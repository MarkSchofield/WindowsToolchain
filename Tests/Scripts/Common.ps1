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

function Canonicalize-Path() {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0)]
        $Path
    )
    [System.IO.Path]::GetFullPath($Path)
}

function Get-MemberValue {
    [CmdletBinding()]
    param(
        $InputObject,
        $Name,
        $Or = $null
    )
    (Select-Object -InputObject $InputObject -ExpandProperty $Name -ErrorAction SilentlyContinue) ?? $Or
}

<#
 .Synopsis
  Checks whether the given file is newer than any subsequently specified files.
#>
function IsUpToDate($Target) {
    $Dependencies = $args

    $TargetItem = Get-Item -Path $Target -ErrorAction SilentlyContinue
    if (-not $TargetItem) {
        return $false;
    }

    foreach ($Dependency in $Dependencies) {
        $DependentItem = Get-Item -Path $Dependency -ErrorAction SilentlyContinue
        if ((-not $DependentItem) -or ($DependentItem.LastWriteTime -gt $TargetItem.LastWriteTime)) {
            return $false;
        }
    }

    $true
}

function Using-Location($Location, $Scriptlet) {
    Push-Location -Path $Location
    try {
        & $Scriptlet
    } finally {
        Pop-Location
    }
}

function StashEnvironment($Name, $Scriptlet) {
    $Value = Get-Item -Path "env:$Name" |
        Select-Object -ExpandProperty Value
    try {
        & $Scriptlet
    } finally {
        Set-Item -Path "env:$Name" -Value $Value
    }
}

function Touch($Item) {
    Write-Verbose "Touch: $Item"
    (Get-Item $Item).LastWriteTime = Get-Date
}

function DownloadFile([string] $Url, [string] $DownloadPath) {
    [System.Net.WebClient]::new().DownloadFile($Url, $DownloadPath)
}

<#
 .Synopsis
  Searches the given location and parent folders looking for the given file.
#>
function GetPathOfFileAbove([string]$Location, [string]$File) {
    for (; $Location.Length -ne 0; $Location = Split-Path $Location) {
        if (Test-Path -PathType Leaf -Path (Join-Path -Path $Location -ChildPath $File)) {
            $Location
            break
        }
    }
}
