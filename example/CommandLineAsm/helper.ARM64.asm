            AREA .text,CODE,READONLY
            EXPORT CallAsmCode

            ALIGN
CallAsmCode FUNCTION
            mov     lr, 42
            ret
            ENDFUNC

            END
