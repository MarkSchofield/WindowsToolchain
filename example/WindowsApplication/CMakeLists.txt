#----------------------------------------------------------------------------------------------------------------------
#
#----------------------------------------------------------------------------------------------------------------------
project(WindowsApplication LANGUAGES CXX)

add_executable(WindowsApplication WIN32
    app.manifest
    WindowsApplication.cpp
    WindowsApplication.rc
)

set_source_files_properties(WindowsApplication.rc
    PROPERTIES
        OBJECT_DEPENDS "${CMAKE_CURRENT_LIST_DIR}/small.ico;${CMAKE_CURRENT_LIST_DIR}/WindowsApplication.ico"
)
