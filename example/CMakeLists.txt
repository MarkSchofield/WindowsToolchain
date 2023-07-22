#----------------------------------------------------------------------------------------------------------------------
#
#----------------------------------------------------------------------------------------------------------------------
cmake_minimum_required(VERSION 3.20)

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
add_subdirectory(CommandLineAsan)
add_subdirectory(SharedLibrary)
add_subdirectory(WindowsApplication)

if((CMAKE_CXX_COMPILER_ID STREQUAL "MSVC") AND VS_EXPERIMENTAL_MODULE)
    if((CMAKE_SYSTEM_PROCESSOR STREQUAL x64) OR (CMAKE_SYSTEM_PROCESSOR STREQUAL AMD64) OR (CMAKE_SYSTEM_PROCESSOR STREQUAL x86))
        add_subdirectory(CommandLineModule)
    endif()
endif()
