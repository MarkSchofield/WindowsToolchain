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
include_guard()

set(MIDL_1_0_PLATFORM_RESPONSE_FILE "${CMAKE_BINARY_DIR}/midl.1.0.platform.rsp")

#----------------------------------------------------------------------------------------------------------------------
#
#----------------------------------------------------------------------------------------------------------------------
function(enable_midl)
    cmake_language(EVAL CODE "cmake_language(DEFER CALL _process_target_midl_1_0 [[${ARGV0}]])")
endfunction()

#----------------------------------------------------------------------------------------------------------------------
#
#----------------------------------------------------------------------------------------------------------------------
function(_generateMidlOutput TARGET IDL_FILES MIDL_GENERATED_FILES)
    get_target_property(TARGET_SOURCE_DIR ${TARGET} SOURCE_DIR)
    get_target_property(TARGET_INCLUDE_DIRECTORIES ${TARGET} INCLUDE_DIRECTORIES)

    set(MIDL_COMMAND "")
    list(APPEND MIDL_COMMAND "\"${MIDL_COMPILER}\"")
    list(APPEND MIDL_COMMAND /nologo)
    list(APPEND MIDL_COMMAND /W3 /WX)
    list(APPEND MIDL_COMMAND /char signed)
    list(APPEND MIDL_COMMAND /env x64)
    list(APPEND MIDL_COMMAND /error all)
    list(APPEND MIDL_COMMAND /newtlb)
    list(APPEND MIDL_COMMAND /robust)
    list(APPEND MIDL_COMMAND /target NT60)
    list(APPEND MIDL_COMMAND /dlldata "DllData.c")
    list(APPEND MIDL_COMMAND /out "\"${CMAKE_CURRENT_BINARY_DIR}/Generated Files\"")

    list(TRANSFORM TARGET_INCLUDE_DIRECTORIES PREPEND "/I \"")
    list(TRANSFORM TARGET_INCLUDE_DIRECTORIES APPEND "\"")
    list(APPEND MIDL_COMMAND ${TARGET_INCLUDE_DIRECTORIES})

    # COMPILER_DIR
    get_filename_component(COMPILER_DIR ${CMAKE_C_COMPILER} DIRECTORY)

    set(GENERATED_FILES)
    list(APPEND GENERATED_FILES "${CMAKE_CURRENT_BINARY_DIR}/Generated Files/DllData.c")

    foreach(IDL_FILE IN LISTS IDL_FILES)
        get_filename_component(IDL_FILE_BASE ${IDL_FILE} NAME_WLE)

        set(MIDL_FILE_SPECIFIC_COMMAND ${MIDL_COMMAND})
        list(APPEND MIDL_FILE_SPECIFIC_COMMAND /h "${IDL_FILE_BASE}_i.h")
        list(APPEND MIDL_FILE_SPECIFIC_COMMAND /iid "${IDL_FILE_BASE}_i.c")
        list(APPEND MIDL_FILE_SPECIFIC_COMMAND /proxy "${IDL_FILE_BASE}_p.c")
        list(APPEND MIDL_FILE_SPECIFIC_COMMAND /tlb "${IDL_FILE_BASE}.tlb")
        list(APPEND MIDL_FILE_SPECIFIC_COMMAND ${IDL_FILE})

        set(MIDL_OUTPUT_FILES)
        list(APPEND MIDL_OUTPUT_FILES "${CMAKE_CURRENT_BINARY_DIR}/Generated Files/${IDL_FILE_BASE}_i.h")
        list(APPEND MIDL_OUTPUT_FILES "${CMAKE_CURRENT_BINARY_DIR}/Generated Files/${IDL_FILE_BASE}_i.c")
        list(APPEND MIDL_OUTPUT_FILES "${CMAKE_CURRENT_BINARY_DIR}/Generated Files/${IDL_FILE_BASE}_p.c")
        list(APPEND MIDL_OUTPUT_FILES "${CMAKE_CURRENT_BINARY_DIR}/Generated Files/${IDL_FILE_BASE}.tlb")

        set(MIDL_COMMAND_SCRIPT ${CMAKE_CURRENT_BINARY_DIR}/midl.1.0.${IDL_FILE_BASE}.cmd)
        list(JOIN MIDL_FILE_SPECIFIC_COMMAND " " MIDL_COMMAND_LINE)

        file(GENERATE OUTPUT ${MIDL_COMMAND_SCRIPT} CONTENT "\
@echo off
set PATH=%PATH%;${COMPILER_DIR}
${MIDL_COMMAND_LINE}
")

        add_custom_command(
            OUTPUT ${MIDL_OUTPUT_FILES} "${CMAKE_CURRENT_BINARY_DIR}/Generated Files/DllData.c"
            COMMAND ${MIDL_COMMAND_SCRIPT}
            MAIN_DEPENDENCY ${IDL_FILE}
            DEPENDS ${MIDL_COMMAND_SCRIPT}
            COMMENT "Processing ${IDL_FILE}"
            WORKING_DIRECTORY ${TARGET_SOURCE_DIR}
        )

        list(APPEND GENERATED_FILES ${MIDL_OUTPUT_FILES})
    endforeach()

    set(${MIDL_GENERATED_FILES} ${GENERATED_FILES} PARENT_SCOPE)
endfunction()

#----------------------------------------------------------------------------------------------------------------------
#
#----------------------------------------------------------------------------------------------------------------------
function(_process_target_midl_1_0 TARGET)
    get_target_property(TARGET_SOURCE_DIR ${TARGET} SOURCE_DIR)

    get_target_property(IDL_FILES ${TARGET} SOURCES)
    list(FILTER IDL_FILES INCLUDE REGEX "\.idl$")

    # Run MIDL on every '.idl' file specified to the target.
    _generateMidlOutput(${TARGET} ${IDL_FILES} MIDL_GENERATED_FILES)

    target_include_directories(${TARGET}
        PRIVATE
            "${TARGET_SOURCE_DIR}"
        PUBLIC
            "${CMAKE_CURRENT_BINARY_DIR}/Generated Files"
    )

    target_sources(${TARGET}
        PRIVATE
            ${MIDL_GENERATED_FILES}
    )
endfunction()
