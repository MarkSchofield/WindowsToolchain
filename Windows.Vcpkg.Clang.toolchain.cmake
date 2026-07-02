#----------------------------------------------------------------------------------------------------------------------
# MIT License
#
# Copyright (c) 2026 Mark Schofield
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
# This CMake toolchain file configures a vcpkg port build to use clang-cl from WindowsToolchain.
#
# The toolchain expects the following variables to be set by vcpkg:
#
# | CMake Variable | Description                                  |
# |----------------|----------------------------------------------|
# | _VCPKG_ROOT_DIR | The location of the root of the vcpkg clone. |
#
# Resources:
#   <https://learn.microsoft.com/en-us/vcpkg/users/triplets#vcpkg_chainload_toolchain_file>
#
cmake_minimum_required(VERSION 3.20)

include_guard()

list(APPEND CMAKE_TRY_COMPILE_PLATFORM_VARIABLES
    _VCPKG_ROOT_DIR
    Z_VCPKG_ROOT_DIR
    CMAKE_C_COMPILER_FRONTEND_VARIANT
    CMAKE_CXX_COMPILER_FRONTEND_VARIANT
)

if(NOT _VCPKG_ROOT_DIR)
    if(Z_VCPKG_ROOT_DIR)
        set(_VCPKG_ROOT_DIR "${Z_VCPKG_ROOT_DIR}")
    else()
        message(FATAL_ERROR "The '_VCPKG_ROOT_DIR' variable must be set by vcpkg.")
    endif()
endif()

set(CMAKE_C_COMPILER_FRONTEND_VARIANT MSVC)
set(CMAKE_CXX_COMPILER_FRONTEND_VARIANT MSVC)

include("${_VCPKG_ROOT_DIR}/scripts/toolchains/windows.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/Windows.Clang.toolchain.cmake")
