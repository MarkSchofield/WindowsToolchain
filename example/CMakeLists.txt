#----------------------------------------------------------------------------------------------------------------------
#
#----------------------------------------------------------------------------------------------------------------------
cmake_minimum_required(VERSION 3.20)

project(WindowsToolchainExample)

add_compile_definitions(
    UNICODE
    _UNICODE
)

add_subdirectory(CommandLine)
add_subdirectory(CommandLineC)
add_subdirectory(SharedLibrary)
add_subdirectory(WindowsApplication)

if(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
    if((CMAKE_SYSTEM_PROCESSOR STREQUAL x64) OR (CMAKE_SYSTEM_PROCESSOR STREQUAL AMD64) OR (CMAKE_SYSTEM_PROCESSOR STREQUAL x86))
        add_subdirectory(CommandLineModule)
    endif()
endif()
