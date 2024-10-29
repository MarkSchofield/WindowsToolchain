INCLUDE macamd64.inc

_TEXT SEGMENT READONLY 'CODE'

LEAF_ENTRY CallAsmCode, _TEXT
    mov rax, 42
    ret
LEAF_END CallAsmCode, _TEXT

_TEXT ENDS
END
