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

## Linting

WindowsToolchain uses [`cmakelang`][cmakelang] for linting the CMake files in the codebase. The
[.cmake-format.yaml](./.cmake-format.yaml) file describes the formatting style for the codebase. To run the linting
tools:

1. Install [`cmakelang`][cmakelang] following [the installation instuctions](https://cmake-format.readthedocs.io/en/latest/installation.html).
Note: Since WindowsToolchain uses a `.yaml` file for configuration, make sure to install the `cmakelang[YAML]` package.

2. Run [`./analyze.ps1`](./analyze.ps1)

The [Toolchain CI](.\.github\workflows\ci.yaml) GitHub Workflow enforces the linting rules during PR and CI.

[cmake-toolchains]: https://cmake.org/cmake/help/latest/manual/cmake-toolchains.7.html "CMake Toolchains"
[cmakelang]: https://cmake-format.readthedocs.io/ "cmakelang"
