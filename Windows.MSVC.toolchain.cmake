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
# | CMake Variable                              | Description                                                                                           |
# |---------------------------------------------|-------------------------------------------------------------------------------------------------------|
# | CMAKE_SYSTEM_VERSION                        | The version of the operating system for which CMake is to build. Defaults to '10.0.19041.0'.          |
# | CMAKE_SYSTEM_PROCESSOR                      | The processor to compiler for. One of 'x86', 'x64', 'arm', 'arm64'. Defaults to 'x64'.                |
# | CMAKE_VS_PLATFORM_TOOLSET_VERSION           | The version of the MSVC toolset to use. For example, 14.29.30133. Defaults to the highest available.  |
# | CMAKE_VS_PLATFORM_TOOLSET_HOST_ARCHITECTURE | The architecture of the toolset to use. Defaults to 'x64'.                                            |
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
# | MSVC                                        | 1                                                                                                     |
# | MSVC_VERSION                                | The '<major><minor>' version of the C++ compiler being used. For example, '1929'                      |
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
set(MSVC 1)

if(NOT CMAKE_SYSTEM_VERSION)
    set(CMAKE_SYSTEM_VERSION 10.0.19041.0)
endif()

if(NOT CMAKE_SYSTEM_PROCESSOR)
    set(CMAKE_SYSTEM_PROCESSOR x64)
endif()

if(NOT CMAKE_VS_PLATFORM_TOOLSET_HOST_ARCHITECTURE)
    set(CMAKE_VS_PLATFORM_TOOLSET_HOST_ARCHITECTURE x64)
endif()

# Find Visual Studio
#
set(_ProgramFiles "ProgramFiles(x86)")
find_program(VSWHERE_PATH
    vswhere.exe
    HINTS
        "$ENV{${_ProgramFiles}}/Microsoft Visual Studio/Installer"
    REQUIRED
)

function(getVSWhereProperty VSWHERE_OUTPUT FIELD_NAME PROPERTY_NAME)
    string(REGEX MATCH "${FIELD_NAME}: [^\r\n]*" VS_WHERE_PROPERTY "${VSWHERE_OUTPUT}")
    string(REPLACE "${FIELD_NAME}: " "" VS_WHERE_PROPERTY "${VS_WHERE_PROPERTY}")
    set(${PROPERTY_NAME} "${VS_WHERE_PROPERTY}" PARENT_SCOPE)
endfunction()

execute_process(
    COMMAND "${VSWHERE_PATH}" -latest
    OUTPUT_VARIABLE VSWHERE_OUTPUT
)

getVSWhereProperty(${VSWHERE_OUTPUT} installationVersion VS_INSTALLATION_VERSION)
getVSWhereProperty(${VSWHERE_OUTPUT} installationPath VS_INSTALLATION_PATH)
cmake_path(NORMAL_PATH VS_INSTALLATION_PATH)

set(VS_MSVC_PATH "${VS_INSTALLATION_PATH}/VC/Tools/MSVC")

if(NOT VS_PLATFORM_TOOLSET_VERSION)
    file(GLOB VS_TOOLSET_VERSIONS RELATIVE ${VS_MSVC_PATH} ${VS_MSVC_PATH}/*)
    list(SORT VS_TOOLSET_VERSIONS COMPARE NATURAL ORDER DESCENDING)
    list(POP_FRONT VS_TOOLSET_VERSIONS VS_TOOLSET_VERSION)
endif()

set(VS_TOOLSET_PATH "${VS_INSTALLATION_PATH}/VC/Tools/MSVC/${VS_TOOLSET_VERSION}")

message(VERBOSE "VS_INSTALLATION_VERSION = ${VS_INSTALLATION_VERSION}")
message(VERBOSE "VS_INSTALLATION_PATH = ${VS_INSTALLATION_PATH}")

# Find the Windows Kits
#
if(NOT CMAKE_WINDOWS_KITS_10_DIR)
    get_filename_component(CMAKE_WINDOWS_KITS_10_DIR "[HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Microsoft SDKs\\Windows\\v10.0;InstallationFolder]" ABSOLUTE CACHE)
endif()

set(WINDOWS_KITS_PATH "${CMAKE_WINDOWS_KITS_10_DIR}")
set(WINDOWS_KITS_VERSION "${CMAKE_SYSTEM_VERSION}")
set(WINDOWS_KITS_BIN_PATH "${WINDOWS_KITS_PATH}/bin/${WINDOWS_KITS_VERSION}")
set(WINDOWS_KITS_INCLUDE_PATH "${WINDOWS_KITS_PATH}/include/${WINDOWS_KITS_VERSION}")
set(WINDOWS_KITS_LIB_PATH "${WINDOWS_KITS_PATH}/lib/${WINDOWS_KITS_VERSION}")

if(NOT EXISTS ${WINDOWS_KITS_BIN_PATH})
    message(FATAL_ERROR "Windows SDK ${WINDOWS_KITS_VERSION} cannot be found: Folder '${WINDOWS_KITS_BIN_PATH}' does not exist.")
endif()

if(NOT EXISTS ${WINDOWS_KITS_INCLUDE_PATH})
    message(FATAL_ERROR "Windows SDK ${WINDOWS_KITS_VERSION} cannot be found: Folder '${WINDOWS_KITS_INCLUDE_PATH}' does not exist.")
endif()

if(NOT EXISTS ${WINDOWS_KITS_LIB_PATH})
    message(FATAL_ERROR "Windows SDK ${WINDOWS_KITS_VERSION} cannot be found: Folder '${WINDOWS_KITS_LIB_PATH}' does not exist.")
endif()

# Set the tooling variables, include_directories and link_directories
#
function(getMsvcVersion COMPILER MSVC_VERSION_OUTPUT)
    execute_process(
        COMMAND "${COMPILER}" -Bv
        ERROR_VARIABLE COMPILER_OUTPUT
        OUTPUT_QUIET
    )

    if(COMPILER_OUTPUT MATCHES "Compiler Version (([0-9]+)\\.([0-9]+)\\.([0-9]+)(\\.([0-9]+))?)")
        set(COMPILER_VERSION ${CMAKE_MATCH_1})
        set(COMPILER_VERSION_MAJOR ${CMAKE_MATCH_2})
        set(COMPILER_VERSION_MINOR ${CMAKE_MATCH_3})
    endif()

    set(${MSVC_VERSION_OUTPUT} "${COMPILER_VERSION_MAJOR}${COMPILER_VERSION_MINOR}" PARENT_SCOPE)
endfunction()

set(CMAKE_VS_PLATFORM_TOOLSET_ARCHITECTURE ${CMAKE_SYSTEM_PROCESSOR})

set(CMAKE_CXX_COMPILER "${VS_TOOLSET_PATH}/bin/Host${CMAKE_VS_PLATFORM_TOOLSET_HOST_ARCHITECTURE}/${CMAKE_VS_PLATFORM_TOOLSET_ARCHITECTURE}/cl.exe")
set(CMAKE_CXX_COMPILER_ID "MSVC")
set(CMAKE_CXX_COMPILER_FRONTEND_VARIANT "MSVC")
set(MSVC_CXX_ARCHITECTURE_ID "${CMAKE_SYSTEM_PROCESSOR}")

set(CMAKE_C_COMPILER "${VS_TOOLSET_PATH}/bin/Host${CMAKE_VS_PLATFORM_TOOLSET_HOST_ARCHITECTURE}/${CMAKE_VS_PLATFORM_TOOLSET_ARCHITECTURE}/cl.exe")
set(CMAKE_C_COMPILER_ID "MSVC")
set(CMAKE_C_COMPILER_FRONTEND_VARIANT "MSVC")
set(MSVC_C_ARCHITECTURE_ID "${CMAKE_SYSTEM_PROCESSOR}")

if(CMAKE_SYSTEM_PROCESSOR STREQUAL arm)
    set(CMAKE_CXX_FLAGS_INIT "${CMAKE_CXX_FLAGS_INIT} /EHsc")
endif()

getMsvcVersion(${CMAKE_CXX_COMPILER} MSVC_VERSION)
if(NOT MSVC_VERSION)
    message(FATAL_ERROR "Unable to obtain the compiler version from: ${CMAKE_CXX_COMPILER}")
endif()

set(CMAKE_MT "${WINDOWS_KITS_BIN_PATH}/${CMAKE_VS_PLATFORM_TOOLSET_HOST_ARCHITECTURE}/mt.exe")
set(CMAKE_RC_COMPILER "${WINDOWS_KITS_BIN_PATH}/${CMAKE_VS_PLATFORM_TOOLSET_HOST_ARCHITECTURE}/rc.exe")
set(CMAKE_RC_FLAGS_INIT "/nologo")

# Compiler
include_directories(SYSTEM "${VS_TOOLSET_PATH}/ATLMFC/include")
include_directories(SYSTEM "${VS_TOOLSET_PATH}/include")
link_directories("${VS_TOOLSET_PATH}/ATLMFC/lib/${CMAKE_SYSTEM_PROCESSOR}")
link_directories("${VS_TOOLSET_PATH}/lib/${CMAKE_SYSTEM_PROCESSOR}")
link_directories("${VS_TOOLSET_PATH}/lib/x86/store/references")

# Windows SDK
include_directories(SYSTEM "${WINDOWS_KITS_INCLUDE_PATH}/ucrt")
include_directories(SYSTEM "${WINDOWS_KITS_INCLUDE_PATH}/shared")
include_directories(SYSTEM "${WINDOWS_KITS_INCLUDE_PATH}/um")
include_directories(SYSTEM "${WINDOWS_KITS_INCLUDE_PATH}/winrt")
include_directories(SYSTEM "${WINDOWS_KITS_INCLUDE_PATH}/cppwinrt")
link_directories("${WINDOWS_KITS_LIB_PATH}/ucrt/${CMAKE_SYSTEM_PROCESSOR}")
link_directories("${WINDOWS_KITS_LIB_PATH}/um/${CMAKE_SYSTEM_PROCESSOR}")
link_directories("${WINDOWS_KITS_PATH}/References/${CMAKE_SYSTEM_PROCESSOR}")
link_directories("${WINDOWS_KITS_PATH}/UnionMetadata/${CMAKE_SYSTEM_PROCESSOR}")
