@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ replacemenDS/ARM9 - Open source ARM9 boot ROM replacement.
@ Copyright (C) 2021  Michelle-Marie Schiller
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ swi.s - ARM9 Supervisor call dispatcher.
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

.include "inc/psr.s"

@ Supervisor Call exception handler
.arm
SWIHandler:
    push {r11, r12, lr}

    adr r11, .SWITable

    @ Get the SWI comment. We will use it to index into the SWI function table.
    ldrb r12, [lr, #-2]
    ldr r12, [r11, r12, lsl #2]

    @ Save SPSR to prevent it from getting destroyed if an IRQ handler calls another SWI function
    mrs r11, spsr
    push {r11}

    @ Switch into System mode
    @ Note: It is fine to just OR PSR_SYSMode with r11. This does not overwrite the I bit.
    orr r11, r11, #PSR_SYSMode
    msr cpsr_csxf, r11

    @ Save r2 and the System mode link register
    push {r2, lr}

    @ Call the SWI function
    blx r12

    .SWIHandler_Return:
        @ Restore r2 and the System mode link register
        pop {r2, lr}

        @ Switch into Supervisor mode
        msr cpsr_cxsf, #PSR_I | PSR_SVCMode

        @ Restore SPSR
        pop {r11}
        msr spsr_cxsf, r11

        @ Restore r11, r12 and the Supervisor mode link register
        pop {r11, r12, lr}

        movs pc, lr

    .SWITable:
        @ Note: The original ARM9 boot ROM does not handle SWI numbers >= 20h.
        @       We will not (yet?) handle them either.
        .word SWI_SoftReset
        .word SWI_Unhandled
        .word SWI_Unhandled
        .word SWI_WaitByLoop + 1
        .rept 7
        .word SWI_Unhandled
        .endr
        .word SWI_CpuFastSet
        .rept 19
        .word SWI_Unhandled
        .endr
        .word SWI_CustomPost

.arm
SWI_Unhandled:
    b SWI_Unhandled

.include "swi/swiCopy.s"
.include "swi/swiMisc.s"
.include "swi/swiReset.s"
