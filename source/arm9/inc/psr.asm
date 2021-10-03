############################################################################################################################
# replacemenDS/ARM9 - Open source ARM9 boot ROM replacement.
# Copyright (C) 2021  Michelle-Marie Schiller
############################################################################################################################
# psr.asm - ARM9 Processor Status Register definitions.
############################################################################################################################

# Condition code flags
.set PSR_Q, 1 << 27
.set PSR_V, 1 << 28
.set PSR_C, 1 << 29
.set PSR_Z, 1 << 30
.set PSR_N, 1 << 31

# Control flags
.set PSR_T, 1 << 5
.set PSR_F, 1 << 6 ; FIQ Disable!
.set PSR_I, 1 << 7 ; IRQ Disable!

# Mode field
.set PSR_USRMode, 0x10
.set PSR_FIQMode, 0x11
.set PSR_IRQMode, 0x12
.set PSR_SVCMode, 0x13
.set PSR_ABTMode, 0x17
.set PSR_UNDMode, 0x1B
.set PSR_SYSMode, 0x1F
