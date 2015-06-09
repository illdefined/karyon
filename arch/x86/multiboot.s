extern _text
extern _edata
extern _end

	section .rodata
	; 64 bit GDT
gdt_base:
	gdt_null equ $ - gdt_base
	resb 8
	gdt_code equ $ - gdt_base
	dw 0 ; Limit (low)
	dw 0 ; Base (low)
	db 0 ; Base (middle)
	db 0b10011000 ; Access
	db 0b00100000 ; Granularity
	db 0 ; Base (high)
	gdt_data equ $ - gdt_base
	dw 0 ; Limit (low)
	dw 0 ; Base (low)
	db 0 ; Base (middle)
	db 0b10010000 ; Access
	db 0b00100000 ; Granularity
	db 0 ; Base (high)
gdt:
	dw $ - gdt_base - 1
	dq gdt_base

	; Multiboot header
	section multiboot
	align 8
mb_start:
	dd 0xe85250d6 ; Multiboot magic
	dd 0x00000000 ; Architecture: i386
	dd mb_end - mb_start ; Header length
	dd -(0xe85250d6 + (mb_end - mb_start)) ; Checksum

	; Address tag
	align 8
mb_tag_addr_start:
	dw 2
	dw 1 ; Optional
	dd mb_tag_addr_end - mb_tag_addr_start
	dd mb_start ; Multiboot header address
	dd _text     ; Load address
	dd _edata  ; Load end address
	dd _end      ; BSS end address
mb_tag_addr_end:

	; Entry address tag
	align 8
mb_tag_entry_start:
	dw 3
	dw 1 ; Optional
	dd mb_tag_entry_end - mb_tag_entry_start
	dd _start      ; Entry address
mb_tag_entry_end:

	; Console flags tag
	align 8
mb_tag_cons_start:
	dw 4
	dw 1 ; Optional
	dd mb_tag_cons_end - mb_tag_cons_start
	dd 1 << 0 | 1 << 1 ; EGA text console
mb_tag_cons_end:

	; Module alignment tag
	align 8
mb_tag_mod_start:
	dw 6 ; Module alignment
	dw 0 ; Required
	dd mb_tag_mod_end - mb_tag_mod_start
mb_tag_mod_end:

	; End tag
	align 8
mb_tag_end_start:
	dw 0 ; End
	dw 0
	dd mb_tag_end_end - mb_tag_end_start
mb_tag_end_end:
mb_end:

	section .text
	global _start
_start:
	bits 32
	; Check for multiboot signature
	cmp eax, 0x36d76289
	jne panic

	; Check availability of long mode
	mov eax, 0x80000000
	cpuid
	cmp eax, 0x80000001
	jb panic

	; Check availability of Page Size Extension
	mov eax, 0x00000001
	cpuid
	and edx, 1 << 3
	jz panic

	; Check availability of NX bit
	mov eax, 0x80000001
	cpuid
	and edx, 1 << 20
	jz panic

	; Identity map first 4 GiB with 2 MiB pages

	; PML4
	mov edi, pml4
	mov cr3, edi ; Point control register 3 to the PML4T
	mov eax, pdp
	or eax, 1 << 0 | 1 << 1 ; Present, writable
	stosd ; Write PML4T entry

	; PDP
	mov edi, pdp
	mov eax, pd
	or eax, 1 << 0 | 1 << 1 ; Present, writable
	mov ebx, 0x1000 ; PD size
	mov ecx, 4 ; Number of PDPT entries
	mov edx, 4 ; Extra PDPT entry size

pdp_init:
	stosd ; Write PDPT entry
	add eax, ebx ; Advance PD address
	add edi, edx ; Advance PDPT index
	loop pdp_init

	; PD
	mov edi, pd
	mov eax, 1 << 0 | 1 << 1 | 1 << 7 ; Present, writable, 2 MiB
	mov ebx, 2 * 1024 * 1024 ; Page size
	mov ecx, 2048 ; 2048 PD entries
	mov edx, 4 ; Extra PD entry size

pd_init:
	stosd ; Write PD index
	add eax, ebx ; Advance page address
	add edi, edx ; Advance PD index
	loop pd_init

	; Enable PSE and PAE
	mov eax, cr4
	or eax,  1 << 4 | 1 << 5
	mov cr4, eax

	; Enter long mode
	mov ecx, 0xc0000080 ; EFER MSR
	rdmsr
	or eax, 1 << 8 ; Long mode flag
	wrmsr

	; Enable paging
	mov eax, cr0
	or eax, 1 << 31
	mov cr0, eax

	; Enter 64 bit long mode
	lgdt [gdt]
	jmp gdt_code:lm64

panic:
	; BSOD
	xor eax, eax
	mov ah, 16
	mov ecx, 80 * 25
	mov edi, 0xb8000
	rep stosw

.halt:
	cli
	hlt
	jmp short .halt

	bits 64
lm64:
	; Initialise the stack
	mov rsp, stack

.halt:
	cli
	hlt
	jmp short .halt

	section .bss
	align 0x1000
	; Page table
pml4:
	resb 0x1000
pdp:
	resb 0x1000
pd:
	resb 0x4000
	; Initial stack
	align 16
	resb 0x4000
stack:
