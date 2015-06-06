RUSTC := rustc

target/x86/ge: target/x86/multiboot.o target/x86/ge.o
	$(LD) -T arch/x86/ge.ld -z common-page-size=4096 -o $@ $^

target/x86/multiboot.o: arch/x86/multiboot.s
target/x86/ge.o: arch/x86/ge.rs

target/x86/grub.iso: target/x86/ge
	grub-mkrescue -o $@ $^ arch/x86/iso

qemu-x86: target/x86/grub.iso
	qemu-system-x86_64 -cpu kvm64 -smp cores=2,threads=2,sockets=1 -m 256M -cdrom $< -name karyon -display curses -monitor stdio

target/x86/%.o: arch/x86/%.s
	$(AS) -c -o $@ $<

target/x86/%.o: arch/x86/%.rs
	$(RUSTC) --emit obj -O -o $@ $<

.PHONY: qemu-x86
