#----------------------------------------------------------------------------------------------------------------------
#
#----------------------------------------------------------------------------------------------------------------------
project(RuntimeComponent LANGUAGES CXX)

include(MidlRT)

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

target_precompile_headers(RuntimeComponent
    PRIVATE
        pch.h
)

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
