#==============================================
    # Project: S390x File Handling System
    # File Name: main.S
    # Description: This file contains the main function of the program
    # Optional Project - CSL 1403-1 - Dr. Asadi
    # AmirMahdi Tahmasebi       - 402106178
    # AmirHossein Mirzaei       - 402106661
    # MohammadMahdi Rajabi      - 402106015
    # AmirHossein MohammadZadeh - 402106434
#==============================================
.include "macros.S"
.include "strfuncs.S"
.include "iofuncs.S"
.include "fileop.S"
.include "debug.S"
.include "ansi.S"
.include "time.S"
################################################

# Begin of data section
.data
    .align 8
    buffer: .zero 1024   # Buffer for reading the command
    .align 8

##################################################

.macro print_error command message
    .set _print_stream, STDERR
    ANSI_LRED
    print_lit "ahmzsh: "
    print_rl  \command
    print_lit ": "
    print_lit "\message"
    ANSI_RST
    putc_i '\n
    .set _print_stream, STDOUT
.endm

.macro print_prompt
    ANSI_CYN; print_lit "\n$>"
    ANSI_LGRN
    lay   %sp, -256(%sp)  # Allocate buffer for the current directory
    lay   %r2,    0(%sp)  # Buffer
    pwd   %r2,  256       # Get the current directory
    print %r2             # Print the current directory
    ANSI_RST
    lay   %sp,  256(%sp)  # Disallocate the buffer
    print_lit "$ "
.endm

##################################################

# Begin of text section
.text
.global _start
_start:
    call main
    sys_exit

##################################################
main:
    enter 1

command_loop:
    print_prompt                            # Print the prompt
    gets_rl   buffer, 1024                  # Read the command
    strcheck  buffer, "",        command_loop # If the command is empty, continue
    strcheck  buffer, "exit",    .exit      # exit
    strncheck buffer, "help",    .help      # help ...
    strncheck buffer, "create ", .create    # create <filename>
    strncheck buffer, "rename ", .rename    # rename <oldname> <newname>
    strncheck buffer, "delete ", .delete    # delete <filename>
    strncheck buffer, "read ",   .read      # read <filename> [numberOfLines]
    strncheck buffer, "write ",  .write     # write <filename> "<content>"
    strncheck buffer, "cd ",     .cd        # cd <directory>
    strncheck buffer, "mkdir ",  .mkdir     # mkdir <directory>
    strncheck buffer, "rmdir ",  .rmdir     # rmdir <directory>
    strcheck  buffer, "ls",      .ls        # ls
    strcheck  buffer, "time",    .time      # time
    print_error buffer, "Command not found" # Error message
    j command_loop

#=================================================================================
.create:
    larl %r2, buffer                                #|
    lay  %r2, 7(%r2)                                #| %r2 <- filename
    open_file %r2, %r2, O_CREAT + O_EXCL + O_WRONLY # Open the file
    cgijle %r2, 0, .create_error                    # If the file cannot be created, jump to error
    close_file %r2                                  # Close the file
    j command_loop
.create_error:
    print_error buffer, "Cannot create file"
    j command_loop
#=================================================================================
.rename:
    larl   %r2, buffer     #|
    lay    %r2, 7(%r2)     #| Move to the first character of the first string
    strchr %r3, %r2, 0x20  # Find the space character between the two strings
    clgije %r3, 0, .rename_syntax_error
    lgfi   %r4, 0          #|
    stc    %r4, 0(%r3)     #| Null terminate the first string
    lay    %r3, 1(%r3)     # Move to the next character
    sys_rename
    clgijne %r2, 0, .rename_error  # Compare Logical 64-bit with immediate (0) and jump if not equal
    j command_loop
.rename_syntax_error:
    print_error buffer, "Syntax error"
    j command_loop
.rename_error:
    print_error buffer, "Cannot rename file"
    j command_loop
#=================================================================================
.delete:
    larl %r2, buffer                #|
    lay  %r2, 7(%r2)                #| %r2 <- filename
    sys_unlink
    clgijne %r2, 0, .delete_error   # errorcode != 0 -> error
    j command_loop
.delete_error:
    print_error buffer, "Cannot delete file"
    j command_loop
#=================================================================================
.read:
    larl   %r2, buffer     #|
    lay    %r2, 5(%r2)     #| Move to the first character of the first string
    strchr %r3, %r2, 0x20  # Find the space character between the two strings
    clgije %r3, 0, .read_all
    lgfi   %r4, 0          #|
    stc    %r4, 0(%r3)     #| Null terminate the first string
    lay    %r3, 1(%r3)     # Move to the next character
    atol   %r3, %r3        # Convert the second string to integer
    j .read_read
.read_all:
    lgfi   %r3, 1000       # Read 1000 lines at most
.read_read:
    open_file %r2, %r0, O_RDONLY # Open the file (path in %r2, fd will be in %r0)
    cgijle  %r0, 0, .read_error  # If the file cannot be opened, jump to error
    lay    %sp, -4096(%sp)       # Allocate buffer for reading the file
    lay    %r1, 0(%sp)           # Buffer
.read_loop:
    stc    0, 0(%r1)             # Null terminate the buffer
    fgets  %r0, %r1, 4096        # Read a line from the file
    print  %r1                   # Print the line
    cgijl  %r2, 0, .read_done    # If numberOfLines is specified, check if we have read enough lines
    putc_i '\n
    agfi   %r3, -1               # Decrement the number of lines
    cgijh  %r3, 0, .read_loop    # If we have not read enough lines, continue reading
.read_done:
    lay    %sp,  4096(%sp)       # Disallocate the buffer
    close_file %r0               # Close the file
    j command_loop
.read_error:
    print_error buffer, "Cannot read file"
    j command_loop
#=================================================================================
.write:
    larl    %r2, buffer
    lay     %r2, 6(%r2)       # Move to the first character of the first string
    strchr  %r3, %r2, 0x20    # Find the space character between the two strings
    clije   %r3, 0, .write_syntax_error
    lgfi    %r4, 0            #|
    stc     %r4, 0(%r3)       #| Null terminate the first string
    lay     %r3, 1(%r3)       # Move to the next character
    llc     %r4, 0(%r3)       # Get the first character of the second string
    clijne  %r4, 0x22, .write_syntax_error
    lay     %r3, 1(%r3)       # Move to the next character
    strlen  %r4, %r3          # Get the length of the second string
    llc     %r5, -1(%r4, %r3) # Get the last character of the second string
    clijne  %r5, 0x22, .write_syntax_error
    lgfi    %r5, 0            #|
    stcy    %r5, -1(%r4, %r3) #| Null terminate (remove closing quote)
    # Convert "\n" to newline character
    convert_newline %r3
    # Open the file
    open_file %r2, %r0, O_APPEND + O_WRONLY + O_CREAT
    cgijle   %r0, 0, .write_error
    fprint  %r0, %r3
    fputc_i %r0 '\n
    close_file %r0
    j command_loop
.write_syntax_error:
    print_error buffer, "Syntax error"
    j command_loop
.write_error:
    print_error buffer, "Cannot write to file"
    j command_loop
#=================================================================================
.cd:
    larl %r2, buffer
    lay  %r2, 3(%r2)
    sys_chdir
    clgijne %r2, 0, .cd_error
    j command_loop
.cd_error:
    print_error buffer, "No such directory"
    j command_loop
#=================================================================================
.mkdir:
    larl %r2, buffer
    lay  %r2, 6(%r2)
    sys_mkdir
    clgijne %r2, 0, .mkdir_error
    j command_loop
.mkdir_error:
    print_error buffer, "Cannot create directory"
    j command_loop
#=================================================================================
.rmdir:
    larl %r2, buffer
    lay  %r2, 6(%r2)
    sys_rmdir
    clgijne %r2, 0, .rmdir_error
    j command_loop
.rmdir_error:
    print_error buffer, "Cannot remove directory"
    j command_loop
#=================================================================================
.ls:
    lay %sp, -256(%sp)
    lay %r2, 0(%sp)
    pwd %r2, 256
    open_file %r2, %r3, O_RDONLY + O_DIRECTORY
    lay %sp, 256(%sp)
    # Using getdents system call to read the directory entries
    lay  %sp, -4096(%sp)
    lgr  %r2, %r3     # fd
    lay  %r3, 0(%sp)  # buffer
    lgfi %r4, 4096    # count
    sys_getdents      # getdents(fd, buffer, count)
    lgr  %r4, %r2     # read count
    lgfi %r2, 0       # init byte index to 0
._ls_loop:
    lg   %r6,  0(%r2, %sp)  # inode
    lh   %r7, 16(%r2, %sp)  # record length
    lay  %r8, 18(%r2, %sp)  # file name
    agr  %r2, %r7           # next record
    lgb  %r9, -1(%r2, %sp)  # final byte is flags
    cije %r9, DT_DIR, ._ls_print_dir
    cije %r9, DT_REG, ._ls_print_file
    print %r8
    j ._ls_loop_next
._ls_print_file:
    ANSI_LYLW
    print %r8
    j ._ls_loop_next
._ls_print_dir:
    ANSI_LCYNB
    print %r8
    print_lit "/"
._ls_loop_next:
    ANSI_RST
    putc_i '\n
    cgrjl %r2, %r4, ._ls_loop
._ls_done:
    lay %sp, 4096(%sp)
    j command_loop
#=================================================================================
.time:
    lay   %sp, -24(%sp)  # Allocate for struct timeval tv
    lay   %r2, 0(%sp)    # tv
    lay   %r3, 16(%sp)   # tz
    sys_timeofd
    clgijne %r2, 0, .time_error
    lgf   %r3, 16(%sp)   # Minutes of GMT Offset
    msgfi %r3, 60        # Convert to seconds
    lg    %r2, 0(%sp)    # tv.tv_sec
    sgr   %r2, %r3       # Apply GMT Offset
    lay   %sp, 24(%sp)   # Disallocate the timeval struct
    ANSI_MGN
    print_lit "Current time: "
    ANSI_LMGNB
    lay   %sp, -256(%sp) # Allocate Buffer for time string
    lay   %r3, 0(%sp)    # Buffer
    call  time_to_string # Convert time to string
    lay   %r3, 0(%sp)    # Buffer
    print %r3            # Print the time string
    lay   %sp, 256(%sp)  # Disallocate the buffer
    ANSI_RST
    putc_i '\n
    j command_loop
.time_error:
    print_error buffer, "Cannot get time"
    j command_loop
#=================================================================================
.help:
    ANSI_CYN; print_lit "  Available commands:\n"; ANSI_RST
    ANSI_YLW; print_lit "\thelp\n"; ANSI_RST
    print_lit "\t\tDisplay this help message.\n"
    ANSI_YLW; print_lit "\texit\n"; ANSI_RST
    print_lit "\t\tExit the program.\n"
    ANSI_YLW; print_lit "\tcreate <filename>\n"; ANSI_RST
    print_lit "\t\tCreate a new file with the specified filename.\n"
    ANSI_YLW; print_lit "\trename <oldname> <newname>\n"; ANSI_RST
    print_lit "\t\tRename a file from oldname to newname.\n"
    ANSI_YLW; print_lit "\tdelete <filename>\n"; ANSI_RST
    print_lit "\t\tDelete the specified file.\n"
    ANSI_YLW; print_lit "\tread <filename> [numberOfLines]\n"; ANSI_RST
    print_lit "\t\tRead the specified number of lines from the file.\n"
    print_lit "\t\tIf numberOfLines is not specified, read the entire file.\n"
    ANSI_YLW; print_lit "\twrite <filename> \"<content>\"\n"; ANSI_RST
    print_lit "\t\tWrite the specified content to the file.\n"
    ANSI_YLW; print_lit "\tcd <directory>\n"; ANSI_RST
    print_lit "\t\tChange the current directory to the specified directory.\n"
    ANSI_YLW; print_lit "\tmkdir <directory>\n"; ANSI_RST
    print_lit "\t\tCreate a new directory with the specified name.\n"
    ANSI_YLW; print_lit "\trmdir <directory>\n"; ANSI_RST
    print_lit "\t\tRemove the specified directory.\n"
    ANSI_YLW; print_lit "\tls\n"; ANSI_RST
    print_lit "\t\tList the contents of the current directory.\n"
    ANSI_YLW; print_lit "\ttime\n"; ANSI_RST
    print_lit "\t\tDisplay the current time.\n"
    j command_loop
#=================================================================================
.exit:
    leave 1
    xgr %r2, %r2
    ret
