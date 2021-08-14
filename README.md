# A CMake Toolchain file for Windows MSVC

A CMake toolchain file describes the set of tools and utilities for compiling code in CMake. This repo provides a
toolchain that descibes how to compile using MSVC in CMake, with the goal of making Windows CMake builds more canonical
to reduce the 'barrier-to-entry' to build code for Windows.

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

Specify the 'Windows.MSVC.toolchain.cmake' file as a toolchain file to your CMake builds. See [the documentation for CMake toolchains][cmake-toolchains]
for more details on Toolchain files and how to consume them.

The ['Windows.MSVC.toolchain.cmake'](./Windows.MSVC.toolchain.cmake) file has details on the various CMake variables
that can be used to configure the build. And [the example folder](./example) provides a CMake project that builds a
variety of Windows projects.

[cmake-toolchains]: https://cmake.org/cmake/help/latest/manual/cmake-toolchains.7.html "CMake Toolchains"
