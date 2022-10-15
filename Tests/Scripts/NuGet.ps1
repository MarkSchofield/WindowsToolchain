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

function Download-NuGet {
    param(
        [string] $OutputPath,
        $NuGetVersion = '6.3.1',
        $NuGetExecutableSha256Hash = '046632DFCF4C78787A396C2A55E070808592FF1EDED9340E645991E7A4DC5CC4'
    )
    $NuGetUrl = "https://dist.nuget.org/win-x86-commandline/v$NuGetVersion/nuget.exe"
    $NuGetExecutablePath = Join-Path -Path $OutputPath -ChildPath 'nuget.exe'

    if (-not (IsUpToDate $NuGetExecutablePath)) {
        DownloadFile $NuGetUrl $NuGetExecutablePath
        if ($NuGetExecutableSha256Hash -ne (Get-FileHash -Path $NuGetExecutablePath -Algorithm SHA256).Hash) {
            Remove-Item -Force -Path $NuGetExecutablePath
            Write-Error "Invalid Hash"
        }
    }
    Get-Item -Path $NuGetExecutablePath
}
