#![feature(asm, no_std, core, lang_items, start)]
#![no_std]
#![no_main]

extern crate core;

#[no_mangle]
pub extern fn main() {
}

#[lang = "stack_exhausted"] extern fn stack_exhausted() {}
#[lang = "eh_personality"] extern fn eh_personality() {}

#[lang = "panic_fmt"]
fn panic_fmt() -> ! {
	loop {
		unsafe {
			asm!("cli\nhlt" :::: "volatile")
		}
	}
}
