@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ replacemenDS/ARM9 - Open source ARM9 boot ROM replacement.
@ Copyright (C) 2021  Michelle-Marie Schiller
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ swiHalt.s - ARM9 Halt SWI routines.
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

.include "inc/memory.s"
.include "inc/mmio.s"
.include "inc/psr.s"

@ SWI 06h - Halt
.arm
SWI_Halt:
    @ Clear r0
    mov r0, #0

    @ Enter low power mode
    mcr p15, 0, r0, c7, c0, 4

    bx lr

@ SWI 05h - VBlankIntrWait
SWI_VBlankIntrWait:
    @ Note: VBlankIntrWait sets r0, r1 = 1 and calls IntrWait.
    @       We can just set r1 = 1 and reuse the IntrWait handler.
    mov r1, #1

@ SWI 04h - IntrWait
@ r0 = Discard old interrupt flags
@ r1 = Interrupts to wait for
SWI_IntrWait:
    push {r4}

    mov r4, #ADDR_MMIO
    
    @ Get boot ROM interrupt flags address
    @ Note: The boot ROM IF address is hardcoded.
    @       We have to use the same address.
    mrc p15, 0, r2, c9, c1, 0
    mov r2, r2, lsr #12
    mov r2, r2, lsl #12
    add r2, r2, #0x4000

    @ Note: According to GBATEK, No Discard doesn't work. Let's replicate the behavior.

    @ Set IME = 1
    @ Note: This works because all memory accesses on the ARM9 are force-aligned.
    @       That way, we can save a register.
    add r4, #1
    str r4, [r4, #IO_IME]

    .IntrWait_Loop:
        @ Enter low power mode
        mov r0, #0
        mcr p15, 0, r0, c7, c0, 4

        @ Clear IME, get interrupt flags
        str r0, [r4, #IO_IME]
        ldr r0, [r2, #-8]

        @ Acknowledge processed IRQs
        ands r3, r0, r1
        eorne r0, r0, r3
        strne r0, [r2, #-8]

        @ Set IME = 1
        str r4, [r4, #IO_IME]

        @ Repeat if we didn't get the interrupts we wanted
        @ Note: Thanks to the Cult of GBA group for the idea to reuse the Z flag from
        @       the ANDS instruction. https://github.com/Cult-of-GBA/BIOS/blob/master/bios_calls/power.s
        beq .IntrWait_Loop
    
    pop {r4}

    bx lr
