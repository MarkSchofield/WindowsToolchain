
find_program(
    POWERSHELL_PATH
    NAMES
        pwsh.exe powershell.exe
    DOC "The path to PowerShell"
)

#[[====================================================================================================================
    execute_powershell
    -------------------------
    Executes the given PowerShell script.

        execute_powershell(
            <script>
            [OUTPUT_VARIABLE <variable name>]
        )
====================================================================================================================]]#
function(execute_powershell INLINE_SCRIPT)
    set(OPTIONS)
    set(ONE_VALUE_KEYWORDS OUTPUT_VARIABLE)
    set(MULTI_VALUE_KEYWORDS)

    if(NOT INLINE_SCRIPT)
        message(FATAL_ERROR "No script was specified.")
    endif()

    cmake_parse_arguments(PARSE_ARGV 0 EXECUTE_POWERSHELL "${OPTIONS}" "${ONE_VALUE_KEYWORDS}" "${MULTI_VALUE_KEYWORDS}")

    set(POWERSHELL_COMMAND ${POWERSHELL_PATH} -ExecutionPolicy RemoteSigned -NoProfile -NonInteractive)
    list(APPEND POWERSHELL_COMMAND  -Command ${INLINE_SCRIPT})

    message(VERBOSE "POWERSHELL_COMMAND = ${POWERSHELL_COMMAND}")
    execute_process(
        COMMAND ${POWERSHELL_COMMAND}
        OUTPUT_VARIABLE POWERSHELL_OUTPUT
        ERROR_VARIABLE POWERSHELL_ERROR
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    message(VERBOSE "POWERSHELL_OUTPUT = ${POWERSHELL_OUTPUT}")
    message(VERBOSE "POWERSHELL_ERROR = ${POWERSHELL_ERROR}")

    if(EXECUTE_POWERSHELL_OUTPUT_VARIABLE)
        set(${EXECUTE_POWERSHELL_OUTPUT_VARIABLE} "${POWERSHELL_OUTPUT}" PARENT_SCOPE)
    endif()
endfunction()
