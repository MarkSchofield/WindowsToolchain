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

# Precompiled headers cause a dependency cycle with module support
if(NOT CMAKE_EXPERIMENTAL_CXX_MODULE_CMAKE_API)
    target_precompile_headers(SharedLibrary
        PRIVATE
            pch.h
    )
endif()
