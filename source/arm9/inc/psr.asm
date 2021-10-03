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
.set PSR_MODE_USR, 0x10
.set PSR_MODE_FIQ, 0x11
.set PSR_MODE_IRQ, 0x12
.set PSR_MODE_SVC, 0x13
.set PSR_MODE_ABT, 0x17
.set PSR_MODE_UND, 0x1B
.set PSR_MODE_SYS, 0x1F
