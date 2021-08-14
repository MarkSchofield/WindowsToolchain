#----------------------------------------------------------------------------------------------------------------------
#
#----------------------------------------------------------------------------------------------------------------------
project(SharedLibrary LANGUAGES CXX)

add_library(SharedLibrary SHARED
    DllMain.cpp
    Project1.cpp
)

target_compile_definitions(SharedLibrary
    PRIVATE
        PROJECT1_EXPORTS
)

target_precompile_headers(SharedLibrary
    PRIVATE
        pch.h
)
