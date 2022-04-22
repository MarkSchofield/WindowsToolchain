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
cmake_minimum_required(VERSION 3.20)

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

    Note: Deprecated. Use 'add_cppwinrt_projection' instead.
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

#[[====================================================================================================================
    add_cppwinrt_projection
    -----------------------

    Creates a target representing a C++/WinRT projection

        add_cppwinrt_projection(<target>
            INPUTS <spec>+
            [VERSION <C++/WinRT version>]
            [PROJECTION_ROOT_PATH <path>]
            [OPTIMIZE]
        )

    The 'INPUTS' will be used to generate the projection, and can be any input to the cppwinrt tooling. If the INPUTS
    includes a path to a .winmd file, the file will be a dependency of the target that generates the projection.

    The VERSION parameter is optional, but if not specified the CPPWINRT_VERSION must be set.

    The PROJECTION_ROOT_PATH is optional. If not specified, and CPPWINRT_PROJECTION_ROOT_PATH is set, then the value of
    CPPWINRT_PROJECTION_ROOT_PATH will be used. If no value for PROJECTION_ROOT_PATH is specified, it will be defaulted
    to `${CMAKE_BINARY_DIR}/__cppwinrt`. Note: It is recommended that a custom value is specified outside of
    ${CMAKE_BINARY_DIR}, so that the same generated projection files can be used for all platforms and configurations.

====================================================================================================================]]#
function(add_cppwinrt_projection TARGET_NAME)
    set(OPTIONS OPTIMIZE)
    set(ONE_VALUE_KEYWORDS PROJECTION_ROOT_PATH VERSION PCH_NAME)
    set(MULTI_VALUE_KEYWORDS INPUTS)

    if(NOT TARGET_NAME)
        message(FATAL_ERROR "add_cppwinrt_projection called with incorrect arguments: a target name is required.")
    endif()

    cmake_parse_arguments(PARSE_ARGV 1 CPPWINRT "${OPTIONS}" "${ONE_VALUE_KEYWORDS}" "${MULTI_VALUE_KEYWORDS}")

    if(NOT CPPWINRT_VERSION)
        message(FATAL_ERROR "add_cppwinrt_projection: CPPWINRT_VERSION must be specified.")
    endif()

    if(NOT CPPWINRT_PROJECTION_ROOT_PATH)
        set(CPPWINRT_PROJECTION_ROOT_PATH ${CMAKE_BINARY_DIR}/__cppwinrt)
    endif()

    message(VERBOSE "add_cppwinrt_projection: CPPWINRT_VERSION = ${CPPWINRT_VERSION}")
    message(VERBOSE "add_cppwinrt_projection: CPPWINRT_PROJECTION_ROOT_PATH = ${CPPWINRT_PROJECTION_ROOT_PATH}")

    # Install the Microsoft.Windows.CppWinRT NuGet
    install_nuget_package(Microsoft.Windows.CppWinRT ${CPPWINRT_VERSION} NUGET_MICROSOFT_WINDOWS_CPPWINRT)

    # Build the command to generate the projection
    set(CPPWINRT_OUTPUT ${CPPWINRT_PROJECTION_ROOT_PATH}/${TARGET_NAME})
    set(CPPWINRT_OUTPUT_FILE ${CPPWINRT_OUTPUT}/output.log)
    set(CPPWINRT_EXECUTABLE_PATH ${NUGET_MICROSOFT_WINDOWS_CPPWINRT}/bin/cppwinrt.exe)

    set(CPPWINRT_COMMAND)
    list(APPEND CPPWINRT_COMMAND ${CPPWINRT_EXECUTABLE_PATH})
    list(APPEND CPPWINRT_COMMAND -output ${CPPWINRT_OUTPUT})
    list(APPEND CPPWINRT_COMMAND -input ${CPPWINRT_INPUTS})

    if(CPPWINRT_OPTIMIZE)
        list(APPEND CPPWINRT_COMMAND -optimize)
    endif()

    list(APPEND CPPWINRT_COMMAND > ${CPPWINRT_OUTPUT_FILE})

    # Check 'CPPWINRT_INPUTS', if the items are none of:
    #   * local
    #   * sdk[+]
    #   * 10.0.12345.0[+]
    # add it as a dependency.
    set(CPPWINRT_DEPENDS)
    foreach(CPPWINRT_INPUT IN LISTS CPPWINRT_INPUTS)
        if((CPPWINRT_INPUT STREQUAL "local") OR
            (CPPWINRT_INPUT MATCHES [[^sdk\+?$]]) OR
            (CPPWINRT_INPUT MATCHES [[^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+\+?$]]))
            message(VERBOSE "add_cppwinrt_projection: CPPWINRT_INPUT = ${CPPWINRT_INPUT}")
            continue()
        endif()
        message(VERBOSE "add_cppwinrt_projection: CPPWINRT_INPUT = ${CPPWINRT_INPUT} (dependency)")
        list(APPEND CPPWINRT_DEPENDS ${CPPWINRT_INPUT})
    endforeach()

    add_custom_command(
        OUTPUT ${CPPWINRT_OUTPUT_FILE}
        COMMAND ${CPPWINRT_COMMAND}
        DEPENDS ${CPPWINRT_DEPENDS}
        COMMENT "Generating C++/WinRT Projection - ${TARGET_NAME}"
        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    )

    add_library(${TARGET_NAME} INTERFACE
        ${CPPWINRT_OUTPUT_FILE}
    )

    target_include_directories(${TARGET_NAME} BEFORE
        INTERFACE
            ${CPPWINRT_OUTPUT}
    )

    target_link_libraries(${TARGET_NAME}
        INTERFACE
            RuntimeObject.lib
    )
endfunction()
