	.intel_syntax noprefix

	/* Multiboot header */
	.section multiboot
	.align 8
	.long 0xe85250d6 /* Multiboot magic */
	.long 0x00000000 /* Architecture: i386 */
	.long 16 + 12 + 8 + 8 /* Header length */
	.long -(0xe85250d6 + 16 + 12 + 8 + 8) /* Checksum */
	/* Console flags tag */
	.align 8
	.short 4
	.short 1 /* Required */
	.long 12 /*mb_tag_mod - mb_tag_cons*/
	.long 1 << 0 | 1 << 1 /* EGA text console */
	/* Module alignment tag */
	.align 8
	.short 6 /* Module alignment */
	.short 0 /* Required */
	.long 8
	/* End tag */
	.align 8
	.short 0 /* End */
	.short 0
	.long 8

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
