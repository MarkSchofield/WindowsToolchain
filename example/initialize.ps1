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

# Get Ninja
$NinjaVersion = '1.10.2'
$NinjaArchivePath = Join-Path -Path $ToolsPath -ChildPath 'ninja-win.zip'
$NinjaArchiveSha256Hash = 'BBDE850D247D2737C5764C927D1071CBB1F1957DCABDA4A130FA8547C12C695F'
$NinjaOutputPath = Join-Path -Path $ToolsPath -ChildPath 'ninja'
$NinjaExecutablePath = Join-Path -Path $NinjaOutputPath -ChildPath 'ninja.exe'

if (-not (IsUpToDate $NinjaExecutablePath $NinjaArchivePath)) {
    Write-Output "Installing Ninja $NinjaVersion"
    if (-not (IsUpToDate $NinjaArchivePath)) {
        DownloadFile "https://github.com/ninja-build/ninja/releases/download/v$NinjaVersion/ninja-win.zip" $NinjaArchivePath
        if ($NinjaArchiveSha256Hash -ne (Get-FileHash -Path $NinjaArchivePath -Algorithm SHA256).Hash) {
            Remove-Item -Force -Path $NinjaArchivePath
            Write-Error "Invalid Hash"
        }
    }
    Expand-Archive -Path $NinjaArchivePath -DestinationPath $NinjaOutputPath -Force
    Touch $NinjaExecutablePath
}
