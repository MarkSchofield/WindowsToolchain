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
add_subdirectory(CommandLineWinRT)
add_subdirectory(SharedLibrary)
add_subdirectory(WindowsApplication)
