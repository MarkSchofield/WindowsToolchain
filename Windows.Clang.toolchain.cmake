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
# This CMake toolchain file configures a CMake, non-'Visual Studio Generator' build to use
# the Clang compilers and tools on Windows.
#
# The following variables can be used to configure the behavior of this toolchain file:
#
# | CMake Variable                              | Description                                                                                           |
# |---------------------------------------------|-------------------------------------------------------------------------------------------------------|
# | CMAKE_SYSTEM_VERSION                        | The version of the operating system for which CMake is to build. Defaults to '10.0.19041.0'.          |
# | CMAKE_SYSTEM_PROCESSOR                      | The processor to compiler for. One of 'x86', 'x64', 'arm', 'arm64'. Defaults to 'x64'.                |
# | CMAKE_WINDOWS_KITS_10_DIR                   | The location of the root of the Windows Kits 10 directory.                                            |
#
# The toolchain file will set the following variables:
#
# | CMake Variable                              | Description                                                                                           |
# |---------------------------------------------|-------------------------------------------------------------------------------------------------------|
# | CMAKE_C_COMPILER                            | The path to the C compiler to use.                                                                    |
# | CMAKE_CXX_COMPILER                          | The path to the C++ compiler to use.                                                                  |
# | CMAKE_MT                                    | The path to the 'mt.exe' tool to use.                                                                 |
# | CMAKE_RC_COMPILER                           | The path tp the 'rc.exe' tool to use.                                                                 |
# | CMAKE_SYSTEM_NAME                           | Windows                                                                                               |
# | WIN32                                       | 1                                                                                                     |
#
# Resources:
#   <https://cmake.org/cmake/help/latest/manual/cmake-toolchains.7.html>
#
cmake_minimum_required(VERSION 3.20)

set(UNUSED ${CMAKE_TOOLCHAIN_FILE})
set(CMAKE_SYSTEM_NAME Windows)
set(CMAKE_TRY_COMPILE_PLATFORM_VARIABLES "CMAKE_SYSTEM_PROCESSOR;CMAKE_CROSSCOMPILING")
set(CMAKE_CROSSCOMPILING TRUE)
set(WIN32 1)

if(NOT CMAKE_SYSTEM_PROCESSOR)
    set(CMAKE_SYSTEM_PROCESSOR x64)
endif()

include("${CMAKE_CURRENT_LIST_DIR}/VSWhere.cmake")

# Find Clang
#
findVisualStudio(
    REQUIRES
        Microsoft.VisualStudio.Component.VC.Llvm.Clang
    PROPERTIES
        installationVersion VS_INSTALLATION_VERSION
        installationPath VS_INSTALLATION_PATH
)

find_program(CMAKE_C_COMPILER
    clang.exe
    HINTS
        "${VS_INSTALLATION_PATH}/VC/Tools/Llvm/x64/bin"
        "$ENV{ProgramFiles}/LLVM/bin"
    REQUIRED
)

find_program(CMAKE_CXX_COMPILER
    clang++.exe
    HINTS
        "${VS_INSTALLATION_PATH}/VC/Tools/Llvm/x64/bin"
        "$ENV{ProgramFiles}/LLVM/bin"
    REQUIRED
)

set(CMAKE_CXX_COMPILER_ID "Clang")
set(CMAKE_CXX_COMPILER_FRONTEND_VARIANT "GNU")

set(CMAKE_C_COMPILER_ID "Clang")
set(CMAKE_C_COMPILER_FRONTEND_VARIANT "GNU")

if(CLANG_TIDY_CHECKS)
    get_filename_component(CLANG_PATH ${CMAKE_CXX_COMPILER} DIRECTORY CACHE)
    set(CMAKE_CXX_CLANG_TIDY "${CLANG_PATH}/clang-tidy.exe;-checks=${CLANG_TIDY_CHECKS}")
endif()

# Windows Kits
include("${CMAKE_CURRENT_LIST_DIR}/Windows.Kits.cmake")
