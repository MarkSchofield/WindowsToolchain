# Test that Release linker flags include /DEBUG /OPT:REF /OPT:ICF for all architectures
#
# Usage: cmake -P test/TestReleaseLinkerFlags.cmake

cmake_minimum_required(VERSION 3.20)

#[[ Assert that VARIABLE contains EXPECTED substring. ]]
function(assert_contains VARIABLE EXPECTED)
    set(VALUE "${${VARIABLE}}")
    string(FIND "${VALUE}" "${EXPECTED}" POSITION)
    if(POSITION EQUAL -1)
        message(FATAL_ERROR "FAIL: ${VARIABLE} = '${VALUE}' does not contain '${EXPECTED}'")
    endif()
endfunction()

#[[ Test linker flags for the given architecture for all target types. ]]
function(run_test ARCHITECTURE MACHINE_FLAG)
    set(CMAKE_VS_PLATFORM_TOOLSET_ARCHITECTURE "${ARCHITECTURE}")

    # This is the exact same code block from the toolchain files
    foreach(TGT EXE SHARED MODULE)
        set(CMAKE_${TGT}_LINKER_FLAGS_RELEASE_INIT
            "/machine:${CMAKE_VS_PLATFORM_TOOLSET_ARCHITECTURE} /DEBUG /OPT:REF /OPT:ICF")
    endforeach()

    # Verify all three target types got the correct flags
    foreach(TGT EXE SHARED MODULE)
        set(VAR_NAME "CMAKE_${TGT}_LINKER_FLAGS_RELEASE_INIT")
        assert_contains(${VAR_NAME} "/DEBUG")
        assert_contains(${VAR_NAME} "/OPT:REF")
        assert_contains(${VAR_NAME} "/OPT:ICF")
        assert_contains(${VAR_NAME} "${MACHINE_FLAG}")
        message(STATUS "  PASS: ${VAR_NAME} = '${${VAR_NAME}}'")
    endforeach()

    # Verify MinSizeRel and RelWithDebInfo are NOT affected
    if(DEFINED CMAKE_EXE_LINKER_FLAGS_MINSIZEREL_INIT)
        message(FATAL_ERROR "FAIL: CMAKE_EXE_LINKER_FLAGS_MINSIZEREL_INIT should not be set by our change")
    endif()
    if(DEFINED CMAKE_EXE_LINKER_FLAGS_RELWITHDEBINFO_INIT)
        message(FATAL_ERROR "FAIL: CMAKE_EXE_LINKER_FLAGS_RELWITHDEBINFO_INIT should not be set by our change")
    endif()

    # Cleanup for next test
    foreach(TGT EXE SHARED MODULE)
        unset(CMAKE_${TGT}_LINKER_FLAGS_RELEASE_INIT)
    endforeach()
endfunction()

message(STATUS "Testing Release linker flags for all architectures...")

message(STATUS "\nArchitecture: x64")
run_test("x64" "/machine:x64")

message(STATUS "\nArchitecture: ARM64")
run_test("ARM64" "/machine:ARM64")

message(STATUS "\nArchitecture: ARM")
run_test("ARM" "/machine:ARM")

message(STATUS "\nArchitecture: X86")
run_test("X86" "/machine:X86")

message(STATUS "\nAll tests PASSED!")
