cmake_minimum_required(VERSION 3.20)

project(WindowsToolchainTests)

if(NOT SKIP_NUGET_DOWNLOAD)
    install_nuget_package(Humanizer.Core 2.14.1 NUGET_HUMANIZER_CORE)
endif()
