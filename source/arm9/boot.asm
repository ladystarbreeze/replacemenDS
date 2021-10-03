#########################################################################################
# replacemenDS/ARM9 - Open source ARM9 boot ROM replacement.
# Copyright (C) 2021  Michelle-Marie Schiller
#########################################################################################
# boot.asm - ARM9 exception vectors and boot code.
#########################################################################################

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
    b SVCHandler

    # Normally, this vector would branch to a Prefetch Abort exception handler.
    # However, we won't use type of exception. 
    b UnhandledException

    # Normally, this vector would branch to a Data Abort exception handler.
    # However, we won't use type of exception. 
    b UnhandledException

    # This type of exception is not supported on ARMv4T and higher.
    b UnhandledException

    # Branch to Interrupt code (IRQ mode)
    b IRQHandler

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

    sub pc, pc, 8

WarmBoot:
    b WarmBoot