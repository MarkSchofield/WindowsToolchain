#----------------------------------------------------------------------------------------------------------------------
#
#----------------------------------------------------------------------------------------------------------------------
cmake_minimum_required(VERSION 3.20)

project(WindowsToolchainExample)

include(CppWinRT)

generate_winrt_projection(
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
    add_subdirectory(RuntimeComponent)
endif()
