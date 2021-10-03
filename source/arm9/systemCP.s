@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ replacemenDS/ARM9 - Open source ARM9 boot ROM replacement.
@ Copyright (C) 2021  Michelle-Marie Schiller
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ systemCP.s - ARM9 System Co-processor handlers.
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

.include "inc/cp15.s"
.include "inc/memory.s"

@ Sets all relevant CP15 registers to a default state
.arm
CP15_Initialize:
    @ Save link register as the stack might be unavailable
    mov r12, lr

    bl CP15_DisableCaches
    bl CP15_InitializeDTCM

    bx r12

@ Disables and invalidates the caches
.arm
CP15_DisableCaches:
    @ Disable data and instruction caches
    CP15_ReadCR 0
    ldr r1, =#CP15_CR_InstructionCacheEnable | CP15_CR_DataCacheEnable
    bic r0, r0, r1
    CP15_WriteCR 0

    @ Invalidate contents of data and instruction caches
    mov r0, #0
    CP15_InvalidateDataCache 0
    CP15_InvalidateInstructionCache 0
    CP15_DrainWriteBuffer 0

    bx lr

@ Initializes the Data TCM
.arm
CP15_InitializeDTCM:
    @ Set DTCM size and base address
    ldr r0, =#ADDR_DTCM | (5 << 1)
    CP15_WriteDTCMSize 0

    @ Enable DTCM
    CP15_ReadCR 0
    orr r0, r0, #CP15_CR_DTCMEnable
    CP15_WriteCR 0

    bx lr

@ Returns the DTCM size and base address
.arm
CP15_GetDTCMSizeAndBase:
    CP15_ReadDTCMSize 1

    @ DTCM Base = CP15_DTCMSize & 0xFFFFF000
    mov r0, r1, lsr #12
    mov r0, r0, lsl #12

    @ DTCM Size = ((CP15_DTCMSize & 0x3E) >> 1) * 512
    and r1, r1, #0x1F << 1
    mov r1, r1, lsl #8

    bx lr

.pool
