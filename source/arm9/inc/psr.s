@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ replacemenDS/ARM9 - Open source ARM9 boot ROM replacement.
@ Copyright (C) 2021  Michelle-Marie Schiller
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ psr.s - ARM9 Processor Status Register definitions.
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

@ Condition code flags
.equ PSR_Q, 1 << 27
.equ PSR_V, 1 << 28
.equ PSR_C, 1 << 29
.equ PSR_Z, 1 << 30
.equ PSR_N, 1 << 31

@ Control flags
.equ PSR_T, 1 << 5
.equ PSR_F, 1 << 6 @ FIQ Disable!
.equ PSR_I, 1 << 7 @ IRQ Disable!

@ Mode field
.equ PSR_USRMode, 0x10
.equ PSR_FIQMode, 0x11
.equ PSR_IRQMode, 0x12
.equ PSR_SVCMode, 0x13
.equ PSR_ABTMode, 0x17
.equ PSR_UNDMode, 0x1B
.equ PSR_SYSMode, 0x1F
