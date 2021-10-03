############################################################################################################################
# replacemenDS/ARM9 - Open source ARM9 boot ROM replacement.
# Copyright (C) 2021  Michelle-Marie Schiller
############################################################################################################################
# swiReset.asm - ARM9 Reset SWI routines.
############################################################################################################################

.include "inc/cp15.asm"
.include "inc/memory.asm"
.include "inc/psr.asm"

.arm

# SWI 00h - SoftReset
SWI_SoftReset:
    # Initialize System Co-processor
    bl CP15_Initialize ; This subroutine is included in boot.asm

    # Initialize stack pointers and the stack area
    bl SoftReset_InitializeStack

    sub pc, pc, #8

    SoftReset_InitializeStack:
        # Set stack pointers relative to DTCM base, clear link registers and SPSRs
        # Note: The original ARM9 boot ROM hardcodes the stack pointers.

        # Get DTCM size and base address
        CP15_ReadDTCMSize 2
        mov r0, r2, lsr #12
        mov r0, r0, lsl #12
        and r2, r2, #0x1F << 1
        mov r1, #256
        mov r1, r1, lsl r2

        # Get DTCM end address
        add r2, r0, r1

        # Set SVC mode registers
        msr cpsr_csxf, #PSR_I | PSR_F | PSR_SVCMode
        sub sp, r2, #0x40
        mov lr, #0
        msr spsr, lr

        # Set IRQ mode registers
        msr cpsr_csxf, #PSR_I | PSR_F | PSR_IRQMode
        sub sp, r2, #0x60
        mov lr, #0
        msr spsr, lr

        # Set SYS mode registers
        msr cpsr_csxf, #PSR_I | PSR_F | PSR_SYSMode
        sub sp, r2, #0x140

        # Clear high 200h bytes of DTCM
        sub r1, r2, #0x200
        adr r0, SoftReset_ClearStackArea + 1
        bx r0
    
    .thumb
    SoftReset_ClearStackArea:
        mov r0, #0

        .0:
            str r0, [r2, r1]
            add r1, #4
            cmp r1, r2
            bne .0
        
        bx lr
