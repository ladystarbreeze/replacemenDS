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
    b IRQHandler

    @ Normally, this vector would branch to a Fast Interrupt exception handler.
    @ However, we won't use this type of exception.
    b UnhandledException

.arm
UnhandledException:
    b UnhandledException

@ Interrupt exception handler
.arm
IRQHandler:
    @ Save all volatile registers and the link register
    push {r0-r3, r12, lr}

    @ Get DTCM base address
    mrc p15, 0, r0, c9, c1, 0
    mov r0, r0, lsr #12
    mov r0, r0, lsl #12

    @ Note: The user defined IRQ handler address is hardcoded.
    @       We have to use the same address.
    add r0, r0, #0x4000
    mov lr, pc
    ldr pc, [r0, #-4]

    @ Restore all registers
    pop {r0-r3, r12, lr}

    subs pc, lr, #4

@ Reset exception handler
.arm
ResetHandler:
    @ Check POSTFLG register
    mov r4, #ADDR_IO
    ldrb r0, [r4, #IO_POSTFLG]
    tst r0, #POSTFLG_BootCompleted

    @ ARM9 has already completed the boot procedure, this is a jump to 0!
    bne UnhandledException

    @ This is a cold boot, perform hardware initialization

    @ Enable and set up main memory
    blx InitializeMainMemory
    
    @ Initialize System Co-processor
    bl CP15_Initialize

    @ Initialize the stack
    bl .SoftReset_InitializeStack

    @ Note: We're in System mode now!

    @ Note: I'm not quite sure what these messages mean but ARM7 expects them.
    @       We can customize this part when we're working on the ARM7 boot ROM.
    @ Send '0' over IPCSYNC, wait for a '0' response
    mov r0, #0
    blx IPC_SendSync
    blx IPC_WaitSync @ r0 is still 0

    @ Send '1' over IPCSYNC, wait for a '1' response
    mov r0, #1
    blx IPC_SendSync
    mov r0, r0, lsr #8
    blx IPC_WaitSync

    blx InitializeSharedMemory
    blx ClearDTCMAndMainMemory

    @ Clear Power Control 1
    mov r0, #0
    str r0, [r4, #IO_POWCNT1]

    @ Allocate cartridge slots to ARM7
    ldr r0, [r4, #IO_EXMEMCNT]
    ldr r1, =#EXMEMCNT_MainMemoryARM7Priority | EXMEMCNT_NDSSlotARM7Access | EXMEMCNT_GBASlotARM7Access
    orr r0, r0, r1
    str r0, [r4, #IO_EXMEMCNT]

    @ Initialize ROMCTRL
    mov r0, #ROMCTRL_KEY1GapDummyCLK | ROMCTRL_SlowTransfer
    str r0, [r4, #IO_ROMCTRL]

    @ Send '2' over IPCSYNC, wait for a '3' response
    mov r0, #2
    blx IPC_SendSync
    mov r0, #3
    blx IPC_WaitSync

    @ Send '3' over IPCSYNC
    mov r0, #2
    blx IPC_SendSync

    b .

    .pool

.thumb
InitializeMainMemory:
    @ Enable main memory in EXMEMCNT
    ldr r3, =#ADDR_IO + IO_EXTMEMCNT
    ldr r0, =#EXMEMCNT_MainMemoryEnable
    strh r0, [r3]

    @ Note: The original ARM9 boot ROM busy waits after setting EXMEMCNT.
    @       I'm not sure if it is necessary, but let's do it anyway.
    ldr r0, =#0x2000
    bl SWI_WaitByLoop

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
    ldr r0, =#EXMEMCNT_MainMemorySynchronous | EXMEMCNT_MainMemoryEnable
    strh r0, [r3]

    bx lr

.pool

.thumb
InitializeSharedMemory:
    push {r4, lr}

    @ Clear interrupt registers
    ldr r4, =#ADDR_IO + 0x200
    mov r0, #0
    str r0, [r4, #0x8]  @ Clear IME
    str r0, [r4, #0x10] @ Clear IE
    mvn r0, r0
    str r0, [r4, #0x14] @ Clear IF

    @ Allocate shared memory to ARM7
    ldr r4, =#ADDR_IO + IO_WRAMCNT
    mov r0, #WRAMCNT_AllocateToARM7
    strb r0, [r4]

    pop {r4, pc}

.pool

.equ CpuSet_Fill, 1 << 24

.thumb
ClearDTCMAndMainMemory:
    @ Push fill value onto the stack
    mov r0, #0
    push {r0, lr}

    @ Clear DTCM
    blx CP15_GetDTCMSizeAndBase
    ldr r2, =#CpuSet_Fill
    lsr r1, r1, #2
    sub r1, #0x80
    orr r2, r1
    mov r1, r0
    mov r0, sp
    blx SWI_CpuFastSet

    @ Clear high 32K of main memory
    @ Note: The fill value on the stack is still valid.
    mov r0, sp
    ldr r1, =#ADDR_MainMemory + 0x3F8000
    ldr r2, =#CpuSet_Fill | (0x8000 >> 2)
    blx SWI_CpuFastSet

    pop {r0, pc}

.pool

.include "swi.s"
.include "systemCP.s"
.include "ipc.s"
