x86-LD    := ld
x86-AS    := nasm
x86-RUSTC := rustc

x86-cpu   := x86-64
x86-attr  := +64bit,+avx,+call-reg-indirect,+cmov,+cx16,+lzcnt,+popcnt,+sse,+sse2,+sse4.1,+sse4.2,+ssse3

x86-LDFLAGS   := -b elf64-x86-64 -z max-page-size=0x1000 -static -nostdlib
x86-ASFLAGS   := -D DEBUG -f elf64 -F dwarf -g
x86-RUSTFLAGS := --crate-type lib --emit obj -C target-cpu=$(x86-cpu) -C target-feature=$(x86-attr) -C code-model=kernel -C debuginfo=2 -C opt-level=3
x86-QEMUFLAGS := -machine q35 -cpu qemu64,+pse,+pae,+nx,+lm -m 64M -name karyon

define x86-as-d =
$(x86-AS) $(x86-ASFLAGS) -M -MF $@ -MT '$@ $(patsubst %.d,%.o,$@)' $<
endef

define x86-as-o =
$(x86-AS) $(x86-ASFLAGS) -o $@ $<
endef

define x86-rustc-d =
touch $@
endef

define x86-rustc-o =
$(x86-RUSTC) $(x86-RUSTFLAGS) -o $@ $<
endef

x86-ge   := multiboot init ge morestack
x86-ge-o := $(addprefix target/x86/ge/, $(addsuffix .o, $(x86-ge)))
x86-ge-d := $(addprefix target/x86/ge/, $(addsuffix .d, $(x86-ge)))

x86-karyon   := karyon morestack
x86-karyon-o := $(addprefix target/x86/karyon/, $(addsuffix .o, $(x86-karyon)))
x86-karyon-d := $(addprefix target/x86/karyon/, $(addsuffix .d, $(x86-karyon)))

x86: target/x86/ge/ge target/x86/karyon/karyon

x86-check: target/x86/grub.iso target/x86/qemu-monitor
	rm -f target/x86/qemu-serial
	(sleep 20; echo quit) | qemu-system-x86_64 $(x86-QEMUFLAGS) -cdrom $< -boot d -nographic -monitor stdio -serial file:target/x86/qemu-serial
	grep -E -q '^i' target/x86/qemu-serial

x86-qemu: target/x86/grub.iso
	qemu-system-x86_64 $(x86-QEMUFLAGS) -cdrom $< -boot d -display sdl -monitor vc

target/x86/qemu-monitor:
	mkfifo $@

target/x86/grub.iso: target/x86/ge/ge
	grub-mkrescue -o $@ $^ ge/arch/x86/iso

target/x86/ge/ge: ge/arch/x86/ge.ld $(x86-ge-d) $(x86-ge-o)
	$(x86-LD) $(x86-LDFLAGS) -T ge/arch/x86/ge.ld -o $@ $(x86-ge-o)

target/x86/ge:
	mkdir -p $@

target/x86/ge/%.d: ge/arch/x86/%.s target/x86/ge
	$(x86-as-d)

target/x86/ge/%.d: ge/arch/x86/%.rs target/x86/ge
	$(x86-rustc-d)

target/x86/ge/%.o: ge/arch/x86/%.s target/x86/ge
	$(x86-as-o)

target/x86/ge/%.o: ge/arch/x86/%.rs target/x86/ge
	$(x86-rustc-o)

target/x86/karyon/karyon: karyon/arch/x86/karyon.ld $(x86-karyon-d) $(x86-karyon-o)
	$(x86-LD) $(x86-LDFLAGS) -T karyon/arch/x86/karyon.ld -o $@ $(x86-karyon-o)

target/x86/karyon:
	mkdir -p $@

target/x86/karyon/%.d: karyon/arch/x86/%.s target/x86/karyon
	$(x86-as-d)

target/x86/karyon/%.d: karyon/%.rs target/x86/karyon
	$(x86-rustc-d)

target/x86/karyon/%.d: karyon/arch/x86/%.rs target/x86/karyon
	$(x86-rustc-d)

target/x86/karyon/%.o: karyon/arch/x86/%.s target/x86/karyon
	$(x86-as-o)

target/x86/karyon/%.o: karyon/%.rs target/x86/karyon
	$(x86-rustc-o)

target/x86/karyon/%.o: karyon/arch/x86/%.rs target/x86/karyon
	$(x86-rustc-o)

.PHONY: x86 x86-qemu

-include $(x86-ge-d)
