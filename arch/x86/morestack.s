	global __morestack
	bits 64
__morestack:
	cli
	hlt
	jmp short __morestack
