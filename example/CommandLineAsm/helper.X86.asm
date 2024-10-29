INCLUDE callconv.inc

.386
.MODEL flat

_TEXT SEGMENT READONLY 'CODE'

_CallAsmCode PROC
    mov eax, DWORD PTR 42
    ret
_CallAsmCode ENDP

_TEXT ENDS
END
