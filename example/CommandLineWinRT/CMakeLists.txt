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
        RuntimeComponentCppWinRT
)

add_custom_command(TARGET CommandLineWinRT POST_BUILD
  COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_RUNTIME_DLLS:CommandLineWinRT> $<TARGET_FILE_DIR:CommandLineWinRT>
  COMMAND_EXPAND_LISTS
)
