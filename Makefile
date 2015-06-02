RUSTC := rustc

target/x86/ge: target/x86/multiboot.o target/x86/ge.o
	$(LD) -T arch/x86/ge.ld -o $@ $^

target/x86/multiboot.o: arch/x86/multiboot.s
target/x86/ge.o: arch/x86/ge.rs

target/x86/%.o: arch/x86/%.s
	$(AS) -c -o $@ $<

target/x86/%.o: arch/x86/%.rs
	$(RUSTC) --emit obj -O -o $@ $<
