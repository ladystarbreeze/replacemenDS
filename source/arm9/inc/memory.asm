############################################################################################################################
# replacemenDS/ARM9 - Open source ARM9 boot ROM replacement.
# Copyright (C) 2021  Michelle-Marie Schiller
############################################################################################################################
# mmio.asm - ARM9 Memory Region definitions.
############################################################################################################################

# Region base addresses
.set ADDR_DTCM      , 0x00800000
.set ADDR_MainMemory, 0x02000000
.set ADDR_IO        , 0x04000000
.set ADDR_BootROM   , 0xFFFF0000
