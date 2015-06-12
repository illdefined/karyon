-include version.mk
include x86.mk

version.mk: version.py $(addprefix .git/, $(shell test -d .git && cut -d ' ' -f 2 .git/HEAD))
	git describe --dirty --long --always | python2 version.py >$@
