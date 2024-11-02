#----------------------------------------------------------------------------------------------------------------------
#
#----------------------------------------------------------------------------------------------------------------------
project(CommandLineAsm LANGUAGES CXX)

if((CMAKE_SYSTEM_PROCESSOR STREQUAL AMD64) OR (CMAKE_SYSTEM_PROCESSOR STREQUAL X86))
    enable_language(ASM_MASM)
elseif(CMAKE_SYSTEM_PROCESSOR STREQUAL ARM64)
    enable_language(ASM_MARMASM)
else()
    message(FATAL_ERROR "Unknown CMAKE_SYSTEM_PROCESSOR for ASM language.")
endif()

add_executable(CommandLineAsm
    main.cpp
    helper.${CMAKE_SYSTEM_PROCESSOR}.asm
)
