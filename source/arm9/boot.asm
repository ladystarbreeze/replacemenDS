############################################################################################################################
# replacemenDS/ARM9 - Open source ARM9 boot ROM replacement.
# Copyright (C) 2021  Michelle-Marie Schiller
############################################################################################################################
# boot.asm - ARM9 exception vectors and boot code.
############################################################################################################################

# Includes
.include "inc/memory.asm"
.include "inc/mmio.asm"
.include "inc/psr.asm"

# ARM9 exception vector base (located at physical address FFFF0000h)
ExceptionVectors:
    # Branch to Reset code (SVC mode)
    b ResetHandler

    # Normally, this vector would branch to an Undefined Instruction exception handler.
    # However, we won't use this type of exception.
    b UnhandledException

    # Branch to Supervisor code (SVC mode)
    # b SVCHandler
    b UnhandledException

    # Normally, this vector would branch to a Prefetch Abort exception handler.
    # However, we won't use type of exception.
    b UnhandledException

    # Normally, this vector would branch to a Data Abort exception handler.
    # However, we won't use type of exception.
    b UnhandledException

    # This type of exception is not supported on ARMv4T and higher.
    b UnhandledException

    # Branch to Interrupt code (IRQ mode)
    # b IRQHandler
    b UnhandledException

    # Normally, this vector would branch to a Fast Interrupt exception handler.
    # However, we won't use type of exception.
    b UnhandledException

UnhandledException:
    b UnhandledException

# Reset exception handler
ResetHandler:
    # Check POSTFLG register
    mov r4, ADDR_IO
    ldrb r0, [r4, IO_POSTFLG]
    tst r0, POSTFLG_BootCompleted

    # ARM9 has already completed the boot procedure, this is a warm boot!
    bne WarmBoot

    # This is a cold boot, perform hardware initialization

    InitializeMainMemory:
        ldr r1, .0
        ldr r2, .0 + 4

        # To initialize main memory, we have to first read the contents of its control
        # register...
        ldrh r0, [r1]

        # , write back the data we've read twice...
        strh r0, [r1]
        strh r0, [r1]

        # and write two arbitrary halfwords (can be the same data).
        strh r0, [r1]
        strh r0, [r1]

        # The next read from a main memory address will set the new configuration data.
        # Bits 1-21 of the address contain the new configuration data!
        ldrh r0, [r2]

    sub pc, pc, 8

    # Pool
    .0:
        .4byte ADDR_CR                                     ; [0x00] Main memory control register
        .4byte ADDR_MainMemory + 0x400000 + (DATA_CR << 1) ; [0x04] New main memory configuration data

WarmBoot:
    b WarmBoot
