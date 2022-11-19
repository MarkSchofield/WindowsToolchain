#----------------------------------------------------------------------------------------------------------------------
# MIT License
#
# Copyright (c) 2021 Mark Schofield
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#----------------------------------------------------------------------------------------------------------------------
#Requires -PSEdition Core

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. $PSScriptRoot/Common.ps1

. $PSScriptRoot/CMake.ps1
. $PSScriptRoot/Ninja.ps1
. $PSScriptRoot/NuGet.ps1

$CMake = "$env:ProgramFiles/CMake/bin/cmake.exe"
$DownloadPath = Join-Path -Path $PSScriptRoot -ChildPath __download
$DownloadNinjaPath = Join-Path -Path $DownloadPath -ChildPath ninja.exe
$DownloadNuGetPath = Join-Path -Path $DownloadPath -ChildPath nuget.exe

function EnsureAvailableTools {
    # Ensure that the $DownloadPath directory exists
    $Null = New-Item -Path $DownloadPath -ItemType Directory -ErrorAction SilentlyContinue

    # Get Ninja.
    if (-not (Test-Path -Path $DownloadNinjaPath)) {
        $Null = Download-Ninja -OutputPath $DownloadPath
    }

    # Get NuGet.
    if (-not (Test-Path -Path $DownloadNuGetPath)) {
        $Null = Download-NuGet -OutputPath $DownloadPath
    }
}
