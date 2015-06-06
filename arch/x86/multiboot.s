	.intel_syntax noprefix

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

	/* TODO: Initialise long mode */

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

	/* Initial stack */
	.bss
	.space 0x1000
stack:
