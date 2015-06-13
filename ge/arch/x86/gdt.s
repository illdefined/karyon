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
