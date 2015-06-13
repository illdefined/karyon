%include "ge/arch/x86/gdt.s"

extern main

	section .text
	global _start
_start:
	bits 32

	; Set up serial port for debugging
%ifdef DEBUG
	; Save EAX
	mov ebp, eax

	; Disable interrupts
	xor al, al
	mov dx, 0x03f8 + 0x01
	out dx, al

	; Set line control bits
	mov al, 0b10000000 ; DLAB
	mov dx, 0x03f8 + 0x03
	out dx, al

	; Set baud rate to 115200
	xor al, al
	mov dx, 0x03f8 + 0x01
	out dx, al ; High byte
	inc al
	dec dx
	out dx, al ; Low byte

	; Set line control bits
	mov al, 0b00000011 ; 8N1
	mov dx, 0x03f8 + 0x03
	out dx, al

	; Set FIFO control bits
	mov al, 0b11100111
	mov dx, 0x03f8 + 0x02
	out dx, al

	; Set modem control bits
	mov al, 0b00101011
	mov al, 0x0B
	mov dx, 0x03f8 + 0x04
	out dx, al

	; Restore EAX
	mov eax, ebp
%endif

	; Check for multiboot signature
	cmp eax, 0x36d76289
	jne panic

	; Save multiboot information structure address
	mov ebp, ebx

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
	; Write error code to serial line
%ifdef DEBUG
	mov al, 'p'
	mov dx, 0x03f8
	out dx, al
%endif

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

	; Clear flags
	xor rax, rax
	push rax
	popfq

	; Pass multiboot information structure address
	xor rdi, rdi
	mov edi, ebp

	; Write success code to serial line
%ifdef DEBUG
	mov al, 'i'
	mov dx, 0x03f8
	out dx, al
%endif

	call main

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
