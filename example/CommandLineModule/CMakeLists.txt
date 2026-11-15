#----------------------------------------------------------------------------------------------------------------------
#
#----------------------------------------------------------------------------------------------------------------------
cmake_minimum_required(VERSION 4.5.0)

project(CommandLineModule LANGUAGES CXX)

add_executable(CommandLineModule
    main.cpp
)

target_compile_features(CommandLineModule
    PRIVATE
        cxx_std_23
)
