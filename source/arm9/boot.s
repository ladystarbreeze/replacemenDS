@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ replacemenDS/ARM9 - Open source ARM9 boot ROM replacement.
@ Copyright (C) 2021  Michelle-Marie Schiller
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ boot.s - ARM9 exception vectors and boot code.
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

@ Includes
.include "inc/memory.s"
.include "inc/mmio.s"
.include "inc/psr.s"

@ ARM9 exception vector base (located at physical address FFFF0000h)
.arm
ExceptionVectors:
    @ Branch to Reset code (SVC mode)
    b ResetHandler

    @ Normally, this vector would branch to an Undefined Instruction exception handler.
    @ However, we won't use this type of exception.
    b UnhandledException

    @ Branch to Supervisor code (SVC mode)
    b SWIHandler

    @ Normally, this vector would branch to a Prefetch Abort exception handler.
    @ However, we won't use this type of exception.
    b UnhandledException

    @ Normally, this vector would branch to a Data Abort exception handler.
    @ However, we won't use this type of exception.
    b UnhandledException

    @ This type of exception is not supported on ARMv4T and higher.
    b UnhandledException

    @ Branch to Interrupt code (IRQ mode)
    @ b IRQHandler
    b UnhandledException

    @ Normally, this vector would branch to a Fast Interrupt exception handler.
    @ However, we won't use this type of exception.
    b UnhandledException

.arm
UnhandledException:
    b UnhandledException

@ Reset exception handler
.arm
ResetHandler:
    @ Check POSTFLG register
    mov r4, #ADDR_IO
    ldrb r0, [r4, #IO_POSTFLG]
    tst r0, #POSTFLG_BootCompleted

    @ ARM9 has already completed the boot procedure, this is a warm boot!
    bne WarmBoot

    @ This is a cold boot, perform hardware initialization

    .InitializeMainMemory:
        @ Enable main memory in EXMEMCNT
        mov r0, #EXMEMCNT_MainMemoryEnable
        str r0, [r4, #IO_EXMEMCNT]

        @ Note: The original ARM9 boot ROM busy waits after setting EXMEMCNT.
        @ I'm not sure if it is necessary, but let's do it anyway.
        mov r0, #0x2000
        blx SWI_WaitByLoop

        ldr r1, =#ADDR_CR
        ldr r2, =#ADDR_MainMemory + 0x400000 + (DATA_CR << 1)

        @ To initialize main memory, we have to first read the contents of its control
        @ register...
        ldrh r0, [r1]

        @ , write back the data we've read twice...
        strh r0, [r1]
        strh r0, [r1]

        @ and write two arbitrary halfwords (can be the same data).
        strh r0, [r1]
        strh r0, [r1]

        @ The next read from a main memory address will set the new configuration data.
        @ Bits 1-21 of the address contain the new configuration data!
        ldrh r0, [r2]

        @ Complete main memory initialization by writing to EXMEMCNT
        mov r0, #EXMEMCNT_MainMemorySynchronous | EXMEMCNT_MainMemoryEnable
        str r0, [r4, #IO_EXMEMCNT]
    
    @ Initialize System Co-processor
    bl CP15_Initialize

    @ Initialize the stack
    bl SoftReset_InitializeStack

    @ We're in System mode now

    blx InitializeSharedMemory

    b .

    .pool

.arm
WarmBoot:
    b WarmBoot

.thumb
InitializeSharedMemory:
    push {r4, lr}

    @ Note: I'm not quite sure what these messages mean but ARM7 expects them.
    @ Send '0' over IPCSYNC, wait for a '0' response
    ldr r4, =#ADDR_IO + IO_IPCSYNC
    mov r0, #0
    strh r0, [r4]
    bl IPC_WaitSync

    @ Send '1' over IPCSYNC, wait for a '1' response
    lsr r0, r4, #18
    strh r0, [r4]
    lsr r0, r0, #8
    bl IPC_WaitSync

    b .

.pool

.include "swi.s"
.include "systemCP.s"
.include "ipc.s"
