# Use the rust language
set language rust

# Reload command re-attaches to the host and resets it
# Useful for when re-programming with cargo embed
define reload
	# Connect to probe-rs
	target extended-remote :1337

	# Reset the target
	monitor reset halt

	# Break execution on main
	break main

	# Also, on the different failure modes
	break DefaultHandler
	break HardFault
	break rust_begin_unwind

end

reload
