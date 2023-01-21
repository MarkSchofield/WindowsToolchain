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
    toolchain_ensure_nuget
    ----------------------

    Ensures that NuGet is available and the NUGET_PATH variables is set in the cache. The following steps will be
    taken:

        1. If `NUGET_PATH` is set, then that value will be used.
        2. If NuGet is found through `find_program`, that path will be used.
        3. NuGet will be downloaded - specified by `NUGET_VERSION` and `NUGET_HASH` - into the `TOOLCHAIN_TOOLS_PATH`
           and `NUGET_PATH` will be set to the download location. If `TOOLCHAIN_TOOLS_PATH` is not set, then it will
           default to `${CMAKE_BINARY_DIR}/__tools`.

    Note: Since `CMAKE_BINARY_DIR` is platform specific, the default download location will change by platform,
    resulting in the tool being downloaded once for each platform that is built. Setting
    `TOOLCHAIN_TOOLS_PATH` to a platform-independent path (e.g. relative to the root of the repository) will
    allow NuGet to be downloaded once for all platforms.
====================================================================================================================]]#
function(toolchain_ensure_nuget)
    find_program(NUGET_PATH
        NAMES nuget nuget.exe
    )

    # If NuGet isn't found, download it.
    #
    # NuGet.exe will be downloaded to `TOOLCHAIN_TOOLS_PATH`. If `TOOLCHAIN_TOOLS_PATH` is not set then it will be downloaded to '${CMAKE_BINARY_DIR}/__tools'.
    if(NUGET_PATH STREQUAL "NUGET_PATH-NOTFOUND")
        if(NOT NUGET_VERSION)
            set(NUGET_VERSION "6.1.0")
            set(NUGET_HASH "SHA256=432d322b16ffab3fed5d24ab7ea30ae10c555a00339a9bf53060aa4b2aee7925")
        else()
            if(NOT NUGET_HASH)
                message(FATAL_ERROR "NUGET_VERSION is set to ${NUGET_VERSION}. NUGET_HASH must be set if NUGET_VERSION is set.")
            endif()
        endif()

        if(NOT TOOLCHAIN_TOOLS_PATH)
            set(TOOLCHAIN_TOOLS_PATH "${CMAKE_BINARY_DIR}/__tools")
        endif()

        set(NUGET_PATH "${TOOLCHAIN_TOOLS_PATH}/nuget.exe" CACHE FILEPATH "The location of 'nuget.exe'" FORCE)

        toolchain_download_file(
            URL "https://dist.nuget.org/win-x86-commandline/v${NUGET_VERSION}/nuget.exe"
            PATH ${NUGET_PATH}
            EXPECTED_HASH ${NUGET_HASH}
        )
    endif()
endfunction()

#[[====================================================================================================================
    install_nuget_package
    ---------------------
    Downloads a NuGet package.

        install_nuget_package(
            <package name>
            <package version>
            <variable name>
            [PRERELEASE <ON|OFF>]
            [PACKAGESAVEMODE <nuspec|nupkg>]
        )

    The packages will be downloaded to `NUGET_PACKAGE_ROOT_PATH`. If `NUGET_PACKAGE_ROOT_PATH` is not set, then
    packages will be downloaded to `${CMAKE_BINARY_DIR}/__nuget`.

    Note: Since `CMAKE_BINARY_DIR` is platform specific, the default download location will change by platform,
    resulting in NuGet packages being downloaded once for each platform that is built. Setting
    `NUGET_PACKAGE_ROOT_PATH` to a platform-independent path (e.g. relative to the root of the repository) will
    allow NuGet packages to be downloaded once for all platforms.
====================================================================================================================]]#
function(install_nuget_package NUGET_PACKAGE_NAME NUGET_PACKAGE_VERSION VARIABLE_NAME)
    set(OPTIONS)
    set(ONE_VALUE_KEYWORDS PRERELEASE PACKAGESAVEMODE)
    set(MULTI_VALUE_KEYWORDS)

    cmake_parse_arguments(PARSE_ARGV 3 NUGET "${OPTIONS}" "${ONE_VALUE_KEYWORDS}" "${MULTI_VALUE_KEYWORDS}")

    if(NOT NUGET_PACKAGE_ROOT_PATH)
        set(NUGET_PACKAGE_ROOT_PATH ${CMAKE_BINARY_DIR}/__nuget)
    endif()

    set(NUGET_PACKAGE_PATH "${NUGET_PACKAGE_ROOT_PATH}/${NUGET_PACKAGE_NAME}.${NUGET_PACKAGE_VERSION}")

    if(NOT EXISTS "${NUGET_PACKAGE_PATH}")
        toolchain_ensure_nuget()

        set(NUGET_COMMAND ${NUGET_PATH} install ${NUGET_PACKAGE_NAME})

        list(APPEND NUGET_COMMAND -OutputDirectory ${NUGET_PACKAGE_ROOT_PATH})
        list(APPEND NUGET_COMMAND -Version ${NUGET_PACKAGE_VERSION})

        if(NUGET_PRERELEASE)
            list(APPEND NUGET_COMMAND -Prerelease)
        endif()

        if(DEFINED NUGET_PACKAGESAVEMODE)
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
