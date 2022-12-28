#Requires -PSEdition Core

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

BeforeAll {
    . $PSScriptRoot/../Scripts/Test.ps1

    EnsureAvailableTools

    $ToolsPath = Join-Path -Path $PSScriptRoot -ChildPath __tools
    $OutputPath = Join-Path -Path $PSScriptRoot -ChildPath __output

    $ToolsNuGetPath = Join-Path -Path $ToolsPath -ChildPath nuget.exe

    $OriginalLocation = Get-Location
}

AfterAll {
    Set-Location $OriginalLocation
}

Describe 'Windows.MSVC.toolchain.cmake NuGet support' {
    BeforeEach {
        # Make sure that the build is clean before each test
        @(
            $ToolsPath
            $OutputPath
        ) | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue

        Set-Location -Path $PSScriptRoot
    }

    It 'does not download NuGet if not needed' {
        $Parameters = @(
            "-DSKIP_NUGET_DOWNLOAD=true"
            "-DTOOLCHAIN_TOOLS_PATH=$ToolsPath"
        )

        $Null = & $CMake --preset windows @Parameters
        $LastExitCode | Should -Be 0

        $CMakeCachePath = Join-Path -Path $OutputPath -ChildPath windows/CMakeCache.txt
        $CMakeCachePath | Should -Exist
        $ToolsNuGetPath | Should -Not -Exist
    }

    It 'does not download NuGet if it is found in the path' {
        StashEnvironment Path {
            $Parameters = @(
                "-DTOOLCHAIN_TOOLS_PATH=$ToolsPath"
            )

            $env:Path = $DownloadPath
            $Null = & $CMake --preset windows @Parameters --log-level=verbose
            $LastExitCode | Should -Be 0

            $CMakeCachePath = Join-Path -Path $OutputPath -ChildPath windows/CMakeCache.txt
            $CMakeCachePath | Should -Exist
            $ToolsNuGetPath | Should -Not -Exist
        }
    }

    It 'does not download NuGet if it is not in the path or specified, and TOOLCHAIN_TOOLS_PATH is not set' {
        StashEnvironment Path {
            $env:Path = ''

            # With no NuGet to be found, and TOOLCHAIN_TOOLS_PATH not set, the build should fail.
            $Null = & $CMake --preset windows 2>&1
            $LastExitCode | Should -Be 1
        }
    }

    It 'downloads NuGet if it is not in the path or specified, and TOOLCHAIN_TOOLS_PATH is set' {
        StashEnvironment Path {
            $env:Path = ''

            # With no NuGet to be found, but with TOOLCHAIN_TOOLS_PATH set, the build should succeed.
            $Parameters = @(
                "-DTOOLCHAIN_TOOLS_PATH=$ToolsPath"
            )

            $Null = & $CMake --preset windows @Parameters
            $LastExitCode | Should -Be 0

            $CMakeCachePath = Join-Path -Path $OutputPath -ChildPath windows/CMakeCache.txt
            $CMakeCachePath | Should -Exist
            $ToolsNuGetPath | Should -Exist

            Join-Path $OutputPath 'windows/__nuget/Humanizer.Core.2.14.1/Humanizer.Core.2.14.1.nupkg' |
                Should -Exist

            $CMakeCachePath |
                Get-CMakeCacheVariable -EntryName NUGET_PATH |
                Select-Object -ExpandProperty Value |
                Canonicalize-Path |
                Should -Be $ToolsNuGetPath
        }
    }

    It 'honors the PACKAGESAVEMODE' {
        # Switch to the 'nuspec' PACKAGESAVEMODE.
        $Parameters = @(
            "-DTOOLCHAIN_TOOLS_PATH=$ToolsPath"
            "-DSPECIFIED_PACKAGESAVEMODE=nuspec"
        )

        $Null = & $CMake --preset windows @Parameters
        $LastExitCode | Should -Be 0

        Join-Path $OutputPath 'windows/__nuget/Humanizer.Core.2.14.1/Humanizer.Core.nuspec' |
            Should -Exist
    }
}
