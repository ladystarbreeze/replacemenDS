#########################################################################################
# replacemenDS/ARM9 - Open source ARM9 boot ROM replacement.
# Copyright (C) 2021  Michelle-Marie Schiller
#########################################################################################
# mmio.asm - ARM9 Memory-mapped IO definitions.
#########################################################################################

# NOTE: All registers are specified as offsets to the MMIO base address.

# System Control registers
.set IO_POSTFLG, 0x300

# IO_POSTFLG
.set POSTFLG_BootCompleted, 1
