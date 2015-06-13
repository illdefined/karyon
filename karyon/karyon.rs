#![feature(asm, no_std, core, lang_items, start)]
#![no_std]
#![no_main]

extern crate core;

#[lang = "stack_exhausted"] extern fn stack_exhausted() {}
#[lang = "eh_personality"] extern fn eh_personality() {}

#[no_mangle]
pub extern fn main() {
}

#[lang = "panic_fmt"]
fn panic_fmt() -> ! {
	loop {
	}
}
