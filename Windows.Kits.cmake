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
if(NOT CMAKE_SYSTEM_VERSION)
    set(CMAKE_SYSTEM_VERSION 10.0.19041.0)
endif()

if(NOT CMAKE_VS_PLATFORM_TOOLSET_HOST_ARCHITECTURE)
    set(CMAKE_VS_PLATFORM_TOOLSET_HOST_ARCHITECTURE x64)
endif()

if(NOT CMAKE_WINDOWS_KITS_10_DIR)
    get_filename_component(CMAKE_WINDOWS_KITS_10_DIR "[HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Microsoft SDKs\\Windows\\v10.0;InstallationFolder]" ABSOLUTE CACHE)
endif()

set(WINDOWS_KITS_PATH "${CMAKE_WINDOWS_KITS_10_DIR}" CACHE PATH "" FORCE)
set(WINDOWS_KITS_VERSION "${CMAKE_SYSTEM_VERSION}" CACHE STRING "" FORCE)
set(WINDOWS_KITS_BIN_PATH "${WINDOWS_KITS_PATH}/bin/${WINDOWS_KITS_VERSION}" CACHE PATH "" FORCE)
set(WINDOWS_KITS_INCLUDE_PATH "${WINDOWS_KITS_PATH}/include/${WINDOWS_KITS_VERSION}" CACHE PATH "" FORCE)
set(WINDOWS_KITS_LIB_PATH "${WINDOWS_KITS_PATH}/lib/${WINDOWS_KITS_VERSION}" CACHE PATH "" FORCE)

if(NOT EXISTS ${WINDOWS_KITS_BIN_PATH})
    message(FATAL_ERROR "Windows SDK ${WINDOWS_KITS_VERSION} cannot be found: Folder '${WINDOWS_KITS_BIN_PATH}' does not exist.")
endif()

if(NOT EXISTS ${WINDOWS_KITS_INCLUDE_PATH})
    message(FATAL_ERROR "Windows SDK ${WINDOWS_KITS_VERSION} cannot be found: Folder '${WINDOWS_KITS_INCLUDE_PATH}' does not exist.")
endif()

if(NOT EXISTS ${WINDOWS_KITS_LIB_PATH})
    message(FATAL_ERROR "Windows SDK ${WINDOWS_KITS_VERSION} cannot be found: Folder '${WINDOWS_KITS_LIB_PATH}' does not exist.")
endif()

set(CMAKE_MT "${WINDOWS_KITS_BIN_PATH}/${CMAKE_VS_PLATFORM_TOOLSET_HOST_ARCHITECTURE}/mt.exe")
set(CMAKE_RC_COMPILER "${WINDOWS_KITS_BIN_PATH}/${CMAKE_VS_PLATFORM_TOOLSET_HOST_ARCHITECTURE}/rc.exe")
set(CMAKE_RC_FLAGS_INIT "/nologo")

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
