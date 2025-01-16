#==============================================
    # Project: S390x File Handling System
    # File Name: time.S
    # Description: This file contains the time to string conversion
    # Optional Project - CSL 1403-1 - Dr. Asadi
    # AmirMahdi Tahmasebi       - 402106178
    # AmirHossein Mirzaei       - 402106661
    # MohammadMahdi Rajabi      - 402106015
    # AmirHossein MohammadZadeh - 402106434
#==============================================
.ifndef TIME_S_
.eqv    TIME_S_, 1

.include "macros.S"
.include "strfuncs.S"

# Convert time to string
#   %r2: time in seconds
#   %r3: buffer to store the string
.text
time_to_string:
    enter 0, 6      # Save registers from r6 to r15
    lgr  %r9, %r2   # Save the time in r9
    lgfi %r6, 60    # %r6 = 60
    dsgr %r8, %r6   # %r9 = %r9 / 60, %r8 = %r9 % 60
    push %r8        # Push %r8 (seconds) to stack
    dsgr %r8, %r6   # %r9 = %r9 / 60, %r8 = %r9 % 60
    push %r8        # Push %r8 (minutes) to stack
    lgfi %r6, 24    # %r6 = 24
    dsgr %r8, %r6   # %r9 = %r9 / 24, %r8 = %r9 % 24
    lgr  %r11, %r8  # %r11 = %r8 (hours)
    pop  %r12       # Pop %r12 (minutes) from stack
    pop  %r13       # Pop %r13 (seconds) from stack
    ltoa   %r3, %r11, 10, 2  # Convert hours to string
    strlen %r8, %r3          # Get the length of the string
    lgfi   %r9, ':           # Load ':' to %r9
    stc    %r9, 0(%r8, %r3)  # Append ':' to the string
    lay    %r3, 1(%r8, %r3)  # Update %r3 to point to the end of the string
    ltoa   %r3, %r12, 10, 2  # Convert minutes to string
    strlen %r8, %r3          # Get the length of the string
    lgfi   %r9, ':           # Load ':' to %r9
    stc    %r9, 0(%r8, %r3)  # Append ':' to the string
    lay    %r3, 1(%r8, %r3)  # %r3 = %r3 + %r4
    ltoa   %r3, %r13, 10, 2  # Convert seconds to string
    leave 0, 6
    ret
.endif
