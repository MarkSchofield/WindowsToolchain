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

find_program(NUGET_PATH
    nuget nuget.exe
    PATHS
        ${NUGET_PATH}
)

#[[====================================================================================================================
    install_nuget_package
    ---------------------
    Downloads a NuGet package.

        install_nuget_package(
            <package name>
            <package version>
            <variable name>
            [PRERELEASE <ON|OFF>]
            [PACKAGESAVEMODE <nuspec|nupkg|nuspec;nupkg>]
        )
====================================================================================================================]]#
function(install_nuget_package NUGET_PACKAGE_NAME NUGET_PACKAGE_VERSION VARIABLE_NAME)
    set(OPTIONS)
    set(ONE_VALUE_KEYWORDS PRERELEASE)
    set(MULTI_VALUE_KEYWORDS)

    cmake_parse_arguments(PARSE_ARGV 0 NUGET "${OPTIONS}" "${ONE_VALUE_KEYWORDS}" "${MULTI_VALUE_KEYWORDS}")

    if(NOT NUGET_PACKAGE_ROOT_PATH)
        set(NUGET_PACKAGE_ROOT_PATH ${CMAKE_BINARY_DIR}/__nuget)
    endif()

    set(NUGET_PACKAGE_PATH "${NUGET_PACKAGE_ROOT_PATH}/${NUGET_PACKAGE_NAME}.${NUGET_PACKAGE_VERSION}")

    if(NOT EXISTS "${NUGET_PACKAGE_PATH}")
        set(NUGET_COMMAND ${NUGET_PATH} install ${NUGET_PACKAGE_NAME})

        list(APPEND NUGET_COMMAND -OutputDirectory ${NUGET_PACKAGE_ROOT_PATH})
        list(APPEND NUGET_COMMAND -Version ${NUGET_PACKAGE_VERSION})

        if(NUGET_PRERELEASE)
            list(APPEND NUGET_COMMAND -Prerelease)
        endif()

        if(NUGET_PACKAGESAVEMODE)
            list(APPEND NUGET_COMMAND -PackageSaveMode ${NUGET_PACKAGESAVEMODE})
        endif()

        message(STATUS "Downloading ${NUGET_PACKAGE_NAME} ${NUGET_PACKAGE_VERSION}")
        message(VERBOSE "install_nuget_package: NUGET_COMMAND = ${NUGET_COMMAND}")

        execute_process(
            COMMAND ${NUGET_COMMAND}
            OUTPUT_VARIABLE NUGET_OUTPUT
            ERROR_VARIABLE NUGET_ERROR
            RESULT_VARIABLE NUGET_RESULT
            )

        message(VERBOSE "install_nuget_package: NUGET_OUTPUT = ${NUGET_OUTPUT}")
        if(NOT (NUGET_RESULT STREQUAL 0))
            message(FATAL_ERROR "install_nuget_package: Install failed with: ${NUGET_ERROR}")
        endif()
    endif()

    set(${VARIABLE_NAME} "${NUGET_PACKAGE_PATH}" PARENT_SCOPE)
endfunction()
