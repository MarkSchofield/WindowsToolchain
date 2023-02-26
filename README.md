# A CMake Toolchain file for Windows MSVC and Windows Clang

A CMake toolchain file describes the set of tools and utilities for compiling code in CMake. This repo provides
toolchains that describes how to compile using MSVC and Clang in CMake, with the goal of making Windows CMake builds more
canonical to reduce the 'barrier-to-entry' to build code for Windows.

[![build status](https://github.com/MarkSchofield/Toolchain/actions/workflows/ci.yaml/badge.svg?branch=main)](https://github.com/MarkSchofield/Toolchain/actions/workflows/ci.yaml?query=branch%3Amain)

## But I can build with MSVC in CMake already...?

Yes, but you're probably either:

  1. using a "Visual Studio Generator". In which case, CMake will emit - and then build - a Visual Studio Solution file
     that knows how to find the build tools and utilities.

  2. running from a Visual Studio "Command Prompt". In which case, the command prompt is hard-coded to use a set of
     tools and utilities, which means that you always need to initialize your command prompt before getting started.

By using a Toolchain file to describe the tools and utilities to build in CMake-terms, you can use other generators
(e.g. Ninja) and don't have to initialize an environment to run a build.

## So this is a replacement for Visual Studio!?

No, no. This uses the tools and utilities from installed Visual Studio but from a CMake build.

## So this solves all my build problems!?

No. This is an early attempt at making Visual Studio tooling easier to use from CMake. There's definitely gaps -
there's no support for "Windows Universal" builds, for example. But it gets enough of a stake-in-the-ground to start a
conversation.

## How do I use this?

Specify the 'Windows.MSVC.toolchain.cmake' or 'Windows.Clang.toolchain.cmake' file as a toolchain file to your CMake
builds. See [the documentation for CMake toolchains][cmake-toolchains] for more details on Toolchain files and how to
consume them.

The ['Windows.MSVC.toolchain.cmake'](./Windows.MSVC.toolchain.cmake) and
['Windows.Clang.toolchain.cmake'](./Windows.Clang.toolchain.cmake) file has details on the various CMake variables
that can be used to configure the build. And [the example folder](./example) provides a CMake project that builds a
variety of Windows projects.

## WindowsToolchain and VCPkg

VCPkg - <https://github.com/microsoft/vcpkg> - is a Package Manager for C++. There are a couple of problems when using WindowsToolchain and VCPkg together:

1. In order to use VCPkg, the `vcpkg.cmake` script must be specified as the toolchain for CMake builds - as per [the VCPkg documentation](https://github.com/microsoft/vcpkg#getting-started). Since only a single script can be specified as the [CMAKE_TOOLCHAIN_FILE](https://cmake.org/cmake/help/latest/variable/CMAKE_TOOLCHAIN_FILE.html), then VCPkg *cannot* be used in conjunction with other CMake toolchains, such as WindowsToolchain.

2. VCPkg has default functionality to copy runtime dependencies from VCPkg-based packages during a CMake build. The functionality - implemented in [`applocal.ps1`](https://github.com/microsoft/vcpkg/blob/0ba60bfef5dea4cb2599daa7ad8364e309835a68/scripts/buildsystems/msbuild/applocal.ps1) - requires that `dumpbin`, `llvm-objdump` or `objdump` be found by PowerShell's `Get-Command`. On Windows, `applocal.ps1` is typically executed so that it would find `dumpbin` through the `PATH` environment variable, but since WindowsToolchain doesn't configure the `PATH` environment variable `applocal.ps1` fails.

In order to use WindowsToolchain with VCPkg:

1. Specify WindowsToolchain as the `CMAKE_TOOLCHAIN_FILE`, and specify the `vcpkg.cmake` script as a [`CMAKE_PROJECT_TOP_LEVEL_INCLUDES`](https://cmake.org/cmake/help/latest/variable/CMAKE_PROJECT_TOP_LEVEL_INCLUDES.html) entry. Note: `CMAKE_PROJECT_TOP_LEVEL_INCLUDES` requires CMake 3.24 or higher.

2. Set `VCPKG_APPLOCAL_DEPS` to `OFF` in your `CMakePresets.json`, on the CMake configuration command-line, or before the top-level `project()` call to disable the default behavior of VCPkg to copy runtime dependencies during a build. If dependencies need to be copied during a build, use custom commands to copy them. For example, the following CMake snippet will copy dependencies for a target called `CommandLine`, for dependencies that support the `$<TARGET_RUNTIME_DLLS:tgt>` generator expression:

    ```cmake
    if(WIN32)
        add_custom_command(TARGET CommandLine POST_BUILD
            COMMAND "${CMAKE_COMMAND};-E;$<IF:$<BOOL:$<TARGET_RUNTIME_DLLS:CommandLine>>,copy;$<TARGET_RUNTIME_DLLS:CommandLine>;$<TARGET_FILE_DIR:CommandLine>,true>"
            COMMAND_EXPAND_LISTS
        )
    endif()
    ```

    Note: The `$<TARGET_RUNTIME_DLLS:tgt>` generator expression requires CMake 3.21 or higher.

[#59](https://github.com/MarkSchofield/WindowsToolchain/issues/59) discusses using WindowsToolchain and VCPkg together.

## Linting

WindowsToolchain uses [`cmakelang`][cmakelang] for linting the CMake files in the codebase. The
[.cmake-format.yaml](./.cmake-format.yaml) file describes the formatting style for the codebase. To run the linting
tools:

1. Install [`cmakelang`][cmakelang] following [the installation instuctions](https://cmake-format.readthedocs.io/en/latest/installation.html).
Note: Since WindowsToolchain uses a `.yaml` file for configuration, make sure to install the `cmakelang[YAML]` package.

2. Run [`./analyze.ps1`](./analyze.ps1)

The [Toolchain CI](.\.github\workflows\ci.yaml) GitHub Workflow enforces the linting rules during PR and CI.

## Testing

WindowsToolchain uses [Pester][pester] for testing the CMake files in the codebase. The tests are written for
[PowerShell Core][powershellcore] and checked into [the `Tests` folder](./Tests). To run the tests:

1. Launch a [PowerShell Core][powershellcore] prompt.

    ```text
    pwsh
    ```

2. Make sure that you have [Pester][pester] installed. This only needs to be done once.

    ```powershell
    Install-Module Pester
    ```

3. Import the Pester module into the PowerShell Core session:

    ```powershell
    Import-Module Pester
    ```

4. Discover and run all tests:

    ```powershell
    Invoke-Pester
    ```

The [Toolchain CI](.\.github\workflows\ci.yaml) GitHub Workflow requires all tests to pass during PR and CI.

[cmake-toolchains]: https://cmake.org/cmake/help/latest/manual/cmake-toolchains.7.html "CMake Toolchains"
[cmakelang]: https://cmake-format.readthedocs.io/ "cmakelang"
[pester]: https://pester.dev/ "Pester"
[powershellcore]: https://learn.microsoft.com/en-us/powershell/ "PowerShell Core"
