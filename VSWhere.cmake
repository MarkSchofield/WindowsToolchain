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
set(_ProgramFiles "ProgramFiles(x86)")
find_program(VSWHERE_PATH
    vswhere.exe
    HINTS
        "$ENV{${_ProgramFiles}}/Microsoft Visual Studio/Installer"
    REQUIRED
)

function(getVSWhereProperty VSWHERE_OUTPUT VSWHERE_PROPERTY VARIABLE_NAME)
    string(REGEX MATCH "${VSWHERE_PROPERTY}: [^\r\n]*" VSWHERE_VALUE "${VSWHERE_OUTPUT}")
    string(REPLACE "${VSWHERE_PROPERTY}: " "" VSWHERE_VALUE "${VSWHERE_VALUE}")
    set(${VARIABLE_NAME} "${VSWHERE_VALUE}" PARENT_SCOPE)
endfunction()

function(findVisualStudio)
    set(OPTIONS ";")
    set(ONE_VALUE_KEYWORDS ";")
    set(MULTI_VALUE_KEYWORDS "PROPERTIES")

    cmake_parse_arguments(PARSE_ARGV 0 FIND_VS "${OPTIONS}" "${ONE_VALUE_KEYWORDS}" "${MULTI_VALUE_KEYWORDS}")

    execute_process(
        COMMAND ${VSWHERE_PATH} -latest
        OUTPUT_VARIABLE VSWHERE_OUTPUT
        )

    while(FIND_VS_PROPERTIES)
        list(POP_FRONT FIND_VS_PROPERTIES VSWHERE_PROPERTY)
        list(POP_FRONT FIND_VS_PROPERTIES VSWHERE_CMAKE_VARIABLE)
        getVSWhereProperty(${VSWHERE_OUTPUT} ${VSWHERE_PROPERTY} VSWHERE_VALUE)
        set(${VSWHERE_CMAKE_VARIABLE} ${VSWHERE_VALUE} PARENT_SCOPE)
    endwhile()
endfunction()
