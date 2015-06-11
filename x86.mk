x86-LD    := ld
x86-AS    := nasm
x86-RUSTC := rustc

x86-cpu   := x86-64
x86-attr  := +64bit,+avx,+call-reg-indirect,+cmov,+cx16,+lzcnt,+popcnt,+sse,+sse2,+sse4.1,+sse4.2,+ssse3

x86-LDFLAGS   := -b elf64-x86-64 -z max-page-size=0x1000 -static -nostdlib
x86-ASFLAGS   := -D DEBUG -f elf64 -F dwarf -g
x86-RUSTFLAGS := --emit obj -C target-cpu=$(x86-cpu) -C target-feature=$(x86-attr) -C code-model=kernel -C debuginfo=2 -C opt-level=3

x86-ge   := multiboot init ge morestack
x86-ge-o := $(addprefix target/x86/, $(addsuffix .o, $(x86-ge)))
x86-ge-d := $(addprefix target/x86/, $(addsuffix .d, $(x86-ge)))

x86: target/x86/ge

x86-qemu: target/x86/grub.iso
	qemu-system-x86_64 -m 64M -name karyon -cdrom $< -boot d -display sdl -monitor vc

target/x86/grub.iso: target/x86/ge
	grub-mkrescue -o $@ $^ arch/x86/iso

target/x86/ge: arch/x86/ge.ld $(x86-ge-d) $(x86-ge-o)
	$(x86-LD) $(x86-LDFLAGS) -T arch/x86/ge.ld -o $@ $(x86-ge-o)

target/x86/%.d: arch/x86/%.s
	$(x86-AS) $(x86-ASFLAGS) -M -MF $@ $<

target/x86/%.d: arch/x86/%.rs
	touch $@

target/x86/%.o: arch/x86/%.s
	$(x86-AS) $(x86-ASFLAGS) -o $@ $<

target/x86/%.o: arch/x86/%.rs
	$(x86-RUSTC) $(x86-RUSTFLAGS) -o $@ $<

.PHONY: x86 x86-qemu

-include $(x86-ge-d)
