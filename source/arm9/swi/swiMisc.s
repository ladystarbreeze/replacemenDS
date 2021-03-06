@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ replacemenDS/ARM9 - Open source ARM9 boot ROM replacement.
@ Copyright (C) 2021  Michelle-Marie Schiller
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ swiReset.s - ARM9 Misc SWI routines.
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

.include "inc/memory.s"
.include "inc/mmio.s"

@ SWI 03h - WaitByLoop
@ r0 = Number of loop iterations (between 1 and 7FFFFFFFh)
.thumb
SWI_WaitByLoop:
    @ Use a wait loop to burn cycles.
    @ Uncached Thumb code is faster than (uncached) ARM code. The original ARM9 boot ROM uses Thumb code, too.
    sub r0, #1
    bgt SWI_WaitByLoop
    
    bx lr

.balign 4

@ SWI 0Fh - IsDebugger
@ r0 = 0 (Retail console), 1 (Debugger)
.thumb
SWI_IsDebugger:
    @ Note: We don't support non-retail hardware, always return 0.
    mov r0, #0

    bx lr

@ SWI 1Fh - CustomPost
@ r0 = Data to be written to IO_POSTFLG
.thumb
SWI_CustomPost:
    ldr r1, =#ADDR_IO + IO_POSTFLG
    str r0, [r1]

    bx lr

.pool
