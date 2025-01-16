#==============================================
    # Project: S390x File Handling System
    # File Name: macros.s
    # Description: This file contains the general macros used in the program
    # Optional Project - CSL 1403-1 - Dr. Asadi
    # AmirMahdi Tahmasebi       - 402106178
    # AmirHossein Mirzaei       - 402106661
    # MohammadMahdi Rajabi      - 402106015
    # AmirHossein MohammadZadeh - 402106434
#==============================================
.ifndef MACROS_S_
.eqv    MACROS_S_, 1

############## Macro: call <label> ##############
# <label> : The label of the function to be called.
# This macro call a function using calling convention of S390x architecture.
.macro call func
    lay   %sp, -160(%sp)                    # Allocate stack frame for calling function
    brasl %r14, \func                       # Call the function
    lay   %sp, 160(%sp)                     # Disallocate stack frame of called function
.endm

################# Macro: ret ####################
# This macro returns to the caller function.
.macro ret
    br %r14                                 # Return to the caller
.endm

######## Macro: enter [size=0] [first=6] ########
# [size=0] : The number of 64-bit local variables to be allocated in stack.
# [first=6] : The first register number to be saved in stack.
# This macro allocates space in stack for local variables,
# and saves the registers from r[x] to r[15] in stack frame allocated by caller
.macro enter size=0 first=6
    stmg %r\first, %sp, \first*8(%sp)
    lay  %sp, -\size*8(%sp)
.endm

####### Macro: leave [size=0] [first=6] ########
# [size=0] : The number of 64-bit local variables to be deallocated in stack.
# [first=6] : The first register number to be restored from stack.
# This macro deallocates space in stack for local variables,
# and restores the registers from r[x] to r[15] from stack frame
.macro leave size=0 first=6
    lay %sp, \size*8(%sp)
    lmg %r\first, %sp, \first*8(%sp)
.endm

############# Macro: push <srcreg> #############
# <srcreg> : The register to be pushed in stack.
# This macro pushes the value of register <srcreg> in stack.
.macro push srcreg
    lay %sp, -8(%sp)
    stg \srcreg, 0(%sp)
.endm

############ Macro: pop <dstreg> ###############
# <dstreg> : The register to be popped from stack.
# This macro pops the value from stack and stores in register <dstreg>.
.macro pop dstreg
    lg \dstreg, 0(%sp)
    lay %sp, 8(%sp)
.endm

.macro push_multiple regs:vararg
    .irp reg, \regs
    push \reg
    .endr
.endm

.macro pop_multiple regs:vararg
    .irp reg, \regs
    pop \reg
    .endr
.endm

########### Linux System Call Macros ###########
.macro sys_exit    ; svc 1   ; .endm   # void _exit(int status);
.macro sys_read    ; svc 3   ; .endm   # ssize_t read(int fd, void buf[.count], size_t count);
.macro sys_write   ; svc 4   ; .endm   # ssize_t write(int fd, const void buf[.count], size_t count);
.macro sys_open    ; svc 5   ; .endm   # int open(const char *filename, int flags, mode_t mode);
.macro sys_close   ; svc 6   ; .endm   # int close(int fd);
.macro sys_creat   ; svc 8   ; .endm   # int creat(const char *filename, mode_t mode);
.macro sys_unlink  ; svc 10  ; .endm   # int unlink(const char *pathname);
.macro sys_chdir   ; svc 12  ; .endm   # int chdir(const char *path);
.macro sys_rename  ; svc 38  ; .endm   # int rename(const char *oldpath, const char *newpath);
.macro sys_mkdir   ; svc 39  ; .endm   # int mkdir(const char *pathname, mode_t mode);
.macro sys_rmdir   ; svc 40  ; .endm   # int rmdir(const char *pathname);
.macro sys_getdents; svc 141 ; .endm   # int getdents(unsigned int fd, struct linux_dirent *dirp, unsigned int count);
.macro sys_getcwd  ; svc 183 ; .endm   # char *getcwd(char *buf, size_t size);

.endif
