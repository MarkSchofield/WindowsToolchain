#----------------------------------------------------------------------------------------------------------------------
# MIT License
#
# Copyright (c) 2021 Mark Schofield
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#----------------------------------------------------------------------------------------------------------------------
include_guard()

include("${CMAKE_CURRENT_LIST_DIR}/ToolchainCommon.cmake")

#[[====================================================================================================================
    execute_powershell
    ------------------
    Executes the given PowerShell script.

        execute_powershell(
            <script>
            [OUTPUT_VARIABLE <variable name>]
        )
====================================================================================================================]]#
function(execute_powershell INLINE_SCRIPT)
    toolchain_find_powershell(POWERSHELL_PATH)

    set(OPTIONS)
    set(ONE_VALUE_KEYWORDS OUTPUT_VARIABLE)
    set(MULTI_VALUE_KEYWORDS)

    if(NOT INLINE_SCRIPT)
        message(FATAL_ERROR "No script was specified.")
    endif()

    cmake_parse_arguments(PARSE_ARGV 0 EXECUTE_POWERSHELL "${OPTIONS}" "${ONE_VALUE_KEYWORDS}" "${MULTI_VALUE_KEYWORDS}")

    set(POWERSHELL_COMMAND ${POWERSHELL_PATH} -ExecutionPolicy RemoteSigned -NoProfile -NonInteractive)
    list(APPEND POWERSHELL_COMMAND -Command ${INLINE_SCRIPT})

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
