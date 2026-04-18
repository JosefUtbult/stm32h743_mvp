# Use the rust language
set language rust

# Connect to probe-rs
target extended-remote :1337

# Reset the target
monitor reset halt

# Break execution on main
break main

# Also, on the different failure modes
break DefaultHandler
break HardFault
