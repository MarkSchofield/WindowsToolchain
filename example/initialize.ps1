#----------------------------------------------------------------------------------------------------------------------
#
#----------------------------------------------------------------------------------------------------------------------
#Requires -PSEdition Core

[CmdletBinding()]
param (
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

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

function DownloadFile([string] $Url, [string] $DownloadPath) {
    (New-Object -TypeName System.Net.WebClient).
        DownloadFile($Url, $DownloadPath)
}

function CreateDirectory($Path) {
    if (-not (Test-Path -Path $Path -PathType Container)) {
        $null = mkdir -Path $Path
    }
}

function Touch($Item) {
    Write-Verbose "Touch: $Item"
    (Get-Item $Item).LastWriteTime = Get-Date
}

$SourcePath = $PSScriptRoot
$ToolsPath = Join-Path -Path $SourcePath -ChildPath __tools

CreateDirectory $ToolsPath

# Get NuGet
$NuGetVersion = '6.0.0'
$NuGetUrl = "https://dist.nuget.org/win-x86-commandline/v$NuGetVersion/nuget.exe"
$NuGetExecutableSha256Hash = '04EB6C4FE4213907E2773E1BE1BBBD730E9A655A3C9C58387CE8D4A714A5B9E1'
$NuGetOutputPath = Join-Path -Path $ToolsPath -ChildPath 'nuget.exe'

if (-not (IsUpToDate $NuGetOutputPath)) {
    Write-Output "Installing NuGet $NuGetVersion"
    DownloadFile $NuGetUrl $NuGetOutputPath
    $Hash = (Get-FileHash -Path $NuGetOutputPath -Algorithm SHA256).Hash
    if ($NuGetExecutableSha256Hash -ne $Hash) {
        Remove-Item -Force -Path $NuGetOutputPath
        Write-Error "Invalid Hash ($Hash)"
    }
}
