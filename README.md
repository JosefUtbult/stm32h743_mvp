# STM32H743 MVP

This project is an attempt at a minimal viable product for embedded rust on the
stm32 platform. The goal is to:

- Enable raw peripheral access using the a pac from one of the `stm32xx` crates
- Allow for tracing using RTT
- Add support for GDB debugging

This is in practice a hello world project that writes a hello world message and
blinks a LED on various STM32 Nucleo boards.

## Components

### Hardware

This guide is intended to be used with a Nucleo board. It contains the actual
processor and an on-board ST-LINK V3 programmer. It is pretty much as plug and
play as you are going to get.

The supported boards are the following:

- STM32H743
- STM32F411

The code for these can be found in the [`platform`](./platform) directory.

### Cortex-M support

Low level access to Cortex-M processors is provided by the
[`cortex-m`](https://docs.rs/cortex-m/latest/cortex_m/) crate. This allows for
access to core peripherals/registers, some interrupt stuff and wrappers around
Cortex-M specific ARM instructions. This could in theory be substituted with a
bunch of register maps to ARM/Cortex-M registers and some assembly code.

Along with this, there is also the
[`cortex-m-rt`](https://docs.rs/cortex-m-rt/latest/cortex_m_rt/) crate. It
provides startup code (interrupt vector setup, actually getting the processor
to run `main`, etc). Without this crate you would have to setup a linker script
manually. Instead, this is done by `cortex-m-rt`. This linking will require a
memory map, `memory.x`, which defines the size and start of the different
memory regions (RAM, Flash).

### Peripheral access

Peripheral access (or `pac`) is done with target specific crates. These are:

- The [`stm32h7`](https://docs.rs/stm32h7/latest/stm32h7/) crate
- The [`stm32f4`](https://docs.rs/stm32f4/latest/stm32f4/) crate

These give you access to a peripheral object that allows you to read/write to
different hardware registers that is unique to the specific STM32 processor
family.

### RTT Tracing

[`rtt-target`](https://docs.rs/crate/rtt-target/latest) is a crate used to
facilitate the target side of the RTT (Real-Time Transfer) I/O protocol. It
gives you macros for tracing over the debug probe.

This could be replaced simply by using a serial port and writing debug
information over it manually.

### Cargo Embed

[`cargo-embed`](https://probe.rs/docs/tools/cargo-embed/) is a tool provided by
the [`probe-rs`](https://probe.rs/) project. It does all the heavy lifting of
the debugging on the host side. It:

- Enables flashing of firmware to the target
- Opens an RTT terminal to read trace output
- Opens a GDB server that GDB can connect to for stepping

This is configured by the `Embed.toml` script.

### GDB

GDB is a debugger for halting execution of programs and manually stepping through it.
The version used here is intended for cross platform debugging. It will be either
`arm-none-eabi-gdb` or `gdb-multiarch` depending on your distribution.

GDB is configured by the `.gdbinit` script provided here. It will try to connect to the
cargo embed GDB server and reset the target.

Alternatively, you can use the debugger provided by `probe-rs` for VSCode. This is
probably a better solution if that is your IDE of choice.

## Setup

Install `cargo-embed`

```bash
cargo install probe-rs
```

```bash
rustup target add thumbv7em-none-eabihf
```

```bash
cargo embed debug
```

Then, in a separate terminal, launch GDB and point to the generated binary.
Note that this example uses the stm32h743 example.

**Debian**
```bash
gdb-multiarch target/thumbv7em-none-eabihf/debug/stm32h743_mvp
```

**Arch**
```bash
arm-none-eabi-gdb target/thumbv7em-none-eabihf/debug/stm32h743_mvp
```

GDB with cargo embed is a bit finicky. It doesn't really work well with
stepping over functions, and it has a tendency to reset itself. The easiest way
of working with it is to restart GDB each time you flash new firmware.

It will probably halt on some weird places in the code when you first start it.
Just run `continue` until you can see that you are in the main function.

To enable `tui` mode, you can either run `tui enable` manually or add the following
to `~/.config/gdb/gdbinit`:

```
tui enable
```
