@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ replacemenDS/ARM9 - Open source ARM9 boot ROM replacement.
@ Copyright (C) 2021  Michelle-Marie Schiller
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ swiReset.s - ARM9 Memory Copy and Set SWI routines.
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

.equ CpuSet_Fill, 1 << 24
.equ CpuSet_Word, 1 << 26

@ SWI 0Ch - CpuFastSet
@ r0 = Source address
@ r1 = Destination address
@ r2 = Transfer length/Copy mode
.arm
SWI_CpuFastSet:
    push {r4-r11, lr}

    @ Get word count
    mov r3, r2, lsl #11
    movs r3, r3, lsr #11
    beq .CpuFastSet_Return

    @ Check if the requested operation is a fill or a copy
    teq r2, #CpuSet_Fill

    @ r3 holds the 8-word chunk count, r2 the remaining word count
    and r2, r3, #7
    mov r3, r3, lsr #3

    beq .CpuFastSet_Fill

    .CpuFastSet_Copy:
        ldmia r0!, {r4-r11}
        stmia r1!, {r4-r11}
        subs r3, r3, #1
        bne .CpuFastSet_Copy
        
        @ Return if there are no remaining words
        movs r2, r2
        beq .CpuFastSet_Return
    
    .CpuFastSet_SlowCopy:
        @ Copy remaining words
        ldr r3, [r0], #4
        str r3, [r1], #4
        subs r2, r2, #1
        bne .CpuFastSet_SlowCopy
        beq .CpuFastSet_Return

    .CpuFastSet_Fill:
        ldr r0, [r0]
        mov r4, r0
        mov r5, r0
        mov r6, r0
        mov r7, r0
        mov r8, r0
        mov r9, r0
        mov r10, r0
        mov r11, r0
    
        .CpuFastSet_Fill_Loop:
            stmia r1!, {r4-r11}
            subs r3, r3, #1
            bne .CpuFastSet_Fill_Loop
        
        @ Return if there are no remaining words
        movs r2, r2
        beq .CpuFastSet_Return
    
    .CpuFastSet_SlowFill:
        @ Fill remaining words
        str r0, [r1], #4
        subs r2, r2, #1
        bne .CpuFastSet_SlowFill

    .CpuFastSet_Return:
        pop {r4-r11, pc}
