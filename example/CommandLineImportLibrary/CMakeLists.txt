#----------------------------------------------------------------------------------------------------------------------
#
#----------------------------------------------------------------------------------------------------------------------
project(CommandLineImportLibrary LANGUAGES CXX)

include(${WINDOWS_TOOLCHAIN_SUPPORT_DIR}/Imports.cmake)

# An example of generating an import library for a DLL: 'ntdll.dll' exports 'NtCreateFile', but doesn't include
# 'NtCreateFile' as an export in the 'ntdll.lib' import library shipped in the Windows SDK. Rather than calling
# LoadLibrary/GetProcAddress to call 'NtCreateFile', generate an import library, and link to that.
add_import_library(ntdll_imports
    NAME
        ntdll
    EXPORTS
        NtCreateFile
)

add_executable(CommandLineImportLibrary
    main.cpp
)

target_link_libraries(CommandLineImportLibrary
    PRIVATE
        ntdll_imports
)
