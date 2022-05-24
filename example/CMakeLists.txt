#----------------------------------------------------------------------------------------------------------------------
#
#----------------------------------------------------------------------------------------------------------------------
cmake_minimum_required(VERSION 3.20)

project(WindowsToolchainExample)

include(${WINDOWS_TOOLCHAIN_DIR}/Support/CppWinRT.cmake)

add_cppwinrt_projection(CppWinRT
    INPUTS
        ${CMAKE_SYSTEM_VERSION}
    OPTIMIZE
)

add_compile_definitions(
    UNICODE
    _UNICODE
)

add_subdirectory(CommandLine)
add_subdirectory(SharedLibrary)
add_subdirectory(WindowsApplication)

if(NOT (CMAKE_CXX_COMPILER_ID STREQUAL Clang))
    add_subdirectory(CommandLineWinRT)
    add_subdirectory(RuntimeComponent)
endif()
