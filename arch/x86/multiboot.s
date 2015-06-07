	.intel_syntax noprefix

	.section .rodata
text_page:
	.long _text_page
text_size:
	.long _text_size
rodata_page:
	.long _rodata_page
rodata_size:
	.long _rodata_size

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

	/* Initialise the stack */
	mov esp, stack

	/* Check availability of long mode */
	mov eax, 0x80000000
	cpuid
	cmp eax, 0x80000001
	jb panic

	/* PML4T */
	mov edi, pml4t
	mov cr3, edi /* Point control register 3 to the PML4T */
	mov eax, pdpt
	or eax, 1 << 0 | 1 << 1 /* Present, writable */
	mov [edi], eax

	/* PDPT */
	mov edi, pdpt
	mov eax, pdt
	or eax, 1 << 0 | 1 << 1 /* Present, writable */
	mov [edi], eax

	/* PDT */
	mov edi, pdt
	mov eax, pt
	or eax, 1 << 0 | 1 << 1 /* Present, writable */
	mov [edi], eax

	/* Identity map first two MiB in PT */
	mov edi, pt
	mov eax, 1 << 0 | 1 << 1 /* Present, writable */
	mov ebx, 1 << 31 /* NX bit */
	mov ebx, 0
	mov ecx, 512
pt_init:
	mov [edi], eax
	mov [edi+4], ebx
	add eax, 0x1000 /* Advance address by one page */
	add edi, 8 /* Advance index by eight bytes */
	loop pt_init

	/* Set up text segment */
	mov edi, pt
	mov eax, [text_page]
	mov ebx, ~(1 << 1)
	mov ecx, [text_size]
	mov edx, ~(1 << 31)

pt_text:
	and [edi+eax*8], ebx /* Clear writable bit */
	and [edi+eax*8+4], edx /* Clear NX bit */
	inc eax /* Advance index */
	loop pt_text

	/* Set up rodata segment */
	mov edi, pt
	mov eax, [rodata_page]
	mov ebx, ~(1 << 1)
	mov ecx, [rodata_size]

pt_rodata:
	and [edi+eax*8], ebx /* Clear writable bit */
	inc eax /* Advance index by eight bytes */
	loop pt_rodata

	/* Enable PAE */
	mov eax, cr4
	or eax, 1 << 5
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
	cli
	hlt
	jmp short lm64

	.section .bss
	/* Page table */
pml4t:
	.space 0x1000
pdpt:
	.space 0x1000
pdt:
	.space 0x1000
pt:
	.space 0x1000
	/* Initial stack */
	.align 16
	.space 0x4000
stack:
