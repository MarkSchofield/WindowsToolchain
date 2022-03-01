#----------------------------------------------------------------------------------------------------------------------
#
#----------------------------------------------------------------------------------------------------------------------
#Requires -PSEdition Core

[CmdletBinding()]
param (
    [ValidateSet('windows-clang-x64', 'windows-msvc-arm64', 'windows-msvc-x64', 'windows-msvc-x86')]
    $Presets = @('windows-clang-x64', 'windows-msvc-arm64', 'windows-msvc-x64', 'windows-msvc-x86')
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

$Configurations = @(
    'Debug'
    'Release'
    'RelWithDebInfo'
)

foreach ($Preset in $Presets) {
    & $CMake --preset $Preset

    foreach ($Configuration in $Configurations) {
        & $CMake --build --preset $Preset --config $Configuration
    }
}
