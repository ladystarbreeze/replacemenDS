@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ replacemenDS/ARM9 - Open source ARM9 boot ROM replacement.
@ Copyright (C) 2021  Michelle-Marie Schiller
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ ipc.s - ARM9 Inter-processor Communication routines.
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

.include "inc/mmio.s"

@ Busy waits for a response over IPCSYNC
@ r0 = Expected 4-bit IPC response
.thumb
IPC_WaitSync:
    ldr r2, =#ADDR_IO + IO_IPCSYNC

    .WaitSync_Loop:
        @ It should be fine use ldrb here, bits 4-7 of IPCSYNC are unused.
        ldrb r1, [r2]
        cmp r0, r1
        bne .WaitSync_Loop
    
    bx lr

.balign 4

.pool

@ Sends a message over IPCSYNC
@ r0 = 4-bit IPC message
.thumb
IPC_SendSync:
    ldr r1, =#ADDR_IO + IPCSYNC
    lsl r0, #8
    strh r0, [r1]

    bx lr

.pool
