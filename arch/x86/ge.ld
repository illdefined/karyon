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

	.bss : ALIGN(4K) {
		*(.bss)
		_end = .;
	} :data
}
