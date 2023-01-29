#----------------------------------------------------------------------------------------------------------------------
#
#----------------------------------------------------------------------------------------------------------------------
project(RuntimeComponent LANGUAGES CXX)

include(${WINDOWS_TOOLCHAIN_DIR}/Support/MidlRT.cmake)

add_library(RuntimeComponent SHARED
    Class.cpp
    Class.h
    Class.idl
    RuntimeComponent.def
)

target_compile_features(RuntimeComponent
    PRIVATE
        cxx_std_17
)

# Precompiled headers cause a dependency cycle with module support
if(NOT CMAKE_EXPERIMENTAL_CXX_MODULE_CMAKE_API)
    target_precompile_headers(RuntimeComponent
        PRIVATE
            pch.h
    )
endif()

target_link_libraries(RuntimeComponent
    PRIVATE
        CppWinRT
)

enable_midlrt(RuntimeComponent)

add_cppwinrt_projection(RuntimeComponentCppWinRT
    INPUTS
        ${CMAKE_CURRENT_BINARY_DIR}/RuntimeComponent.winmd
    DEPS
        CppWinRT
    OPTIMIZE
)

target_link_libraries(RuntimeComponentCppWinRT
    INTERFACE
        RuntimeComponent
)
