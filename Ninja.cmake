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
#
# Downloads the Ninja Build executable from within a toolchain.
#
# The following variables can be used to configure the behavior of this file:
#
# | CMake Variable          | Description                                                                                                               |
# |-------------------------|---------------------------------------------------------------------------------------------------------------------------|
# | NINJA_VERSION           | The version of Ninja to download - if it can't be found. Defaults to 1.11.0.                                              |
# | NINJA_ARCHIVE_HASH      | The hash of the Ninja archive, following the format of `string(<HASH>`. Defaults to the hash of the Ninja 1.10.2 archive. |
# | TOOLCHAIN_TOOLS_PATH    | The path to download tools to. If not set, then tools will not be downloaded.                                             |
# | NINJA_DIR               | The directory where ninja may found. Defaults not set.                                                                    |
include_guard()

if((NOT (CMAKE_GENERATOR STREQUAL Ninja)) AND (NOT (CMAKE_GENERATOR STREQUAL "Ninja Multi-Config")))
    return()
endif()

if(NOT NINJA_VERSION)
    set(NINJA_VERSION "1.11.0")
    set(NINJA_ARCHIVE_HASH "SHA256=d0ee3da143211aa447e750085876c9b9d7bcdd637ab5b2c5b41349c617f22f3b")
else()
    if(NOT NINJA_ARCHIVE_HASH)
        message(FATAL_ERROR "NINJA_VERSION is set to ${NINJA_VERSION}. NINJA_ARCHIVE_HASH must be set if NINJA_VERSION is set.")
    endif()
endif()

find_program(NINJA_PATH
    NAMES ninja ninja.exe
    HINTS ${NINJA_DIR}
)

include("${CMAKE_CURRENT_LIST_DIR}/ToolchainCommon.cmake")

# If:
#   1. Ninja can't be found
#   2. TOOLCHAIN_TOOLS_PATH is set
#   3. CMAKE_MAKE_PROGRAM isn't specified, or it was specified and equal to where it would be downloaded to.
#
# Download and unpack ninja to TOOLCHAIN_TOOLS_PATH and set CMAKE_MAKE_PROGRAM to point to it.
if((NINJA_PATH STREQUAL "NINJA_PATH-NOTFOUND") AND TOOLCHAIN_TOOLS_PATH)
    if(NOT IS_ABSOLUTE ${TOOLCHAIN_TOOLS_PATH})
        message(WARNING "TOOLCHAIN_TOOLS_PATH is not an absolute path. This might result in an inconsistent behavior.")
    endif()

    set(NINJA_ARCHIVE_PATH "${TOOLCHAIN_TOOLS_PATH}/ninja.zip")
    set(NINJA_PATH "${TOOLCHAIN_TOOLS_PATH}/ninja.exe")

    if ((NOT CMAKE_MAKE_PROGRAM) OR (CMAKE_MAKE_PROGRAM STREQUAL NINJA_PATH))
        toolchain_download_file(
            URL "https://github.com/ninja-build/ninja/releases/download/v${NINJA_VERSION}/ninja-win.zip"
            PATH ${NINJA_ARCHIVE_PATH}
            EXPECTED_HASH ${NINJA_ARCHIVE_HASH}
        )

        if(${NINJA_ARCHIVE_PATH} IS_NEWER_THAN ${NINJA_PATH})
            file(ARCHIVE_EXTRACT
                INPUT ${NINJA_ARCHIVE_PATH}
                DESTINATION ${TOOLCHAIN_TOOLS_PATH}
            )
            file(TOUCH_NOCREATE ${NINJA_PATH})
        endif()

        set(CMAKE_MAKE_PROGRAM ${NINJA_PATH} CACHE FILEPATH "" FORCE)
    endif()
endif()
