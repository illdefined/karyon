extern _text
extern _edata
extern _end
extern _start

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
