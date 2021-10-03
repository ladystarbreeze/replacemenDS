############################################################################################################################
# replacemenDS/ARM9 - Open source ARM9 boot ROM replacement.
# Copyright (C) 2021  Michelle-Marie Schiller
############################################################################################################################
# systemCP.asm - ARM9 System Co-processor handlers.
############################################################################################################################

.include "inc/cp15.asm"
.include "inc/memory.asm"

# Sets all relevant CP15 registers to a default state
CP15_Initialize:
    # Save link register as the stack might be unavailable
    mov r12, lr

    bl CP15_DisableCaches
    bl CP15_InitializeDTCM

    bx r12

CP15_DisableCaches:
    # Disable data and instruction caches
    CP15_ReadCR 0
    ldr r1, .0
    bic r0, r0, r1
    CP15_WriteCR 0

    # Invalidate contents of data and instruction caches
    mov r0, #0
    CP15_InvalidateDataCache 0
    CP15_InvalidateInstructionCache 0
    CP15_DrainWriteBuffer 0

    bx lr

    # Pool
    .0:
        .4byte CP15_CR_InstructionCacheEnable | CP15_CR_DataCacheEnable ; [0x00] CR mask

CP15_InitializeDTCM:
    # Set DTCM size and base address
    ldr r0, .0
    CP15_WriteDTCMSize 0

    # Enable DTCM
    CP15_ReadCR 0
    orr r0, r0, #CP15_CR_DTCMEnable
    CP15_WriteCR 0

    bx lr

    # Pool
    .0:
        .4byte ADDR_DTCM | (5 << 1) ; [0x00] DTCM configuration data
