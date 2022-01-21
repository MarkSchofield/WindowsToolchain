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

include("${CMAKE_CURRENT_LIST_DIR}/../PowerShell.cmake")

set(MIDL_PLATFORM_RESPONSE_FILE "${CMAKE_BINARY_DIR}/midl.platform.rsp")
set(MDMERGE_PLATFORM_RESPONSE_FILE "${CMAKE_BINARY_DIR}/mdmerge.platform.rsp")

# Read the PLATFORM_REFERENCES from the WINDOWS_KITS_PLATFORM_PATH file.
execute_powershell("
[xml]$Platform = Get-Content \"${WINDOWS_KITS_PLATFORM_PATH}\"
$Platform.ApplicationPlatform.ContainedApiContracts.ApiContract |
    ForEach-Object { $_.name, $_.version }
"
    OUTPUT_VARIABLE PLATFORM_REFERENCES)
string(REPLACE "\n" ";" PLATFORM_REFERENCES ${PLATFORM_REFERENCES})

while(PLATFORM_REFERENCES)
    list(POP_FRONT PLATFORM_REFERENCES PLATFORM_REFERENCE_NAME)
    list(POP_FRONT PLATFORM_REFERENCES PLATFORM_REFERENCE_VERSION)

    if(PLATFORM_REFERENCE_NAME STREQUAL Windows.Foundation.FoundationContract)
        list(APPEND PLATFORM_METADATA_PATHS "${WINDOWS_KITS_REFERENCES_PATH}/${CMAKE_SYSTEM_VERSION}/${PLATFORM_REFERENCE_NAME}/${PLATFORM_REFERENCE_VERSION}")
    endif()

    list(APPEND PLATFORM_REFERENCE_WINMDS "${WINDOWS_KITS_REFERENCES_PATH}/${CMAKE_SYSTEM_VERSION}/${PLATFORM_REFERENCE_NAME}/${PLATFORM_REFERENCE_VERSION}/${PLATFORM_REFERENCE_NAME}.winmd")
    list(APPEND PLATFORM_REFERENCE_PATHS "${WINDOWS_KITS_REFERENCES_PATH}/${CMAKE_SYSTEM_VERSION}/${PLATFORM_REFERENCE_NAME}/${PLATFORM_REFERENCE_VERSION}")
endwhile()

#----------------------------------------------------------------------------------------------------------------------
#
#----------------------------------------------------------------------------------------------------------------------
function(_generateMidlPlatformResponseFile)
    cmake_path(CONVERT "${PLATFORM_REFERENCE_WINMDS}" TO_NATIVE_PATH_LIST PLATFORM_REFERENCE_WINMDS)
    cmake_path(CONVERT "${PLATFORM_METADATA_PATHS}" TO_NATIVE_PATH_LIST PLATFORM_METADATA_PATHS)

    # Generate the response file containing the MIDL references to the platform winmd files
    list(JOIN PLATFORM_REFERENCE_WINMDS "\" /reference \"" PLATFORM_REFERENCE_WINMDS_ARGS)
    set(PLATFORM_REFERENCE_WINMDS_ARGS "/reference \"${PLATFORM_REFERENCE_WINMDS_ARGS}\"")

    list(JOIN PLATFORM_METADATA_PATHS "\" /metadata_dir \"" PLATFORM_METADATA_PATHS_ARGS)
    set(PLATFORM_METADATA_PATHS_ARGS "/metadata_dir \"${PLATFORM_METADATA_PATHS_ARGS}\"")

    file(GENERATE
        OUTPUT ${MIDL_PLATFORM_RESPONSE_FILE}
        CONTENT "/nologo ${PLATFORM_REFERENCE_WINMDS_ARGS} ${PLATFORM_METADATA_PATHS_ARGS}"
        )
endfunction()

#----------------------------------------------------------------------------------------------------------------------
#
#----------------------------------------------------------------------------------------------------------------------
function(_generateMdMergePlatformResponseFile)
    cmake_path(CONVERT "${PLATFORM_REFERENCE_PATHS}" TO_NATIVE_PATH_LIST PLATFORM_REFERENCE_PATHS)

    # Generate the response file containing the MIDL references to the platform winmd files
    list(JOIN PLATFORM_REFERENCE_PATHS "\" -metadata_dir \"" PLATFORM_REFERENCE_PATHS_ARGS)
    set(PLATFORM_REFERENCE_PATHS_ARGS "-metadata_dir \"${PLATFORM_REFERENCE_PATHS_ARGS}\"")

    file(GENERATE
        OUTPUT ${MDMERGE_PLATFORM_RESPONSE_FILE}
        CONTENT "-v ${PLATFORM_REFERENCE_PATHS_ARGS}"
        )
endfunction()

_generateMidlPlatformResponseFile()
_generateMdMergePlatformResponseFile()

#----------------------------------------------------------------------------------------------------------------------
#
#----------------------------------------------------------------------------------------------------------------------
function(enable_midlrt)
    cmake_language(EVAL CODE "cmake_language(DEFER CALL _process_target_midl [[${ARGV0}]])")
endfunction()

#----------------------------------------------------------------------------------------------------------------------
#
#----------------------------------------------------------------------------------------------------------------------
function(_generateUnmergedWinMd TARGET IDL_FILES WINMD_FILES_VARIABLE)
    get_target_property(TARGET_SOURCE_DIR ${TARGET} SOURCE_DIR)

    set(MIDL_COMMAND "")
    list(APPEND MIDL_COMMAND "\"${MIDL_COMPILER}\"")
    list(APPEND MIDL_COMMAND "@\"${MIDL_PLATFORM_RESPONSE_FILE}\"")
    list(APPEND MIDL_COMMAND /winrt)
    list(APPEND MIDL_COMMAND /W3 /WX)
    list(APPEND MIDL_COMMAND /char signed)
    list(APPEND MIDL_COMMAND /env x64)
    list(APPEND MIDL_COMMAND /error all)
    list(APPEND MIDL_COMMAND /h nul /dlldata nul /iid nul /proxy nul /notlb)
    list(APPEND MIDL_COMMAND /client none /server none)
    list(APPEND MIDL_COMMAND /enum_class)
    list(APPEND MIDL_COMMAND /ns_prefix)
    list(APPEND MIDL_COMMAND /target NT60)
    list(APPEND MIDL_COMMAND /nomidl)
    list(APPEND MIDL_COMMAND /I "\"${WINDOWS_KITS_INCLUDE_PATH}/winrt\"")

    list(JOIN MIDL_COMMAND " " MIDL_COMMAND_LINE)

    # COMPILER_DIR
    get_filename_component(COMPILER_DIR ${CMAKE_C_COMPILER} DIRECTORY)

    set(GENERATED_FILES)

    foreach(IDL_FILE IN LISTS IDL_FILES)
        get_filename_component(IDL_FILE_BASE ${IDL_FILE} NAME_WLE)

        set(OUTPUT_WINMD_FILE ${CMAKE_CURRENT_BINARY_DIR}/Unmerged/${IDL_FILE_BASE}.winmd)
        set(OUTPUT_WINMD_LOG ${CMAKE_CURRENT_BINARY_DIR}/Unmerged/${IDL_FILE_BASE}.log)

        cmake_path(NATIVE_PATH OUTPUT_WINMD_FILE OUTPUT_WINMD_FILE)
        cmake_path(NATIVE_PATH OUTPUT_WINMD_LOG OUTPUT_WINMD_LOG)

        set(MIDL_COMMAND_SCRIPT ${CMAKE_CURRENT_BINARY_DIR}/midl.${IDL_FILE_BASE}.cmd)
        file(GENERATE OUTPUT ${MIDL_COMMAND_SCRIPT} CONTENT "\
@echo off
set PATH=%PATH%;${COMPILER_DIR}
${MIDL_COMMAND_LINE} /winmd \"${OUTPUT_WINMD_FILE}\" \"${IDL_FILE}\" /o \"${OUTPUT_WINMD_LOG}\"
")

        add_custom_command(
            OUTPUT ${OUTPUT_WINMD_FILE} ${OUTPUT_WINMD_LOG}
            COMMAND ${MIDL_COMMAND_SCRIPT}
            MAIN_DEPENDENCY ${IDL_FILE}
            DEPENDS ${MIDL_COMMAND_SCRIPT}
            COMMENT "Generating ${IDL_FILE_BASE}.winmd"
            WORKING_DIRECTORY ${TARGET_SOURCE_DIR}
        )

        list(APPEND GENERATED_FILES ${OUTPUT_WINMD_FILE})
    endforeach()

    set(${WINMD_FILES_VARIABLE} ${GENERATED_FILES} PARENT_SCOPE)
endfunction()

#----------------------------------------------------------------------------------------------------------------------
#
#----------------------------------------------------------------------------------------------------------------------
function(_mergeWinMdFiles TARGET WINMD_FILES TARGET_WINMD_FILE_VARIABLE)
    get_target_property(TARGET_SOURCE_DIR ${TARGET} SOURCE_DIR)
    get_target_property(TARGET_NAME ${TARGET} "NAME")

    set(OUTPUT_TARGET_WINMD_DIR ${CMAKE_CURRENT_BINARY_DIR})
    set(OUTPUT_TARGET_WINMD_FILE ${OUTPUT_TARGET_WINMD_DIR}/${TARGET_NAME}.winmd)

    # Build common MDMERGE parameters into MDMERGE_COMMAND
    set(MDMERGE_COMMAND "")
    list(APPEND MDMERGE_COMMAND "\"${MDMERGE_TOOL}\"")
    list(APPEND MDMERGE_COMMAND "@\"${MDMERGE_PLATFORM_RESPONSE_FILE}\"")
    list(APPEND MDMERGE_COMMAND -partial)
    list(APPEND MDMERGE_COMMAND -n:1)
    list(APPEND MDMERGE_COMMAND -o "\"${OUTPUT_TARGET_WINMD_DIR}\"")

    foreach(WINMD_FILE IN LISTS WINMD_FILES)
        list(APPEND MDMERGE_COMMAND -i "\"${WINMD_FILE}\"")
    endforeach()

    set(MDMERGE_COMMAND_SCRIPT ${CMAKE_CURRENT_BINARY_DIR}/mdmerge.${TARGET_NAME}.cmd)
    list(JOIN MDMERGE_COMMAND " " MDMERGE_COMMAND_LINE)
    file(GENERATE OUTPUT ${MDMERGE_COMMAND_SCRIPT} CONTENT "\
@echo off
${MDMERGE_COMMAND_LINE}
")

    add_custom_command(
            OUTPUT ${OUTPUT_TARGET_WINMD_FILE}
            COMMAND ${MDMERGE_COMMAND_SCRIPT}
            DEPENDS ${WINMD_FILES} ${MDMERGE_COMMAND_SCRIPT}
            COMMENT "Generating ${TARGET_NAME}.winmd"
            WORKING_DIRECTORY ${TARGET_SOURCE_DIR}
        )

    set(${TARGET_WINMD_FILE_VARIABLE} ${OUTPUT_TARGET_WINMD_FILE} PARENT_SCOPE)
endfunction()

#----------------------------------------------------------------------------------------------------------------------
#
#----------------------------------------------------------------------------------------------------------------------
function(_cppwinrtTargetProjection TARGET MERGED_WINMD_FILE)
    get_target_property(TARGET_NAME ${TARGET} "NAME")

    set(CPPWINRT_COMMAND "")
    list(APPEND CPPWINRT_COMMAND "\"${NUGET_MICROSOFT_WINDOWS_CPPWINRT}/bin/cppwinrt.exe\"")
    list(APPEND CPPWINRT_COMMAND -overwrite)
    list(APPEND CPPWINRT_COMMAND -name ${TARGET_NAME})
    list(APPEND CPPWINRT_COMMAND -pch .)
    list(APPEND CPPWINRT_COMMAND -prefix)
    list(APPEND CPPWINRT_COMMAND -comp "\"${CMAKE_CURRENT_BINARY_DIR}/Generated Files/sources\"")
    list(APPEND CPPWINRT_COMMAND -opt)
    list(APPEND CPPWINRT_COMMAND -in "\"${MERGED_WINMD_FILE}\"")
    foreach(PLATFORM_REFERENCE_WINMD IN LISTS PLATFORM_REFERENCE_WINMDS)
        list(APPEND CPPWINRT_COMMAND -ref "\"${PLATFORM_REFERENCE_WINMD}\"")
    endforeach()
    list(APPEND CPPWINRT_COMMAND -out "\"${CMAKE_CURRENT_BINARY_DIR}/Generated Files\"")

    set(CPPWINRT_COMMAND_SCRIPT ${CMAKE_CURRENT_BINARY_DIR}/cppwinrt.${TARGET_NAME}.cmd)
    list(JOIN CPPWINRT_COMMAND " " CPPWINRT_COMMAND_LINE)
    file(GENERATE OUTPUT ${CPPWINRT_COMMAND_SCRIPT} CONTENT "\
@echo off
${CPPWINRT_COMMAND_LINE}
")

    add_custom_command(
            OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/Generated Files/module.g.cpp"
            COMMAND ${CPPWINRT_COMMAND_SCRIPT}
            DEPENDS ${MERGED_WINMD_FILE} ${CPPWINRT_COMMAND_SCRIPT}
            COMMENT "Projecting ${TARGET_NAME}.winmd"
            WORKING_DIRECTORY ${TARGET_SOURCE_DIR}
        )
endfunction()

#----------------------------------------------------------------------------------------------------------------------
#
#----------------------------------------------------------------------------------------------------------------------
function(_cppwinrtPlatformProjection)
    set(CPPWINRT_COMMAND "")
    list(APPEND CPPWINRT_COMMAND "\"${NUGET_MICROSOFT_WINDOWS_CPPWINRT}/bin/cppwinrt.exe\"")
    foreach(PLATFORM_REFERENCE_WINMD IN LISTS PLATFORM_REFERENCE_WINMDS)
        list(APPEND CPPWINRT_COMMAND -in "\"${PLATFORM_REFERENCE_WINMD}\"")
    endforeach()
    list(APPEND CPPWINRT_COMMAND -out "\"${CMAKE_CURRENT_BINARY_DIR}/Generated Files\"")

    set(CPPWINRT_COMMAND_SCRIPT ${CMAKE_CURRENT_BINARY_DIR}/cppwinrt.__platform__.cmd)
    list(JOIN CPPWINRT_COMMAND " " CPPWINRT_COMMAND_LINE)
    file(GENERATE OUTPUT ${CPPWINRT_COMMAND_SCRIPT} CONTENT "\
    @echo off
    ${CPPWINRT_COMMAND_LINE}
    ")

    add_custom_command(
            OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/Generated Files/winrt/base.h"
            COMMAND ${CPPWINRT_COMMAND_SCRIPT}
            DEPENDS ${MERGED_WINMD_FILE} ${CPPWINRT_COMMAND_SCRIPT}
            COMMENT "Projecting 'Platform' .winmd"
            WORKING_DIRECTORY ${TARGET_SOURCE_DIR}
        )
endfunction()

#----------------------------------------------------------------------------------------------------------------------
#
#----------------------------------------------------------------------------------------------------------------------
function(_process_target_midl TARGET)
    get_target_property(TARGET_SOURCE_DIR ${TARGET} SOURCE_DIR)
    get_target_property(IDL_FILES ${TARGET} SOURCES)
    list(FILTER IDL_FILES INCLUDE REGEX "\.idl$")

    # Generate a '.winmd' file for every '.idl' file specified to the target.
    _generateUnmergedWinMd(${TARGET} ${IDL_FILES} WINMD_FILES)

    # Run mdmerge to merge the generated .winmd files.
    _mergeWinMdFiles(${TARGET} ${WINMD_FILES} TARGET_WINMD_FILE)

    # Use cppwinrt.exe to generate the projection from the .winmd file.
    _cppwinrtTargetProjection(${TARGET} ${TARGET_WINMD_FILE})

    _cppwinrtPlatformProjection()

    target_include_directories(${TARGET}
        PRIVATE
            "${TARGET_SOURCE_DIR}"
            "${CMAKE_CURRENT_BINARY_DIR}/Generated Files"
    )

    target_sources(${TARGET}
        PRIVATE
            "${CMAKE_CURRENT_BINARY_DIR}/Generated Files/module.g.cpp"
    )
endfunction()
