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

#[[====================================================================================================================
    add_import_library
    ------------------

    Creates an import library for a named library and a list of the libraries exports.

    add_import_library(<target name>
        NAME
            <library name>
        EXPORTS
            <exports list>
    )

    Notes:
        * `add_import_library` only works with MSVC compilers.
        * The `<library name>` should be the name of the library without the `.dll` extension.
        * The `<exports list>` should be the list of exports from the library.

====================================================================================================================]]#
function(add_import_library TARGET_NAME)

    if((NOT(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")) AND (NOT(CMAKE_C_COMPILER_ID STREQUAL "MSVC")))
        message(FATAL_ERROR "add_import_library only works with an MSVC compiler.")
    endif()

    set(OPTIONS)
    set(ONE_VALUE_KEYWORDS NAME)
    set(MULTI_VALUE_KEYWORDS EXPORTS)

    cmake_parse_arguments(PARSE_ARGV 0 IMPORT "${OPTIONS}" "${ONE_VALUE_KEYWORDS}" "${MULTI_VALUE_KEYWORDS}")

    # Generate the .def file.
    set(DEF_FILE_PATH ${CMAKE_CURRENT_BINARY_DIR}/${TARGET_NAME}_library.def)
    list(TRANSFORM IMPORT_EXPORTS PREPEND "\t")
    list(TRANSFORM IMPORT_EXPORTS APPEND "\n")
    list(APPEND DEF_FILE_CONTENTS
        "LIBRARY ${IMPORT_NAME}\n"
        "EXPORTS\n"
        "${IMPORT_EXPORTS}"
    )

    file(WRITE "${DEF_FILE_PATH}.input" ${DEF_FILE_CONTENTS})
    configure_file("${DEF_FILE_PATH}.input" ${DEF_FILE_PATH} COPYONLY)

    # Use the .def file to generate the .lib file.
    set(LIB_FILE_NAME ${TARGET_NAME}_library.lib)
    set(LIB_FILE_PATH ${CMAKE_CURRENT_BINARY_DIR}/${LIB_FILE_NAME})

    # Map CMAKE_SYSTEM_PROCESSOR values to LIB_MACHINE to pass as /MACHINE to CMAKE_AR
    if((CMAKE_SYSTEM_PROCESSOR STREQUAL AMD64) OR (CMAKE_SYSTEM_PROCESSOR STREQUAL x64))
        set(LIB_MACHINE x64)
    elseif((CMAKE_SYSTEM_PROCESSOR STREQUAL arm)
        OR (CMAKE_SYSTEM_PROCESSOR STREQUAL arm64)
        OR (CMAKE_SYSTEM_PROCESSOR STREQUAL x86))
        set(LIB_MACHINE ${CMAKE_SYSTEM_PROCESSOR})
    else()
        message(FATAL_ERROR "Unable to identify the library machine type from CMAKE_SYSTEM_PROCESSOR ${CMAKE_SYSTEM_PROCESSOR}")
    endif()

    set(LIB_PROPERTIES "")
    list(APPEND LIB_PROPERTIES
        ${CMAKE_AR}
        "\"/DEF:${DEF_FILE_PATH}\""
        "\"/OUT:${LIB_FILE_PATH}\""
        "/MACHINE:${LIB_MACHINE}"
        /nodefaultlib
        /nologo
    )

    add_custom_command(
        OUTPUT ${LIB_FILE_PATH}
        COMMAND ${LIB_PROPERTIES}
        DEPENDS ${DEF_FILE_PATH}
        COMMENT "Generating ${TARGET_NAME}.lib"
        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    )

    add_custom_target(${TARGET_NAME}_library
        DEPENDS ${LIB_FILE_PATH}
        COMMENT "Generating ${TARGET_NAME}_library"
    )

    add_library(${TARGET_NAME}
        INTERFACE
    )

    add_dependencies(${TARGET_NAME}
        ${TARGET_NAME}_library
    )

    target_link_libraries(${TARGET_NAME}
        INTERFACE
            ${LIB_FILE_PATH}
    )
endfunction()
