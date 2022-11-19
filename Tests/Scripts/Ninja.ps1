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

function Download-Ninja {
    param(
        [string] $OutputPath,
        $NinjaVersion = '1.10.2',
        $NinjaArchiveSha256Hash = 'BBDE850D247D2737C5764C927D1071CBB1F1957DCABDA4A130FA8547C12C695F'
    )
    $NinjaArchiveUrl = "https://github.com/ninja-build/ninja/releases/download/v$NinjaVersion/ninja-win.zip"
    $NinjaArchivePath = Join-Path -Path $OutputPath -ChildPath 'ninja-win.zip'
    $NinjaExecutablePath = Join-Path -Path $OutputPath -ChildPath 'ninja.exe'

    if (-not (IsUpToDate $NinjaExecutablePath $NinjaArchivePath)) {
        Write-Verbose "Installing Ninja $NinjaVersion"
        if (-not (IsUpToDate $NinjaArchivePath)) {
            DownloadFile $NinjaArchiveUrl $NinjaArchivePath
            if ($NinjaArchiveSha256Hash -ne (Get-FileHash -Path $NinjaArchivePath -Algorithm SHA256).Hash) {
                Remove-Item -Force -Path $NinjaArchivePath
                Write-Error "Invalid Hash"
            }
        }
        Expand-Archive -Path $NinjaArchivePath -DestinationPath $OutputPath -Force
        Touch $NinjaExecutablePath
    }
    Get-Item -Path $NinjaExecutablePath
}
