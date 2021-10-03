############################################################################################################################
# replacemenDS/ARM9 - Open source ARM9 boot ROM replacement.
# Copyright (C) 2021  Michelle-Marie Schiller
############################################################################################################################
# mmio.asm - ARM9 Memory-mapped IO definitions.
############################################################################################################################

# NOTE: All registers (except CR) are specified as offsets to the MMIO base address.

# Memory Control registers
.set IO_EXMEMCNT, 0x204

# IO_EXMEMCNT
.set EXMEMCNT_MainMemoryEnable     , 1 << 13
.set EXMEMCNT_MainMemorySynchronous, 1 << 14

# System Control registers
.set IO_POSTFLG, 0x300

# IO_POSTFLG
.set POSTFLG_BootCompleted, 1

# Main Memory Control register
.set ADDR_CR, 0x027FFFFE

# CR
.set CR_WELevelControl, 1 <<  7 ; WE Level Control
.set CR_RisingEdge    , 1 <<  9 ; Rising edge is valid
.set CR_Sequential    , 1 << 11 ; Sequential burst
.set CR_4Cycles       , 2 << 12 ; Read latency is 4 cycles
.set CR_Continuous    , 7 << 16 ; Continuous burst
.set CR_NoPartial     , 3 << 19

# Default CR data
.set DATA_CR, CR_NoPartial | CR_Continuous | CR_4Cycles | CR_Sequential | CR_RisingEdge | 0x100 | CR_WELevelControl | 0x7F
