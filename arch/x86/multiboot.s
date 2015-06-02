	.intel_syntax noprefix

	/* Multiboot header */
	.section multiboot
	.align 4
	.set MAGIC, 0x1badb002
	.set FLAGS, 1 << 0 | 1 << 1
	.long MAGIC
	.long FLAGS
	.long -(MAGIC + FLAGS)

	.section multiboot
	.global _start
_start:
	.code32
	/* Check for multiboot signature */
	cmp eax, 0x2badb002
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
