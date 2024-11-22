#----------------------------------------------------------------------------------------------------------------------
#
#----------------------------------------------------------------------------------------------------------------------
cmake_minimum_required(VERSION 3.20)

if(DEFINED ENV{CUDA_PATH})
    set(CMAKE_CUDA_COMPILER "$ENV{CUDA_PATH}/bin/nvcc.exe")
endif()

project(WindowsToolchainExample)

# Write properties that are influenced by the toolchain
#
message(STATUS "CMAKE_CROSSCOMPILING = ${CMAKE_CROSSCOMPILING}")
message(STATUS "CMAKE_SYSTEM_NAME = ${CMAKE_SYSTEM_NAME}")
message(STATUS "CMAKE_SYSTEM_PROCESSOR = ${CMAKE_SYSTEM_PROCESSOR}")
message(STATUS "MSVC_TOOLSET_VERSION = ${MSVC_TOOLSET_VERSION}")
message(STATUS "MSVC_VERSION = ${MSVC_VERSION}")

# Demonstrate that toolchain-related tooling can be found
#
find_program(NMAKE_PATH
    nmake.exe
)

message(STATUS "NMAKE_PATH = ${NMAKE_PATH}")

# Build a set of representative projects
#
add_compile_definitions(
    UNICODE
    _UNICODE
)

add_subdirectory(CommandLine)
add_subdirectory(CommandLineAsm)
add_subdirectory(CommandLineC)
add_subdirectory(SharedLibrary)
add_subdirectory(WindowsApplication)

if((CMAKE_CXX_COMPILER_ID STREQUAL "MSVC") AND (CMAKE_SYSTEM_PROCESSOR STREQUAL AMD64))
    if(DEFINED ENV{CUDA_PATH})
        add_subdirectory(CommandLineCuda)
    else()
        message(WARNING "NVIDIA Cuda Toolkit not found - please make sure that the 'CUDA_PATH' environment variable is set.")
    endif()
endif()

if((CMAKE_CXX_COMPILER_ID STREQUAL "MSVC") AND VS_EXPERIMENTAL_MODULE)
    if((CMAKE_SYSTEM_PROCESSOR STREQUAL AMD64) OR (CMAKE_SYSTEM_PROCESSOR STREQUAL AMD64) OR (CMAKE_SYSTEM_PROCESSOR STREQUAL X86))
        add_subdirectory(CommandLineModule)
    endif()
endif()
