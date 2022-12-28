#Requires -PSEdition Core

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

BeforeAll {
    . $PSScriptRoot/../Scripts/Test.ps1

    EnsureAvailableTools

    $ToolsPath = Join-Path -Path $PSScriptRoot -ChildPath __tools
    $OutputPath = Join-Path -Path $PSScriptRoot -ChildPath __output

    $ToolsNinjaPath = Join-Path -Path $ToolsPath -ChildPath ninja.exe

    $OriginalLocation = Get-Location
}

AfterAll {
    Set-Location $OriginalLocation
}

Describe 'Windows.MSVC.toolchain.cmake Ninja support' {
    BeforeEach {
        # Make sure that the build is clean before each test
        @(
            $ToolsPath
            $OutputPath
        ) | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue

        Set-Location -Path $PSScriptRoot
    }

    It 'does not download Ninja if CMAKE_MAKE_PROGRAM is set' {
        $Parameters = @(
            "-DCMAKE_MAKE_PROGRAM=$DownloadNinjaPath"
        )

        $Null = & $CMake --preset windows @Parameters
        $LastExitCode | Should -Be 0

        $CMakeCachePath = Join-Path -Path $OutputPath -ChildPath windows/CMakeCache.txt
        $CMakeCachePath | Should -Exist
        $ToolsPath | Should -Not -Exist
    }

    It 'does not download Ninja if it is in the path' {
        StashEnvironment Path {
            $env:Path = $DownloadPath
            $Null = & $CMake --preset windows
            $LastExitCode | Should -Be 0

            $CMakeCachePath = Join-Path -Path $OutputPath -ChildPath windows/CMakeCache.txt
            $CMakeCachePath | Should -Exist
            $ToolsPath | Should -Not -Exist

            $CMakeCachePath |
                Get-CMakeCacheVariable -EntryName CMAKE_MAKE_PROGRAM |
                Select-Object -ExpandProperty Value |
                Canonicalize-Path |
                Should -Be $DownloadNinjaPath
        }
    }

    It 'does not download Ninja if it is not in the path or specified, and TOOLCHAIN_TOOLS_PATH is not set' {
        StashEnvironment Path {
            $env:Path = ''

            # With no Ninja to be found, and TOOLCHAIN_TOOLS_PATH not set, the build should fail.
            $Null = & $CMake --preset windows 2>&1
            $LastExitCode | Should -Be 1
        }
    }

    It 'downloads Ninja if it is not in the path or specified, and TOOLCHAIN_TOOLS_PATH is set' {
        StashEnvironment Path {
            $env:Path = ''

            # With no Ninja to be found, but with TOOLCHAIN_TOOLS_PATH set, the build should succeed.
            $Parameters = @(
                "-DTOOLCHAIN_TOOLS_PATH=$ToolsPath"
            )

            $Null = & $CMake --preset windows @Parameters
            $LastExitCode | Should -Be 0

            $CMakeCachePath = Join-Path -Path $OutputPath -ChildPath windows/CMakeCache.txt
            $CMakeCachePath | Should -Exist
            $ToolsPath | Should -Exist

            $CMakeCachePath |
                Get-CMakeCacheVariable -EntryName CMAKE_MAKE_PROGRAM |
                Select-Object -ExpandProperty Value |
                Canonicalize-Path |
                Should -Be $ToolsNinjaPath
        }
    }
}
