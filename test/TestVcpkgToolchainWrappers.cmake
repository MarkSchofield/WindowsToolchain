# Test that the vcpkg wrappers include vcpkg's Windows toolchain before the WindowsToolchain compiler wrappers.
#
# Usage: cmake -P test/TestVcpkgToolchainWrappers.cmake

cmake_minimum_required(VERSION 3.20)

function(assert_contains VARIABLE EXPECTED)
    set(VALUE "${${VARIABLE}}")
    string(FIND "${VALUE}" "${EXPECTED}" POSITION)
    if(POSITION EQUAL -1)
        message(FATAL_ERROR "FAIL: ${VARIABLE} = '${VALUE}' does not contain '${EXPECTED}'")
    endif()
endfunction()

function(write_fake_vcpkg_toolchain ROOT)
    file(MAKE_DIRECTORY "${ROOT}/scripts/toolchains")
    file(WRITE "${ROOT}/scripts/toolchains/windows.cmake"
        "list(APPEND TEST_INCLUDE_ORDER vcpkg)\n"
        "set(CMAKE_SYSTEM_PROCESSOR AMD64 CACHE STRING \"\")\n"
        "foreach(TGT EXE SHARED MODULE)\n"
        "    set(CMAKE_\${TGT}_LINKER_FLAGS_RELEASE "
        "\"/nologo /DEBUG /INCREMENTAL:NO /OPT:REF /OPT:ICF\" CACHE STRING \"\")\n"
        "endforeach()\n"
    )
endfunction()

function(write_fake_windows_toolchain FILE_NAME INCLUDE_NAME)
    file(WRITE "${TEST_BINARY_DIR}/${FILE_NAME}"
        "list(APPEND TEST_INCLUDE_ORDER ${INCLUDE_NAME})\n"
        "assert_contains(CMAKE_EXE_LINKER_FLAGS_RELEASE \"/DEBUG\")\n"
        "assert_contains(CMAKE_EXE_LINKER_FLAGS_RELEASE \"/OPT:REF\")\n"
        "assert_contains(CMAKE_EXE_LINKER_FLAGS_RELEASE \"/OPT:ICF\")\n"
    )
endfunction()

function(reset_wrapper_state)
    unset(TEST_INCLUDE_ORDER)
    unset(CMAKE_EXE_LINKER_FLAGS_RELEASE CACHE)
    unset(CMAKE_SHARED_LINKER_FLAGS_RELEASE CACHE)
    unset(CMAKE_MODULE_LINKER_FLAGS_RELEASE CACHE)
    unset(CMAKE_SYSTEM_PROCESSOR CACHE)
    unset(CMAKE_C_COMPILER_FRONTEND_VARIANT)
    unset(CMAKE_CXX_COMPILER_FRONTEND_VARIANT)
endfunction()

function(run_wrapper_test WRAPPER_FILE EXPECTED_ORDER)
    reset_wrapper_state()
    include("${TEST_BINARY_DIR}/${WRAPPER_FILE}")

    if(NOT TEST_INCLUDE_ORDER STREQUAL EXPECTED_ORDER)
        message(FATAL_ERROR "FAIL: ${WRAPPER_FILE} include order was '${TEST_INCLUDE_ORDER}', expected '${EXPECTED_ORDER}'")
    endif()

    if(WRAPPER_FILE MATCHES "Clang")
        if(NOT CMAKE_C_COMPILER_FRONTEND_VARIANT STREQUAL MSVC)
            message(FATAL_ERROR "FAIL: ${WRAPPER_FILE} should select the MSVC C frontend.")
        endif()

        if(NOT CMAKE_CXX_COMPILER_FRONTEND_VARIANT STREQUAL MSVC)
            message(FATAL_ERROR "FAIL: ${WRAPPER_FILE} should select the MSVC C++ frontend.")
        endif()
    endif()
endfunction()

set(TEST_BINARY_ROOT "${CMAKE_CURRENT_LIST_DIR}/__output")
set(TEST_BINARY_DIR "${TEST_BINARY_ROOT}/TestVcpkgToolchainWrappers")
file(REMOVE_RECURSE "${TEST_BINARY_ROOT}")
file(MAKE_DIRECTORY "${TEST_BINARY_DIR}")

set(_VCPKG_ROOT_DIR "${TEST_BINARY_DIR}/fake-vcpkg")
write_fake_vcpkg_toolchain("${_VCPKG_ROOT_DIR}")

configure_file("${CMAKE_CURRENT_LIST_DIR}/../Windows.Vcpkg.MSVC.toolchain.cmake"
    "${TEST_BINARY_DIR}/Windows.Vcpkg.MSVC.toolchain.cmake"
    COPYONLY
)
configure_file("${CMAKE_CURRENT_LIST_DIR}/../Windows.Vcpkg.Clang.toolchain.cmake"
    "${TEST_BINARY_DIR}/Windows.Vcpkg.Clang.toolchain.cmake"
    COPYONLY
)

write_fake_windows_toolchain("Windows.MSVC.toolchain.cmake" "msvc")
write_fake_windows_toolchain("Windows.Clang.toolchain.cmake" "clang")

run_wrapper_test("Windows.Vcpkg.MSVC.toolchain.cmake" "vcpkg;msvc")
run_wrapper_test("Windows.Vcpkg.Clang.toolchain.cmake" "vcpkg;clang")

file(REMOVE_RECURSE "${TEST_BINARY_ROOT}")

message(STATUS "All vcpkg wrapper tests PASSED!")
