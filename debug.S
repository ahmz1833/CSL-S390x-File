#==============================================
    # Project: S390x File Handling System
    # File Name: debug.S
    # Description: This file contains the debugging functions and macros
    # Optional Project - CSL 1403-1 - Dr. Asadi
    # AmirMahdi Tahmasebi       - 402106178
    # AmirHossein Mirzaei       - 402106661
    # MohammadMahdi Rajabi      - 402106015
    # AmirHossein MohammadZadeh - 402106434
#==============================================
.ifndef DEBUG_S_
.eqv    DEBUG_S_, 1

.include "macros.S"
.include "strfuncs.S"
.include "iofuncs.S"

##################################### Debug Purposes #####################################
    # Debugging macros for printing the value of a register in hexadecimal format
    # Usage: debugd <register>
    # <register> : The register to be printed in hexadecimal format.
    # This macro prints the value of register in hexadecimal and decimal format.
.data
.align 8
debug_fmt:  .asciz "\033[0;91mDEBUG: \033[0;36m\0\0"
debug_fmt2: .asciz "\033[0m == \033[1;33m0x\0\0\0\0\0\0"
debug_fmt3: .asciz "\033[0;1m (\0\0\0"
debug_fmt4: .asciz ")\033[0m\n\0"
.text
.macro debugd reg
    .set _print_stream, STDERR
    print_rl debug_fmt
    print_lit "\reg"
    print_rl debug_fmt2
    push  %a10
    lgr   %a10, \reg
    srlg  %a10, %a10, 32
    print_num %a10, 16, 8
    pop   %a10
    push  %a10
    llgfr %a10, \reg
    print_num %a10, 16, 8
    pop   %a10
    print_rl debug_fmt3
    print_num \reg, 10, 1
    print_rl debug_fmt4
    .set _print_stream, STDOUT
.endm

.endif
