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

# Precompiled headers cause a dependency cycle with module support
if(NOT CMAKE_EXPERIMENTAL_CXX_MODULE_CMAKE_API)
    target_precompile_headers(CommandLineWinRT
        PRIVATE
            pch.h
    )
endif()

target_link_libraries(CommandLineWinRT
    PRIVATE
        RuntimeComponentCppWinRT
)

add_custom_command(TARGET CommandLineWinRT POST_BUILD
  COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_RUNTIME_DLLS:CommandLineWinRT> $<TARGET_FILE_DIR:CommandLineWinRT>
  COMMAND_EXPAND_LISTS
)
