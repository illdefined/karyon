RUSTC := rustc

target/x86/ge: target/x86/init.o target/x86/ge.o
	$(LD) -T arch/x86/ge.ld -z max-page-size=4096 -static -o $@ $^

target/x86/init.o: arch/x86/init.s
target/x86/ge.o: arch/x86/ge.rs

target/x86/grub.iso: target/x86/ge
	grub-mkrescue -o $@ $^ arch/x86/iso

qemu-x86: target/x86/grub.iso
	qemu-system-x86_64 -cpu kvm64 -smp cores=2,threads=2,sockets=1 -m 256M -cdrom $< -name karyon -display sdl -monitor vc

target/x86/%.o: arch/x86/%.s
	nasm -f elf64 -o $@ $<

target/x86/%.o: arch/x86/%.rs
	$(RUSTC) --emit obj -O -o $@ $<

.PHONY: qemu-x86
