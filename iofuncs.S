#==============================================
    # Project: S390x File Handling System
    # File Name: iofuncs.s
    # Description: This file contains functions and macros for input/output
    # Optional Project - CSL 1403-1 - Dr. Asadi
    # AmirMahdi Tahmasebi       - 402106178
    # AmirHossein Mirzaei       - 402106661
    # MohammadMahdi Rajabi      - 402106015
    # AmirHossein MohammadZadeh - 402106434
#==============================================
.ifndef IOFUNCS_S_
.eqv    IOFUNCS_S_, 1

.include "macros.S"
.include "strfuncs.S"

.eqv STDIN,  0
.eqv STDOUT, 1
.eqv STDERR, 2

################################# Macros for output #################################
# fprint %fd_reg, %buf_reg
# fprint_lit %fd_reg, "LiteralString"
# fputc %fd_reg, %char_reg
# fputc_i %fd_reg, 'A
# fprint_num %fd_reg, %num, [base=10], [mindigits=1]
# print %buf_reg, [stream=STDOUT]
# print_lit "LiteralString", [stream=STDOUT]
# putc %char_reg, [stream=STDOUT]
# putc_i 'A, [stream=STDOUT]
# print_num %num, [base=10], [mindigits=1], [stream=STDOUT]
.set _print_stream, STDOUT

#----------------------------------------------------
# Macro: fprint %fdreg, %bufreg
# %fdreg is reg contains file descriptor and %bufreg is reg contains buffer address
# Note fd must not be in %r3
.macro fprint fd basereg _lfd_=lgr
    push_multiple %r0, %r1, %r2, %r3, %r4, %r5
    lgr    %r3, \basereg
    \_lfd_ %r2, \fd
    strlen %r4, %r3
    sys_write
    pop_multiple %r5, %r4, %r3, %r2, %r1, %r0
.endm

# Macro: print %bufreg, [stream=STDOUT]
# %bufreg is reg contains buffer address, stream is the file descriptor immediate
# Note: this like fprint(stream, bufreg)
.macro print basereg
    fprint _print_stream, \basereg, lgfi
.endm

#----------------------------------------------------
# Macro: fprint_rl %fdreg, buf_lbl
# %fdreg is reg contains file descriptor and buf_lbl is the label of the buffer
# Note fd must not be in %r3
.macro fprint_rl fd buf_lbl _lfd_=lgr
    push %r3
    larl %r3, \buf_lbl
    fprint \fd, %r3, \_lfd_
    pop %r3
.endm

# Macro: print_rl buf_lbl
# buf_lbl is the label of the buffer
# Note: stream defined via changing _print_stream
.macro print_rl buf_lbl
    fprint_rl _print_stream, \buf_lbl, lgfi
.endm

#----------------------------------------------------
# Macro: fprint_lit %fdreg, "LiteralString"
# %fdreg is reg contains file descriptor and "LiteralString" is the string
# Note fd must not be in %r3
.macro fprint_lit fd str:vararg
    .data; .align 8; 99:  .asciz ""\str""; .align 8; .text
    fprint_rl \fd, 99b
.endm

# Macro: print_lit "LiteralString"
# "LiteralString" is the string
# Note: stream defined via changing _print_stream
.macro print_lit str:vararg
    .data; .align 8; 98:  .asciz ""\str""; .align 8; .text
    print_rl 98b
.endm

#----------------------------------------------------
# Macro: fputc %fdreg, %charreg
# %fdreg is reg contains file descriptor, %charreg is reg contains character
.macro fputc fd charreg _lfd_=lgr
    push_multiple %r0, %r1, %r2, %r3, %r4, %r5
    lay %sp, -8(%sp)
    stc \charreg, 0(%sp)
    \_lfd_ %r2, \fd
    lay %r3, 0(%sp)
    lgfi %r4, 1
    sys_write
    lay %sp, 8(%sp)
    pop_multiple %r5, %r4, %r3, %r2, %r1, %r0
.endm

# Macro: putc %charreg, [stream=STDOUT]
# %charreg is reg contains character, stream is the file descriptor immediate
# Note: this like fputc(stream, charreg)
.macro putc charreg
    fputc _print_stream, \charreg, lgfi
.endm

# Macro: fputc_i %fdreg, 'A
# %fdreg is reg contains file descriptor, 'A' is the character immediate
# Note: fd must not be in %r4
.macro fputc_i fd chari _lfd_=lgr
    push %r4
    lgfi %r4, \chari
    fputc \fd, %r4, \_lfd_
    pop %r4
.endm

# Macro: putc_i 'A, [stream=STDOUT]
# 'A' is the character immediate, stream is the file descriptor immediate
# Note: this like fputc_i(stream, 'A')
.macro putc_i chari
    fputc_i _print_stream, \chari, lgfi
.endm

#----------------------------------------------------
# Macro: fprint_num %fdreg, %num, [base=10], [mindigits=1]
# %fdreg is reg contains file descriptor, %num is reg contains number
# base is the base of the number, mindigits is the minimum digits to print
# Note: fd must not be in %r3
.macro fprint_num fd num base=10 mindigits=1 _lfd_=lgr
    push_multiple %r0, %r1, %r2, %r3, %r4, %r5
    lay    %sp, -32(%sp)    # 0->7 : fd   |   8->31 : string buffer
    lgr    %r3, \num
    \_lfd_ %r2, \fd
    stg    %r2, 0(%sp)      # Save fd in stack
    lay    %r2, 8(%sp)
    lgfi   %r4, \base
    lgfi   %r5, \mindigits
    call   _ltoa
    lg     %r2, 0(%sp)      # Load fd from stack
    lay    %r3, 8(%sp)      # Load string buffer address
    fprint %r2, %r3
    lay    %sp, 32(%sp)
    pop_multiple %r5, %r4, %r3, %r2, %r1, %r0
.endm

# Macro: print_num %num, [base=10], [mindigits=1], [stream=STDOUT]
# %num is reg contains number, base is the base of the number, mindigits is the minimum digits to print
# stream is the file descriptor immediate
# Note: this like fprint_num(stream, num, base, mindigits)
.macro print_num num base=10 mindigits=1
    fprint_num _print_stream, \num, \base, \mindigits, lgfi
.endm

################################# Macros for input #################################
# fgetc %fd_reg, %dest
# fgets %fd_reg, %buf_reg, [size=1024]
# fgets_rl %fd_reg, buf_lbl, [size=1024]
# getc %dest
# gets %buf_reg, [size=1024]
# gets_rl buf_lbl, [size=1024]

#----------------------------------------------------
# Macro: fgetc %fdreg, %destreg
# %fdreg is reg contains file descriptor, %destreg is reg to store the character
.macro fgetc fd destreg _lfd_=lgr
    push_multiple %r0, %r0, %r1, %r2, %r3, %r4, %r5
    \_lfd_  %r2, \fd
    lay     %r3, 48+7(%sp)
    lgfi    %r4, 1
    sys_read
    agfi    %r2, -1
    cgfi    %r2, 0
    stocgne %r2, 48(%sp)
    pop_multiple %r5, %r4, %r3, %r2, %r1, %r0, \destreg
.endm

# Macro: getc %destreg
# %destreg is reg to store the character
.macro getc destreg
    fgetc STDIN, \destreg, lgfi
.endm

#----------------------------------------------------
# Macro: fgets %fdreg, %bufreg, [size=1024]
# %fdreg is reg contains file descriptor, %bufreg is reg contains buffer address, size is the size of the buffer
# Note: fd must not be in %r3
# Note: this trims the newline character
.macro fgets fd basereg size=1024 _lfd_=lgr
    push_multiple %r0, %r1, %r3, %r4, %r5
    lgr     %r3, \basereg
    \_lfd_  %r2, \fd
    lgfi    %r4, \size
    call    _fgets
    pop_multiple %r5, %r4, %r3, %r1, %r0
.endm

# Macro: fgets_rl %fdreg, buf_lbl, [size=1024]
# %fdreg is reg contains file descriptor, buf_lbl is the label of the buffer, size is the size of the buffer
# Note: this trims the newline character
.macro fgets_rl fd buf_lbl size=1024 _lfd_=lgr
    push_multiple %r0, %r1, %r3, %r4, %r5
    larl    %r3, \buf_lbl
    \_lfd_  %r2, \fd
    lgfi    %r4, \size
    call    _fgets
    pop_multiple %r5, %r4, %r3, %r1, %r0
.endm

# Macro: gets %bufreg, [size=1024]
# %bufreg is reg contains buffer address, size is the size of the buffer
# Note: like fgets(STDIN, bufreg, size)
# Note: this trims the newline character
.macro gets basereg size=1024
    fgets STDIN, \basereg, \size, lgfi
.endm

# Macro: gets_rl buf_lbl, [size=1024]
# buf_lbl is the label of the buffer, size is the size of the buffer
# Note: like fgets_rl(STDIN, buf_lbl, size)
.macro gets_rl buf_lbl size=1024
    fgets_rl STDIN, \buf_lbl, \size, lgfi
.endm

#---------------------------------------------------------
# Function: uint64_t _fgets(fd, buf, size)
# Description: Read a line from file descriptor fd to buffer buf with size size
# Note: the size is size with null terminator
# Note: This trims the newline character
_fgets:
    enter  0,   6
    lgfi   %r6, 1
._fgets_loop:
    cgrjhe %r6, %r4, ._fgets_end
    fgetc  %r2, %r7
    stcy   %r7, -1(%r6, %r3)
    agfi   %r6, 1
    clijne %r7, 10, ._fgets_loop
    agfi   %r6, -1
._fgets_end:
    agfi   %r6, -1
    lgfi   %r7, 0
    stc    %r7, 0(%r6, %r3)  # Null terminate the string
    lgr    %r2, %r6          # return length of line
    leave  0,   6
    ret

.endif
