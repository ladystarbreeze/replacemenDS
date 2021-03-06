@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ replacemenDS/ARM9 - Open source ARM9 boot ROM replacement.
@ Copyright (C) 2021  Michelle-Marie Schiller
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ swiReset.s - ARM9 Reset SWI routines.
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

.include "inc/memory.s"
.include "inc/psr.s"

@ SWI 00h - SoftReset
.arm
SWI_SoftReset:
    @ Initialize System Co-processor
    bl CP15_Initialize @ This subroutine is included in boot.s

    @ Initialize stack pointers and the stack area
    bl .SoftReset_InitializeStack
    blx .SoftReset_ClearRegisters

    @ Jump to return address in RAM
    ldr lr, =#ADDR_MainMemory + 0x3FFE24
    ldr lr, [lr]
    
    bx lr

    .SoftReset_InitializeStack:
        mov r12, lr

        @ Set stack pointers relative to DTCM base, clear link registers and SPSRs
        @ Note: The original ARM9 boot ROM hardcodes the stack pointers.

        @ Get DTCM size and base address
        bl CP15_GetDTCMSizeAndBase

        @ Get DTCM end address
        add r2, r0, r1

        @ Set SVC mode registers
        msr cpsr_csxf, #PSR_I | PSR_F | PSR_SVCMode
        sub sp, r2, #0x40
        mov lr, #0
        msr spsr, lr

        @ Set IRQ mode registers
        msr cpsr_csxf, #PSR_I | PSR_F | PSR_IRQMode
        sub sp, r2, #0x60
        mov lr, #0
        msr spsr, lr

        @ Set SYS mode registers
        msr cpsr_csxf, #PSR_I | PSR_F | PSR_SYSMode
        sub sp, r2, #0x140

        @ Clear high 200h bytes of DTCM
        sub r1, r2, #0x200
        adr r0, .SoftReset_ClearStackArea + 1
        bx r0
    
    .thumb
    .SoftReset_ClearStackArea:
        mov r0, #0

        .ClearStackArea_Loop:
            str r0, [r1]
            add r1, #4
            cmp r1, r2
            bne .ClearStackArea_Loop
        
        bx r12
    
    .thumb
    .SoftReset_ClearRegisters:
        mov r0, #0
        mov r1, r0
        mov r2, r0
        mov r3, r0
        mov r4, r0
        mov r5, r0
        mov r6, r0
        mov r7, r0
        mov r8, r0
        mov r9, r0
        mov r10, r0
        mov r11, r0
        mov r12, r0

        bx lr
