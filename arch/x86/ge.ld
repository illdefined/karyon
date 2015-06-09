OUTPUT_FORMAT(elf64-x86-64)
ENTRY(_start)

PHDRS {
	text PT_LOAD FLAGS(5);   /* R-E */
	rodata PT_LOAD FLAGS(4); /* R-- */
	data PT_LOAD FLAGS(6);   /* RW- */
}

SECTIONS {
	. = SIZEOF_HEADERS;

	.text : ALIGN(16) {
		_text = .;
		*(multiboot)
		*(.text)
		_etext = .;
	} :text

	.rodata : ALIGN(16) {
		*(.rodata)
		_erodata = .;
	} :rodata

	.data : ALIGN(16) {
		*(.data)
		_edata = .;
	} :data

	.bss : ALIGN(16) {
		*(.bss)
		_end = .;
	} :data
}
