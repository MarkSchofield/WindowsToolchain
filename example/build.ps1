#----------------------------------------------------------------------------------------------------------------------
#
#----------------------------------------------------------------------------------------------------------------------
#Requires -PSEdition Core

[CmdletBinding()]
param (
    [ValidateSet('windows-ninja-msvc-x64', 'windows-ninja-msvc-x64-spectre', 'windows-ninja-msvc-x86',
        'windows-ninja-msvc-arm64', 'windows-ninja-msvc-host', 'windows-ninja-clang-x64',
        'windows-ninja-clangcl-x64', 'windows-fastbuild-msvc-x64', 'windows-vs2022-x64',
        'windows-vs2022-arm64')]
    $Presets = @('windows-ninja-msvc-host'),

    [ValidateSet('Debug', 'Release', 'RelWithDebInfo')]
    $Configurations = @('Debug')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$CMake = Get-Variable -Name 'CMake' -ValueOnly -Scope global -ErrorAction SilentlyContinue
if (-not $CMake) {
    $CMakeCandidates = @(
        (Get-Command 'cmake' -ErrorAction SilentlyContinue)
        if ($IsWindows) {
            (Join-Path -Path $env:ProgramFiles -ChildPath 'CMake/bin/cmake.exe')
        }
    )
    foreach ($CMakeCandidate in $CMakeCandidates) {
        $CMake = Get-Command $CMakeCandidate -ErrorAction SilentlyContinue
        if ($CMake) {
            $global:CMake = $CMake
            break
        }
    }

    if (-not $CMake) {
        Write-Error "Unable to find CMake."
    }
}

foreach ($Preset in $Presets) {
    & $CMake --preset $Preset

    foreach ($Configuration in $Configurations) {
        & $CMake --build --preset $Preset --config $Configuration
    }
}
