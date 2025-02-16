#==============================================
    # Project: S390x File Handling System
    # File Name: ansi.S
    # Description: This file contains ANSI escape sequences for colored output
    # Optional Project - CSL 1403-1 - Dr. Asadi
    # AmirMahdi Tahmasebi       - 402106178
    # AmirHossein Mirzaei       - 402106661
    # MohammadMahdi Rajabi      - 402106015
    # AmirHossein MohammadZadeh - 402106434
#==============================================
.ifndef ANSI_S_
.eqv    ANSI_S_, 1

.include "iofuncs.S"

.data
ANSI_RED_CODE:      .string "\033[0;31m"
ANSI_LRED_CODE:     .string "\033[0;91m"
ANSI_REDB_CODE:     .string "\033[1;31m"
ANSI_LREDB_CODE:    .string "\033[1;91m"
ANSI_GRN_CODE:      .string "\033[0;32m"
ANSI_LGRN_CODE:     .string "\033[0;92m"
ANSI_GRNB_CODE:     .string "\033[1;32m"
ANSI_LGRNB_CODE:    .string "\033[1;92m"
ANSI_YLW_CODE:      .string "\033[0;33m"
ANSI_LYLW_CODE:     .string "\033[0;93m"
ANSI_YLWB_CODE:     .string "\033[1;33m"
ANSI_LYLWB_CODE:    .string "\033[1;93m"
ANSI_BLU_CODE:      .string "\033[0;34m"
ANSI_LBLU_CODE:     .string "\033[0;94m"
ANSI_BLUB_CODE:     .string "\033[1;34m"
ANSI_LBLUB_CODE:    .string "\033[1;94m"
ANSI_MGN_CODE:      .string "\033[0;35m"
ANSI_LMGN_CODE:     .string "\033[0;95m"
ANSI_MGNB_CODE:     .string "\033[1;35m"
ANSI_LMGNB_CODE:    .string "\033[1;95m"
ANSI_CYN_CODE:      .string "\033[0;36m"
ANSI_LCYN_CODE:     .string "\033[0;96m"
ANSI_CYNB_CODE:     .string "\033[1;36m"
ANSI_LCYNB_CODE:    .string "\033[1;96m"
ANSI_RST_CODE:      .string "\033[0m"
ANSI_BOLD_CODE:     .string "\033[1m"
ANSI_UNDERL_CODE:   .string "\033[4m"

.text
.macro ANSI_RED      ;print_rl ANSI_RED_CODE;   .endm
.macro ANSI_LRED     ;print_rl ANSI_LRED_CODE;  .endm
.macro ANSI_REDB     ;print_rl ANSI_REDB_CODE;  .endm
.macro ANSI_LREDB    ;print_rl ANSI_LREDB_CODE; .endm
.macro ANSI_GRN      ;print_rl ANSI_GRN_CODE;   .endm
.macro ANSI_LGRN     ;print_rl ANSI_LGRN_CODE;  .endm
.macro ANSI_GRNB     ;print_rl ANSI_GRNB_CODE;  .endm
.macro ANSI_LGRNB    ;print_rl ANSI_LGRNB_CODE; .endm
.macro ANSI_YLW      ;print_rl ANSI_YLW_CODE;   .endm
.macro ANSI_LYLW     ;print_rl ANSI_LYLW_CODE;  .endm
.macro ANSI_YLWB     ;print_rl ANSI_YLWB_CODE;  .endm
.macro ANSI_LYLWB    ;print_rl ANSI_LYLWB_CODE; .endm
.macro ANSI_BLU      ;print_rl ANSI_BLU_CODE;   .endm
.macro ANSI_LBLU     ;print_rl ANSI_LBLU_CODE;  .endm
.macro ANSI_BLUB     ;print_rl ANSI_BLUB_CODE;  .endm
.macro ANSI_LBLUB    ;print_rl ANSI_LBLUB_CODE; .endm
.macro ANSI_MGN      ;print_rl ANSI_MGN_CODE;   .endm
.macro ANSI_LMGN     ;print_rl ANSI_LMGN_CODE;  .endm
.macro ANSI_MGNB     ;print_rl ANSI_MGNB_CODE;  .endm
.macro ANSI_LMGNB    ;print_rl ANSI_LMGNB_CODE; .endm
.macro ANSI_CYN      ;print_rl ANSI_CYN_CODE;   .endm
.macro ANSI_LCYN     ;print_rl ANSI_LCYN_CODE;  .endm
.macro ANSI_CYNB     ;print_rl ANSI_CYNB_CODE;  .endm
.macro ANSI_LCYNB    ;print_rl ANSI_LCYNB_CODE; .endm
.macro ANSI_RST      ;print_rl ANSI_RST_CODE;   .endm
.macro ANSI_BOLD     ;print_rl ANSI_BOLD_CODE;  .endm
.macro ANSI_UNDERL   ;print_rl ANSI_UNDERL_CODE;.endm

.endif
