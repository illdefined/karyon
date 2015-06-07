OUTPUT_FORMAT(elf64-x86-64)
ENTRY(_start)

PHDRS {
	text PT_LOAD FLAGS(5);   /* R-E */
	rodata PT_LOAD FLAGS(4); /* R-- */
	data PT_LOAD FLAGS(6);   /* RW- */
}

SECTIONS {
	. = SIZEOF_HEADERS;

	.text : ALIGN(4K) {
		*(multiboot)
		*(.text)
		_etext = .;
	} :text

	.rodata : ALIGN(4K) {
		*(.rodata)
		_erodata = .;
	} :rodata

	.data : ALIGN(4K) {
		*(.data)
		_edata = .;
	} :data

	.bss : {
		*(.bss)
		_end = .;
	} :data

	_text_page = ADDR(.text) / 0x1000;
	_rodata_page = ADDR(.rodata) / 0x1000;
	_data_page = ADDR(.data) / 0x1000;

	_text_size = _rodata_page - _text_page;
	_rodata_size = _data_page - _rodata_page;
}
