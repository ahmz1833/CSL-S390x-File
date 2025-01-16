#==============================================
    # Project: S390x File Handling System
    # File Name: fileop.s
    # Description: This file contains the file operations functions and macros
    # Optional Project - CSL 1403-1 - Dr. Asadi
    # AmirMahdi Tahmasebi       - 402106178
    # AmirHossein Mirzaei       - 402106661
    # MohammadMahdi Rajabi      - 402106015
    # AmirHossein MohammadZadeh - 402106434
#==============================================
.ifndef FILEOP_S_
.eqv    FILEOP_S_, 1

.include "macros.S"

.eqv O_RDONLY,    00000000
.eqv O_WRONLY,    00000001
.eqv O_RDWR,      00000002
.eqv O_CREAT,     00000100
.eqv O_APPEND,    00002000
.eqv O_DIRECTORY, 00200000

.eqv DT_REG,      0x08
.eqv DT_DIR,      0x04

.macro pwd destbuf, bufsize=256
    push_multiple %r0, %r1, %r2, %r3, %r4, %r5
    lay  %r2, 0(\destbuf)
    lgfi %r3, \bufsize
    sys_getcwd
    pop_multiple %r5, %r4, %r3, %r2, %r1, %r0
.endm

.macro open_file pathreg, fdreg, flag
    push_multiple %r0, %r0, %r1, %r2, %r3, %r4, %r5
    lay  %r2, 0(\pathreg)
    lgfi %r3, \flag
    sys_open
    stg  %r2, 48(%sp)
    pop_multiple %r5, %r4, %r3, %r2, %r1, %r0, \fdreg
.endm

.endif
