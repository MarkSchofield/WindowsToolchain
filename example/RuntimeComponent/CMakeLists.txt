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

target_precompile_headers(RuntimeComponent
    PRIVATE
        pch.h
)

target_link_libraries(RuntimeComponent
    PRIVATE
        CppWinRT
)

enable_midlrt(RuntimeComponent)
