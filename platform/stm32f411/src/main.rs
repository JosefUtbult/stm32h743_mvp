#![no_std]
#![no_main]

use cortex_m::asm;
use cortex_m_rt::entry;
use stm32f4::stm32f411 as pac;
use rtt_target::{rprintln, rtt_init_print};

#[entry]
fn main() -> ! {
    rtt_init_print!();
    rprintln!("Hello, world!");

    let dp = pac::Peripherals::take().unwrap();

    // Enable GPIOB clock (for onboard LED, PB0)
    // dp.RCC.ahb4enr.modify(|_, w| w.gpioben().set_bit());

    // Set PB0 as output
    // dp.GPIOB.moder.modify(|_, w| w.moder0().output());

    loop {
        // Set PB0 high
        dp.GPIOB.bsrr.write(|w| w.bs0().set_bit());
        cortex_m::asm::delay(8_000_000);

        // Set PB0 low
        dp.GPIOB.bsrr.write(|w| w.br0().set_bit());
        cortex_m::asm::delay(8_000_000);
    }
}

#[panic_handler]
fn panic(info: &core::panic::PanicInfo) -> ! {
    rprintln!("{}", info);
    loop {
        asm::bkpt();
    }
}
