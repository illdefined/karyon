	.intel_syntax noprefix

	.section .rodata
	/* 64 bit GDT */
gdt_base:
	.set gdt_null, $ - gdt_base
	.skip 8
	.set gdt_code, $ - gdt_base
	.short 0 /* Limit (low) */
	.short 0 /* Base (low) */
	.byte 0 /* Base (middle) */
	.byte 0b10011000 /* Access */
	.byte 0b00100000 /* Granularity */
	.byte 0 /* Base (high) */
	.set gdt_data, $ - gdt_base
	.short 0 /* Limit (low) */
	.short 0 /* Base (low) */
	.byte 0 /* Base (middle) */
	.byte 0b10010000 /* Access */
	.byte 0b00100000 /* Granularity */
	.byte 0 /* Base (high) */
gdt:
	.short $ - gdt_base - 1
	.quad gdt_base

	/* Multiboot header */
	.section multiboot
	.align 8
mb_start:
	.long 0xe85250d6 /* Multiboot magic */
	.long 0x00000000 /* Architecture: i386 */
	.long mb_end - mb_start /* Header length */
	.long -(0xe85250d6 + (mb_end - mb_start)) /* Checksum */

	/* Address tag */
	.align 8
mb_tag_addr_start:
	.short 2
	.short 1 /* Optional */
	.long mb_tag_addr_end - mb_tag_addr_start
	.long mb_start /* Multiboot header address */
	.long .text     /* Load address */
	.long _erodata  /* Load end address */
	.long _end      /* BSS end address */
mb_tag_addr_end:

	/* Entry address tag */
	.align 8
mb_tag_entry_start:
	.short 3
	.short 1 /* Optional */
	.long mb_tag_entry_end - mb_tag_entry_start
	.long _start      /* Entry address */
mb_tag_entry_end:

	/* Console flags tag */
	.align 8
mb_tag_cons_start:
	.short 4
	.short 1 /* Optional */
	.long mb_tag_cons_end - mb_tag_cons_start
	.long 1 << 0 | 1 << 1 /* EGA text console */
mb_tag_cons_end:

	/* Module alignment tag */
	.align 8
mb_tag_mod_start:
	.short 6 /* Module alignment */
	.short 0 /* Required */
	.long mb_tag_mod_end - mb_tag_mod_start
mb_tag_mod_end:

	/* End tag */
	.align 8
mb_tag_end_start:
	.short 0 /* End */
	.short 0
	.long mb_tag_end_end - mb_tag_end_start
mb_tag_end_end:
mb_end:

	.section .text
	.global _start
_start:
	.code32
	/* Check for multiboot signature */
	cmp eax, 0x36d76289
	jne panic

	/* Check availability of long mode */
	mov eax, 0x80000000
	cpuid
	cmp eax, 0x80000001
	jb panic

	/* Check availability of Page Size Extension */
	mov eax, 0x00000001
	cpuid
	and edx, 1 << 3
	jz panic

	/* Check availability of NX bit */
	mov eax, 0x80000001
	cpuid
	and edx, 1 << 20
	jz panic

	/* Identity map first 4 GiB with 2 MiB pages */

	/* PML4 */
	mov edi, pml4
	mov cr3, edi /* Point control register 3 to the PML4T */
	mov eax, pdp
	or eax, 1 << 0 | 1 << 1 /* Present, writable */
	stosd /* Write PML4T entry */

	/* PDP */
	mov edi, pdp
	mov eax, pd
	or eax, 1 << 0 | 1 << 1 /* Present, writable */
	mov ebx, 0x1000 /* PD size */
	mov ecx, 4 /* Number of PDPT entries */
	mov edx, 4 /* Extra PDPT entry size */

	mov ebp, _edata
	hlt

pdp_init:
	stosd /* Write PDPT entry */
	add eax, ebx /* Advance PD address */
	add edi, edx /* Advance PDPT index */
	loop pdp_init

	/* PD */
	mov edi, pd
	mov eax, 1 << 0 | 1 << 1 | 1 << 7 /* Present, writable, 2 MiB */
	mov ebx, 2 * 1024 * 1024 /* Page size */
	mov ecx, 2048 /* 2048 PD entries */
	mov edx, 4 /* Extra PD entry size */

pd_init:
	stosd /* Write PD index */
	add eax, ebx /* Advance page address */
	add edi, edx /* Advance PD index */
	loop pd_init

	/* Enable PSE and PAE */
	mov eax, cr4
	or eax,  1 << 4 | 1 << 5
	mov cr4, eax

	/* Enter long mode */
	mov ecx, 0xc0000080 /* EFER MSR */
	rdmsr
	or eax, 1 << 8 /* Long mode flag */
	wrmsr

	/* Enable paging */
	mov eax, cr0
	or eax, 1 << 31
	mov cr0, eax

	/* Enter 64 bit long mode */
	lgdt [gdt]
	jmp gdt_code:lm64

panic:
	/* BSOD */
	xor eax, eax
	mov ah, 16
	mov ecx, 80 * 25
	mov edi, 0xb8000
	rep stosw

halt:
	cli
	hlt
	jmp short halt

	.code64
lm64:
	/* Initialise the stack */
	mov rsp, stack

halt64:
	cli
	hlt
	jmp short halt64

	.section .bss
	/* Page table */
pml4:
	.space 0x1000
pdp:
	.space 0x1000
pd:
	.space 0x4000
	/* Initial stack */
	.align 16
	.space 0x4000
stack:
