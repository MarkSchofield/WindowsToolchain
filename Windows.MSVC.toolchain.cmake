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
# the MSVC compilers and tools.
#
# The following variables can be used to configure the behavior of this toolchain file:
#
# | CMake Variable                              | Description                                                                                                              |
# |---------------------------------------------|--------------------------------------------------------------------------------------------------------------------------|
# | CMAKE_SYSTEM_VERSION                        | The version of the operating system for which CMake is to build. Defaults to the host version.                           |
# | CMAKE_SYSTEM_PROCESSOR                      | The processor to compiler for. One of 'x86', 'x64'/'AMD64', 'arm', 'arm64'. Defaults to ${CMAKE_HOST_SYSTEM_PROCESSOR}.  |
# | CMAKE_VS_VERSION_RANGE                      | A verson range for VS instances to find. For example, '[16.0,17.0)' will find versions '16.*'. Defaults to '[16.0,17.0)' |
# | CMAKE_VS_VERSION_PRERELEASE                 | Whether 'prerelease' versions of Visual Studio should be considered. Defaults to 'OFF'                                   |
# | CMAKE_VS_PRODUCTS                           | One or more Visual Studio Product IDs to consider. Defaults to '*'                                                       |
# | CMAKE_VS_PLATFORM_TOOLSET_VERSION           | The version of the MSVC toolset to use. For example, 14.29.30133. Defaults to the highest available.                     |
# | CMAKE_VS_PLATFORM_TOOLSET_HOST_ARCHITECTURE | The architecture of the toolset to use. Defaults to 'x64'.                                                               |
# | CMAKE_WINDOWS_KITS_10_DIR                   | The location of the root of the Windows Kits 10 directory.                                                               |
# | VS_EXPERIMENTAL_MODULE                      | Whether experimental module support should be enabled.
# | VS_USE_SPECTRE_MITIGATION_RUNTIME           | Whether the compiler should link with a runtime that uses 'Spectre' mitigations. Defaults to 'OFF'.                      |
# | NINJA_PATH                                  | The path to the ninja program. Defaults not set.                                                                         |
# | NUGET_PATH                                  | The path to the nuget program. Defaults not set.                                                                         |
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
# | MSVC                                        | 1                                                                                                     |
# | MSVC_VERSION                                | The '<major><minor>' version of the C++ compiler being used. For example, '1929'                      |
#
# Resources:
#   <https://cmake.org/cmake/help/latest/manual/cmake-toolchains.7.html>
#
cmake_minimum_required(VERSION 3.20)

include_guard()

if(NOT (CMAKE_HOST_SYSTEM_NAME STREQUAL Windows))
    return()
endif()

set(UNUSED ${CMAKE_TOOLCHAIN_FILE}) # Note: only to prevent cmake unused variable warninig
set(CMAKE_SYSTEM_NAME Windows)
set(CMAKE_TRY_COMPILE_PLATFORM_VARIABLES
    CMAKE_SYSTEM_PROCESSOR
    CMAKE_CROSSCOMPILING
    CMAKE_VS_VERSION_PRERELEASE
    CMAKE_VS_VERSION_RANGE
    CMAKE_VS_PRODUCTS
    CMAKE_VS_PLATFORM_TOOLSET_HOST_ARCHITECTURE
    VS_INSTALLATION_VERSION
    VS_INSTALLATION_PATH
)
set(CMAKE_CROSSCOMPILING TRUE)
set(WIN32 1)
set(MSVC 1)

include("${CMAKE_CURRENT_LIST_DIR}/Ninja.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/NuGet.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/VSWhere.cmake")

if(NOT CMAKE_SYSTEM_PROCESSOR)
    set(CMAKE_SYSTEM_PROCESSOR ${CMAKE_HOST_SYSTEM_PROCESSOR})
endif()

if(NOT CMAKE_VS_VERSION_RANGE)
    set(CMAKE_VS_VERSION_RANGE "[16.0,)")
endif()

if(NOT CMAKE_VS_VERSION_PRERELEASE)
    set(CMAKE_VS_VERSION_PRERELEASE OFF)
endif()

if(NOT CMAKE_VS_PRODUCTS)
    set(CMAKE_VS_PRODUCTS "*")
endif()

if(NOT CMAKE_VS_PLATFORM_TOOLSET_HOST_ARCHITECTURE)
    set(CMAKE_VS_PLATFORM_TOOLSET_HOST_ARCHITECTURE x64)
endif()

if(NOT VS_USE_SPECTRE_MITIGATION_RUNTIME)
    set(VS_USE_SPECTRE_MITIGATION_RUNTIME OFF)
endif()

# Find Visual Studio
#
findVisualStudio(
    VERSION ${CMAKE_VS_VERSION_RANGE}
    PRERELEASE ${CMAKE_VS_VERSION_PRERELEASE}
    PRODUCTS ${CMAKE_VS_PRODUCTS}
    PROPERTIES
        installationVersion VS_INSTALLATION_VERSION
        installationPath VS_INSTALLATION_PATH
)

message(VERBOSE "VS_INSTALLATION_VERSION = ${VS_INSTALLATION_VERSION}")
message(VERBOSE "VS_INSTALLATION_PATH = ${VS_INSTALLATION_PATH}")

if(NOT VS_INSTALLATION_PATH)
    message(FATAL_ERROR "Unable to find Visual Studio")
endif()

cmake_path(NORMAL_PATH VS_INSTALLATION_PATH)

set(VS_MSVC_PATH "${VS_INSTALLATION_PATH}/VC/Tools/MSVC")

if(NOT VS_PLATFORM_TOOLSET_VERSION)
    file(GLOB VS_TOOLSET_VERSIONS RELATIVE ${VS_MSVC_PATH} ${VS_MSVC_PATH}/*)
    list(SORT VS_TOOLSET_VERSIONS COMPARE NATURAL ORDER DESCENDING)
    list(POP_FRONT VS_TOOLSET_VERSIONS VS_TOOLSET_VERSION)
endif()

set(VS_TOOLSET_PATH "${VS_INSTALLATION_PATH}/VC/Tools/MSVC/${VS_TOOLSET_VERSION}")

# Set the tooling variables, include_directories and link_directories
#
function(getMsvcVersion COMPILER MSVC_VERSION_OUTPUT)
    execute_process(
        COMMAND "${COMPILER}" -Bv
        ERROR_VARIABLE COMPILER_OUTPUT
        OUTPUT_QUIET
    )

    if(COMPILER_OUTPUT MATCHES "cl.exe.*(([0-9]+)\\.([0-9]+)\\.([0-9]+)(\\.([0-9]+))?)")
        set(COMPILER_VERSION ${CMAKE_MATCH_1})
        set(COMPILER_VERSION_MAJOR ${CMAKE_MATCH_2})
        set(COMPILER_VERSION_MINOR ${CMAKE_MATCH_3})
    endif()

    set(${MSVC_VERSION_OUTPUT} "${COMPILER_VERSION_MAJOR}${COMPILER_VERSION_MINOR}" PARENT_SCOPE)
endfunction()

# Map CMAKE_SYSTEM_PROCESSOR values to CMAKE_VS_PLATFORM_TOOLSET_ARCHITECTURE that identifies the tools that should
# be used to produce code for the CMAKE_SYSTEM_PROCESSOR.
if((CMAKE_SYSTEM_PROCESSOR STREQUAL AMD64) OR (CMAKE_SYSTEM_PROCESSOR STREQUAL x64))
    set(CMAKE_VS_PLATFORM_TOOLSET_ARCHITECTURE x64)
elseif((CMAKE_SYSTEM_PROCESSOR STREQUAL arm)
    OR (CMAKE_SYSTEM_PROCESSOR STREQUAL arm64)
    OR (CMAKE_SYSTEM_PROCESSOR STREQUAL x86))
    set(CMAKE_VS_PLATFORM_TOOLSET_ARCHITECTURE ${CMAKE_SYSTEM_PROCESSOR})
else()
    message(FATAL_ERROR "Unable identify compiler architecture for CMAKE_SYSTEM_PROCESSOR ${CMAKE_SYSTEM_PROCESSOR}")
endif()

set(CMAKE_CXX_COMPILER "${VS_TOOLSET_PATH}/bin/Host${CMAKE_VS_PLATFORM_TOOLSET_HOST_ARCHITECTURE}/${CMAKE_VS_PLATFORM_TOOLSET_ARCHITECTURE}/cl.exe")
set(CMAKE_C_COMPILER "${VS_TOOLSET_PATH}/bin/Host${CMAKE_VS_PLATFORM_TOOLSET_HOST_ARCHITECTURE}/${CMAKE_VS_PLATFORM_TOOLSET_ARCHITECTURE}/cl.exe")

if(CMAKE_SYSTEM_PROCESSOR STREQUAL arm)
    set(CMAKE_CXX_FLAGS_INIT "${CMAKE_CXX_FLAGS_INIT} /EHsc")
endif()

getMsvcVersion(${CMAKE_CXX_COMPILER} MSVC_VERSION)
if(NOT MSVC_VERSION)
    message(FATAL_ERROR "Unable to obtain the compiler version from: ${CMAKE_CXX_COMPILER}")
endif()

# Compiler
include_directories(SYSTEM "${VS_TOOLSET_PATH}/ATLMFC/include")
include_directories(SYSTEM "${VS_TOOLSET_PATH}/include")

if(VS_USE_SPECTRE_MITIGATION_RUNTIME)
    set(TOOLCHAIN_SPECTRE_TOKEN "/spectre")
else()
    set(TOOLCHAIN_SPECTRE_TOKEN)
endif()

link_directories("${VS_TOOLSET_PATH}/ATLMFC/lib${TOOLCHAIN_SPECTRE_TOKEN}/${CMAKE_VS_PLATFORM_TOOLSET_ARCHITECTURE}")
link_directories("${VS_TOOLSET_PATH}/lib${TOOLCHAIN_SPECTRE_TOKEN}/${CMAKE_VS_PLATFORM_TOOLSET_ARCHITECTURE}")

link_directories("${VS_TOOLSET_PATH}/lib/x86/store/references")

# Module support
if(VS_EXPERIMENTAL_MODULE)
    add_compile_options(/experimental:module)
    add_compile_options(/stdIfcDir "${VS_TOOLSET_PATH}/ifc/${CMAKE_VS_PLATFORM_TOOLSET_ARCHITECTURE}")
endif()

# Windows Kits
include("${CMAKE_CURRENT_LIST_DIR}/Windows.Kits.cmake")

set(TOOLCHAIN_SPECTRE_TOKEN)
