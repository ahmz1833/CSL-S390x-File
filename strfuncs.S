#==============================================
    # Project: S390x File Handling System
    # File Name: strfuncs.S
    # Description: This file contains functions and macros for string manipulation
    # Optional Project - CSL 1403-1 - Dr. Asadi
    # AmirMahdi Tahmasebi       - 402106178
    # AmirHossein Mirzaei       - 402106661
    # MohammadMahdi Rajabi      - 402106015
    # AmirHossein MohammadZadeh - 402106434
#==============================================
.ifndef STRFUNCS_S_
.eqv    STRFUNCS_S_, 1

.include "macros.S"

#----------------------------------------------------------------------
# Macro: strlen %dest, %basereg
# Description: Calculate the length of a string
# Note: basereg and dest should not be %r0 or the same
.macro strlen dest basereg
    push   %r0
    lgfi   \dest, -1
1:  lb     %r0,    1(\dest, \basereg)
    agfi   \dest,  1
    clijne %r0, 0, 1b
    pop    %r0
.endm

#----------------------------------------------------------------------
# Macro: ltoa %buf, %num, [base=10], [mindigits=1]
# Description: Convert a number to a string
# Note: num should not be in %r2
.macro ltoa buf, num, base=10, mindigits=1
    push_multiple %r0, %r1, %r2, %r3, %r4, %r5
    lgr  %r2, \buf
    lgr  %r3, \num
    lgfi %r4, \base
    lgfi %r5, \mindigits
    call _ltoa
    pop_multiple %r5, %r4, %r3, %r2, %r1, %r0
.endm

#----------------------------------------------------------------------
# Macro: atol %str, %dstreg, [base=10]
# Description: Convert a string to a number
.macro atol str, dstreg, base=10
    push_multiple %r0, %r0, %r1, %r2, %r3, %r4, %r5
    lgr  %r2, \str
    lgfi %r3, \base
    call _atol
    stg  %r2, 48(%sp)
    pop_multiple %r5, %r4, %r3, %r2, %r1, %r0, \dstreg
.endm

#----------------------------------------------------------------------
# Macro: strcheck %buf_lbl, "string", jmp_lbl
# Description: Compare a string with a literal string
# Note: This macro useful for checking commands with no arguments
.macro strcheck buf_lbl, str_lit, jmp_lbl
    .data; .align 8; 89:  .asciz "\str_lit"; .align 8; .text
    larl   %r2, 89b
    larl   %r3, \buf_lbl
    strlen %r4, %r2
    strlen %r5, %r3 
    cgr    %r5, %r4
    locgrh %r4, %r5
    call   _strncmp
    clije  %r2, 0, \jmp_lbl
.endm

#---------------------------------------------------------------------
# Macro: strncheck %buf_lbl, "string", jmp_lbl
# Description: Compare a string with a literal string (max n characters : strlen of literal string)
# Note: This macro useful for checking commands having arguments
.macro strncheck buf_lbl, str_lit, jmp_lbl
    .data; .align 8; 89:  .asciz "\str_lit"; .align 8; .text
    larl   %r2, 89b
    larl   %r3, \buf_lbl
    strlen %r4, %r2
    call   _strncmp
    clije  %r2, 0, \jmp_lbl
.endm

#----------------------------------------------------------------------
# Function: int32_t _strcmp(str1, str2, n)
# Description: Compare two strings up to n characters
_strncmp:
    enter 0,  6
    lgfi  %r7, 0
    lgfi  %r8, 0
    lgfi  %r9, 0
    ._sncmp_loop:
        crjhe %r9, %r4, ._sncmp_end            # If the counter is equal to the required digits, jump to end
        llc   %r7, 0(%r9, %r2)                  # Load the character of the first string to %r7
        llc   %r8, 0(%r9, %r3)                  # Load the character of the second string to %r8
        agfi  %r9, 1                            # Move the string pointer to the next position
        clrje %r7, %r8, ._sncmp_loop            # If characters are the same, continue
._sncmp_end:
    sgrk %r2, %r7, %r8
    leave 0,  6 
    ret

#----------------------------------------------------------------------
# Function: uint64_t _atol(str, base)
# Description: Convert a string to a number
# Note: not supported base > 10
.text
_atol:
    enter  0,    6
    lgfi   %r9,  0                           # The Number
    lgfi   %r10, 0                           # The Sign
    llc    %r7,  0(%r2)                      # Load the first character of the string to %r6
    clijne %r7,  '-, 20f                     # If the first character is '-', jump to 20
    lgfi   %r10, 1                           # Set the sign to negative
    agfi   %r2,  1                           # Move the string pointer to the next position
20: llc    %r7,  0(%r2)                      # Load the character of the string to %r6
    clije  %r7,  0, _a2l_end                 # If the character is null, jump to end
    msgr   %r9,  %r3                         # %r9 <- %r9 * base
    clijl  %r7, '0, _a2l_err                 # If the character isn't a digit, jump to err
    clijh  %r7, '9, _a2l_err                 # If the character isn't a digit, jump to err
    agfi   %r7, -'0                          # Convert the character to a number
    agr    %r9,  %r7                         # %r9 <- %r9 + %r7
    agfi   %r2,  1                           # Move the string pointer to the next position
    j      20b                               # Loop
_a2l_end:
    clije  %r10, 0, _a2l_pos                 # If the sign is negative, jump to neg
    lgfi   %r10, -1                          #|
    xgr    %r9,  %r10                        #| %r9 <- -%r9
    agfi   %r9,  1                           #|
_a2l_pos:
    lgr    %r2,  %r9                         # Return the number
    j      _a2l_ret
_a2l_err:
    xgr    %r2,  %r2                         # Error (return 0)
_a2l_ret:
    leave  0,   6
    ret

#----------------------------------------------------------------------
# Function: _ltoa(buf, num, base, min_digits)
# Description: Convert a number to desired base string representation
.text
_ltoa:
    enter  0,    6
    lgfi   %r6,  0                           # Load the buffer address to %r6
    lgr    %r9,  %r3                         # Load the number to %r9
    lgfi   %r7,  0                           # Initialize the counter to 0
    cgijhe %r9,  0, 10f                      # Jump to 1 if the number is positive
    lgfi   %r8,  '-                          # Load the negative sign to %r8
    stc    %r8,  0(%r2)                      # Store the negative sign in the buffer
    agfi   %r6,  1                           # Move the buffer pointer to the next position
    lgfi   %r8, -1                           #|
    xgr    %r9,  %r8                         #| %r9 <- -%r9
    agfi   %r9,  1                           #|
10: dsgr   %r8,  %r4                         # %r9:%r8 (%r8 is reminder) <- %r9 / base
    push   %r8                               # Push the reminder to stack
    agfi   %r7,  1                           # %r7 <- %r7 + 1
    cgijne %r9,  0,   10b                    # If %r9 != 0, jump to 1
11: crjhe  %r7,  %r5, 12f                    # Compare the number of digits with the required digits
    lgfi   %r8,  0                           #|
    push   %r8                               #| Push '0' to stack
    agfi   %r7,  1                           # %r7 <- %r7 + 1
    j      11b                               # Loop
12: pop    %r8                               # Pop the digit from stack
    cgijle %r8,  9,   13f                    # Check if the digit is greater than 9
    agfi   %r8, -10 + 'A - '0                # Convert the reminder to ASCII (HEX)
13: agfi   %r8,  '0                          # Convert the reminder to ASCII
    stc    %r8,  0(%r6, %r2)                 # Store the digit in the buffer
    agfi   %r6,  1                           # Move the buffer pointer to the next position
    agfi   %r7, -1                           # %r7 <- %r7 - 1  
    cgijne %r7,  0, 12b                      # If %r7 != 0, jump to 2
    lgfi   %r8,  0                           # Load the null terminator to %r8
    stc    %r8,  0(%r6, %r2)                 # Store the null terminator in the buffer
    leave  0,    6
    ret
#----------------------------------------------------------------------
.endif
