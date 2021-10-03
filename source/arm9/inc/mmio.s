@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ replacemenDS/ARM9 - Open source ARM9 boot ROM replacement.
@ Copyright (C) 2021  Michelle-Marie Schiller
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ mmio.s - ARM9 Memory-mapped IO definitions.
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

@ NOTE: All registers (except CR) are specified as offsets to the MMIO base address.

@ Inter-processor Communication registers
.equ IO_IPCSYNC, 0x180

@ IO_IPCSYNC
.equ IPCSYNC_SendIRQ  , 1 << 13
.equ IPCSYNC_IRQEnable, 1 << 14

@ Memory Control registers
.equ IO_EXMEMCNT, 0x204

@ IO_EXMEMCNT
.equ EXMEMCNT_MainMemoryEnable     , 1 << 13
.equ EXMEMCNT_MainMemorySynchronous, 1 << 14

@ System Control registers
.equ IO_POSTFLG, 0x300

@ IO_POSTFLG
.equ POSTFLG_BootCompleted, 1

@ Main Memory Control register
.equ ADDR_CR, 0x027FFFFE

@ CR
.equ CR_WELevelControl, 1 <<  7 @ WE Level Control
.equ CR_RisingEdge    , 1 <<  9 @ Rising edge is valid
.equ CR_Sequential    , 1 << 11 @ Sequential burst
.equ CR_4Cycles       , 2 << 12 @ Read latency is 4 cycles
.equ CR_Continuous    , 7 << 16 @ Continuous burst
.equ CR_NoPartial     , 3 << 19

@ Default CR data
.equ DATA_CR, CR_NoPartial | CR_Continuous | CR_4Cycles | CR_Sequential | CR_RisingEdge | 0x100 | CR_WELevelControl | 0x7F
