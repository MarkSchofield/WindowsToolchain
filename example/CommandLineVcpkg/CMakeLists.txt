#----------------------------------------------------------------------------------------------------------------------
#
#----------------------------------------------------------------------------------------------------------------------
project(CommandLineVcpkg LANGUAGES CXX)

# Find the unofficial-sqlite3 package from vcpkg
find_package(unofficial-sqlite3 CONFIG REQUIRED)

add_executable(CommandLineVcpkg
    main.cpp
)

target_compile_features(CommandLineVcpkg
    PRIVATE
        cxx_std_23
)

target_link_libraries(CommandLineVcpkg
    PRIVATE
        unofficial::sqlite3::sqlite3
)
