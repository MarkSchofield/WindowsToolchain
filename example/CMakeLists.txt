#----------------------------------------------------------------------------------------------------------------------
#
#----------------------------------------------------------------------------------------------------------------------
cmake_minimum_required(VERSION 3.20)

if(DEFINED ENV{CUDA_PATH})
    set(CMAKE_CUDA_COMPILER "$ENV{CUDA_PATH}/bin/nvcc.exe")
endif()

project(WindowsToolchainExample)

if(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
    message(STATUS "MSVC_VERSION = ${MSVC_VERSION}")
    message(STATUS "MSVC_TOOLSET_VERSION = ${MSVC_TOOLSET_VERSION}")
endif()

add_compile_definitions(
    UNICODE
    _UNICODE
)

add_subdirectory(CommandLine)
add_subdirectory(CommandLineC)
add_subdirectory(SharedLibrary)
add_subdirectory(WindowsApplication)

if(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
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
