#----------------------------------------------------------------------------------------------------------------------
#
#----------------------------------------------------------------------------------------------------------------------
cmake_minimum_required(VERSION 3.20)

project(WindowsToolchainExample)

install_nuget_package(Microsoft.Windows.CppWinRT 2.0.210930.14 NUGET_MICROSOFT_WINDOWS_CPPWINRT)

generate_winrt_projection(
    EXECUTABLE_PATH ${NUGET_MICROSOFT_WINDOWS_CPPWINRT}/bin/cppwinrt.exe
    INPUT local
    OPTIMIZE
)

include_directories(BEFORE SYSTEM ${CPPWINRT_PROJECTION_ROOT_PATH})

add_compile_definitions(
    UNICODE
    _UNICODE
)

add_subdirectory(CommandLine)
add_subdirectory(SharedLibrary)
add_subdirectory(WindowsApplication)

if(NOT (CMAKE_CXX_COMPILER_ID STREQUAL Clang))
    add_subdirectory(CommandLineWinRT)
endif()
