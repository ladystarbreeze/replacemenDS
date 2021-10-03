############################################################################################################################
# replacemenDS/ARM9 - Open source ARM9 boot ROM replacement.
# Copyright (C) 2021  Michelle-Marie Schiller
############################################################################################################################
# cp15.asm - ARM9 System Co-processor definitions and macros.
############################################################################################################################

# Control Register
.set CP15_CR_ProtectionUnitEnable  , 1 <<  0
.set CP15_CR_DataCacheEnable       , 1 <<  2
.set CP15_CR_WriteBufferEnable     , 1 <<  3 ; Always set!
.set CP15_CR_32bitExceptions       , 1 <<  4 ; Always set!
.set CP15_CR_26bitFaultDisable     , 1 <<  5 ; Always set!
.set CP15_CR_LateAbort             , 1 <<  6 ; Always set!
.set CP15_CR_BigEndian             , 1 <<  7
.set CP15_CR_InstructionCacheEnable, 1 << 12
.set CP15_CR_DTCMEnable            , 1 << 16

# CP15 macros
.macro CP15_ReadCR dst
    mrc p15, 0, r\dst, c1, c0, 0
.endm

.macro CP15_WriteCR src
    mcr p15, 0, r\src, c1, c0, 0
.endm

.macro CP15_WriteDTCMSize src
    mcr p15, 0, r\src, c9, c1, 0
.endm

.macro CP15_InvalidateDataCache src
    # The value in rs should be 0!
    mcr p15, 0, r\src, c7, c6, 0
.endm

.macro CP15_InvalidateInstructionCache src
    # The value in rs should be 0!
    mcr p15, 0, r\src, c7, c5, 0
.endm

.macro CP15_DrainWriteBuffer src
    # The value in rs should be 0!
    mcr p15, 0, r\src, c7, c10, 4
.endm
