#----------------------------------------------------------------------------------------------------------------------
#
#----------------------------------------------------------------------------------------------------------------------
project(CommandLineWinRT LANGUAGES CXX)

add_executable(CommandLineWinRT
    main.cpp
)

target_compile_features(CommandLineWinRT
    PRIVATE
        cxx_std_17
)

target_precompile_headers(CommandLineWinRT
    PRIVATE
        pch.h
)

target_link_libraries(CommandLineWinRT
    PRIVATE
        CppWinRT
)
