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
        @ Read IPCSYNC, clear high 28 bits
        ldrh r1, [r2]
        lsl r1, #28
        lsr r1, #28
        cmp r0, r1
        bne .WaitSync_Loop
    
    bx lr

@ Sends a message over IPCSYNC
@ r0 = 4-bit IPC message
.thumb
IPC_SendSync:
    ldr r1, =#ADDR_IO + IO_IPCSYNC
    lsl r0, #8
    strh r0, [r1]

    bx lr

.pool
