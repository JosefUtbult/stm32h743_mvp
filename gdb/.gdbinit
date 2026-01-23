target extended-remote :3333
# target extended-remote :1337

# Workaround to get rust functions to register
set language c

# print demangled symbols
set print asm-demangle on

# set backtrace limit to not have infinite backtrace loops
set backtrace limit 32

# detect unhandled exceptions, hard faults and panics
break DefaultHandler
break HardFault
break rust_begin_unwind
# # run the next few lines so the panic message is printed immediately
# # the number needs to be adjusted for your panic handler
# commands $bpnum
# next 4
# end

# *try* to stop at the user entry point (it might be gone due to inlining)
break main

monitor arm semihosting enable

# # send captured ITM to the file itm.fifo
# # (the microcontroller SWO pin must be connected to the programmer SWO pin)
# # 8000000 must match the core clock frequency
# monitor tpiu config internal itm.txt uart off 8000000

# OR: make the microcontroller SWO pin output compatible with UART (8N1)
# 8000000 must match the core clock frequency
# 2000000 is the frequency of the SWO pin
#monitor tpiu config external uart off 8000000 2000000

# # enable ITM port 0
#monitor itm port 0 on

# Use the PyCortexMDebug plugin to load an svd file
python
import os
from pathlib import Path

# If using the script directly from the source tree without installing
# it, add parent dir in search path to find cmdebug module
try:
    script_path = Path(os.path.abspath(os.path.expanduser(__file__)))
    if (script_path.parents[1] / 'cmdebug').is_dir():
        sys.path.append(str(script_path.parents[1]))
except:
    pass

from cmdebug.svd_gdb import LoadSVD
from cmdebug.dwt_gdb import DWT

DWT()
LoadSVD()
end

svd_load ./STM32H743.svd

# start the process but immediately halt the processor
run
stepi

tui enable
