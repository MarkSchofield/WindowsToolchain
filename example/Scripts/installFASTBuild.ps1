#----------------------------------------------------------------------------------------------------------------------
#
#----------------------------------------------------------------------------------------------------------------------
#Requires -PSEdition Core

[CmdletBinding()]
param (
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$FastBuildVersion = "1.18"
$FastBuildFileName = "FASTBuild-Windows-x64-v$FastBuildVersion.zip"
$FastBuildZipUrl = "https://www.fastbuild.org/downloads/v$FastBuildVersion/$FastBuildFileName"
$DownloadFolder = Join-Path -Path $PSScriptRoot -ChildPath "../../__downloads"
$DownloadFile = Join-Path -Path $DownloadFolder -ChildPath $FastBuildFileName

$null = mkdir -Path $DownloadFolder -Force
Invoke-WebRequest -Uri $FastBuildZipUrl -OutFile $DownloadFile
Expand-Archive -Path $DownloadFile -DestinationPath $DownloadFolder -Force

$DownloadFolder
