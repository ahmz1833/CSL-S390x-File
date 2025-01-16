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
################################################

# Begin of data section
.data
    .align 8
    input_path: .asciz "input.txt"
    .align 8
    output_path: .asciz "output.txt"
    .align 8
    buffer: .zero 1024                            # Buffer to store the content
    .align 8

##################################################

.macro command_not_recognized command
    .set _print_stream, STDERR
    ANSI_LRED
    print_lit "ahmzsh: Command Not Found: "
    ANSI_BOLD
    print_rl \command
    ANSI_RST
    putc_i '\n
    .set _print_stream, STDOUT
.endm

.macro print_prompt
    ANSI_CYN; print_lit "\n$>"
    ANSI_LGRN
    lay   %sp, -256(%sp)
    lay   %r2,    0(%sp)
    pwd   %r2, 256
    print %r2
    ANSI_RST
    lay   %sp,  256(%sp)
    print_lit "$ "
.endm

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
    strcheck  buffer, "exit",    .exit      # exit
    strncheck buffer, "help",    .help      # help ...
    strncheck buffer, "create ", .create    # create <filename>
    strncheck buffer, "rename ", .rename    # rename <oldname> <newname>
    strncheck buffer, "delete ", .delete    # delete <filename>
    strncheck buffer, "read ",   .read      # read <filename> [numberOfLines]
    strncheck buffer, "write ",  .write     # write <filename> "<content>"
    strncheck buffer, "cd ",     .cd        # cd <directory>
    strncheck buffer, "mkdir ",  .mkdir     # mkdir <directory>
    strcheck  buffer, "ls",      .ls        # ls
    strcheck  buffer, "time",    .time      # time
    command_not_recognized buffer           # Command not recognized
    j command_loop

#----------------------------------------------
.create:
    ANSI_MGN; print_lit "TODO\n"; ANSI_RST
    j command_loop
#----------------------------------------------
.rename:
    ANSI_MGN; print_lit "TODO\n"; ANSI_RST
    j command_loop
#----------------------------------------------
.delete:
    ANSI_MGN; print_lit "TODO\n"; ANSI_RST
    j command_loop
#----------------------------------------------
.read:
    ANSI_MGN; print_lit "TODO\n"; ANSI_RST
    j command_loop
#----------------------------------------------
.write:
    ANSI_MGN; print_lit "TODO\n"; ANSI_RST
    j command_loop
#----------------------------------------------
.cd:
    larl %r2, buffer
    lay  %r2, 3(%r2)
    sys_chdir
    clijne %r2, 0, .cd_error
    j command_loop
.cd_error:
    ANSI_LRED
    print_lit "ahmzsh: cd: "
    print_rl buffer
    print_lit ": No such file or directory\n"
    ANSI_RST
    j command_loop
#----------------------------------------------
.mkdir:
    ANSI_MGN; print_lit "TODO\n"; ANSI_RST
    j command_loop
#----------------------------------------------
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
    lg  %r6,  0(%r2, %sp)  # inode
    lh  %r7, 16(%r2, %sp)  # record length
    lay %r8, 18(%r2, %sp)  # file name
    agr %r2, %r7           # next record
    lgb %r9, -1(%r2, %sp)  # final byte is flags
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

    lay %sp, 4096(%sp)
    j command_loop
#----------------------------------------------
.time:
    ANSI_MGN; print_lit "TODO\n"; ANSI_RST
    j command_loop
#----------------------------------------------
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
    ANSI_YLW; print_lit "\tls\n"; ANSI_RST
    print_lit "\t\tList the contents of the current directory.\n"
    ANSI_YLW; print_lit "\ttime\n"; ANSI_RST
    print_lit "\t\tDisplay the current time.\n"
    j command_loop
#----------------------------------------------
.exit:
    leave 1
    xgr %r2, %r2
    ret
