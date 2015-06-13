karyon – a microkernel experiment in Rust
=========================================

[![build status][badge-travis]][travis]

[badge-travis]: https://img.shields.io/travis/illdefined/karyon.svg
[travis]: https://travis-ci.org/illdefined/karyon

## Abstract

*karyon* is my personal microkernel experiment in the Rust programming language.

## Building

Although *karyon* is intended to be portable to any platform with an MMU, only x86-64 is supported for now.

### Prerequisites

The following software is required to build *karyon*:

* [POSIX Shell utilities](http://pubs.opengroup.org/onlinepubs/009696699/utilities/contents.html) (provided out of the box by most unixoid systems)
* [GNU make](https://www.gnu.org/software/make/)
* [Python](https://www.python.org/) (version ≥ 2.6)
* [GNU Binutils](https://www.gnu.org/software/binutils/)
* [NASM](http://www.nasm.us/) (version ≥ 2.11.06)
* [Rust](http://www.rust-lang.org/) (nightly)

The automatic tests additionally require:

* [GRUB](https://www.gnu.org/software/grub/) (version ≥ 2.00)
* [libisoburn](http://libburnia-project.org/)
* [QEMU](http://www.qemu.org/) (version ≥ 2.0)

On a current installation of Ubuntu Linux (≥ 14.04), these can be installed as follows:

```sh
sudo apt-get install make python binutils alien curl grub2 xorriso qemu-system-x86
curl -s -S -f https://static.rust-lang.org/rustup.sh | sh -s -- --channel=nightly
curl -f -O http://www.nasm.us/pub/nasm/releasebuilds/2.11.08/linux/nasm-2.11.08-1.x86_64.rpm
sudo alien nasm-2.11.08-1.x86_64.rpm
sudo dpkg -i nasm_2.11.08-2_amd64.deb
```

### Compiling

```sh
make x86
```

### Automatic tests

```sh
make x86-check
```

### Running

```sh
make x86-qemu
```

## Tasks

* Parse Multiboot tags and setup framebuffer
* Add primitive ELF parser to run kernel
* Implement [GDB stub](https://sourceware.org/gdb/onlinedocs/gdb/Remote-Protocol.html) for remote debugging
* Design and implement API / ABI
* Implement σ₀

## Copyright

This work may be used under the terms of the MirOS licence.

Please refer to the ‘Licence’ file in the source tree for details.
