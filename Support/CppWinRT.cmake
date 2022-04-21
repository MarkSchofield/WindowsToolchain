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

include("${CMAKE_CURRENT_LIST_DIR}/../NuGet.cmake")

#[[====================================================================================================================
    generate_winrt_projection
    -------------------------
    .

        generate_winrt_projection(
            INPUT <spec>+
            [EXECUTABLE_PATH <path>]
            [PCH_NAME <pch name>]
            [OPTIMIZE]
        )
====================================================================================================================]]#
function(generate_winrt_projection)
    set(OPTIONS OPTIMIZE)
    set(ONE_VALUE_KEYWORDS EXECUTABLE_PATH PCH_NAME)
    set(MULTI_VALUE_KEYWORDS INPUT)

    cmake_parse_arguments(PARSE_ARGV 0 CPPWINRT "${OPTIONS}" "${ONE_VALUE_KEYWORDS}" "${MULTI_VALUE_KEYWORDS}")

    if(NOT CPPWINRT_VERSION)
        set(CPPWINRT_VERSION "2.0.210930.14")
    endif()

    install_nuget_package(Microsoft.Windows.CppWinRT ${CPPWINRT_VERSION} NUGET_MICROSOFT_WINDOWS_CPPWINRT)

    if(NOT CPPWINRT_PROJECTION_ROOT_PATH)
        set(CPPWINRT_PROJECTION_ROOT_PATH ${CMAKE_BINARY_DIR}/__cppwinrt)
    endif()

    if(NOT EXISTS "${CPPWINRT_PROJECTION_ROOT_PATH}/winrt")
        if(NOT CPPWINRT_EXECUTABLE_PATH)
            set(CPPWINRT_EXECUTABLE_PATH ${NUGET_MICROSOFT_WINDOWS_CPPWINRT}/bin/cppwinrt.exe)
        endif()

        set(CPPWINRT_COMMAND ${CPPWINRT_EXECUTABLE_PATH})

        list(APPEND CPPWINRT_COMMAND -output ${CPPWINRT_PROJECTION_ROOT_PATH})
        list(APPEND CPPWINRT_COMMAND -input ${CPPWINRT_INPUT})

        if(CPPWINRT_PCH_NAME)
            list(APPEND CPPWINRT_COMMAND -pch ${CPPWINRT_PCH_NAME})
        endif()

        if(CPPWINRT_OPTIMIZE)
            list(APPEND CPPWINRT_COMMAND -optimize)
        endif()

        message(VERBOSE "Generating CppWinRT headers")
        message(VERBOSE "generate_winrt_projection: CPPWINRT_COMMAND = ${CPPWINRT_COMMAND}")

        execute_process(
            COMMAND ${CPPWINRT_COMMAND}
            OUTPUT_VARIABLE CPPWINRT_OUTPUT
            )

        message(VERBOSE "generate_winrt_projection: CPPWINRT_OUTPUT = ${CPPWINRT_OUTPUT}")
    endif()
endfunction()
