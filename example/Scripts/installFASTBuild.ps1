#----------------------------------------------------------------------------------------------------------------------
#
#----------------------------------------------------------------------------------------------------------------------
#Requires -PSEdition Core

[CmdletBinding()]
param (
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$InformationPreference = 'Continue'

Write-Information "Downloading FASTBuild"

$FastBuildVersion = '1.20'
$FastBuildHash = 'FA44C85E037AFF4B8487237D9907F18A31B62E60423A806E5B2F30BD1B61865F'

$FastBuildFileName = "FASTBuild-Windows-x64-v$FastBuildVersion.zip"
$FastBuildZipUrl = "https://www.fastbuild.org/downloads/v$FastBuildVersion/$FastBuildFileName"
$DownloadFolder = Join-Path -Path $PSScriptRoot -ChildPath "../../__downloads"
$DownloadFile = Join-Path -Path $DownloadFolder -ChildPath $FastBuildFileName

$null = mkdir -Path $DownloadFolder -Force
$null = Invoke-WebRequest -Uri $FastBuildZipUrl -OutFile $DownloadFile

$ActualHash = (Get-FileHash -Algorithm SHA256 -Path $DownloadFile | Select-Object -ExpandProperty Hash)
if ($FastBuildHash -ne $ActualHash) {
    Write-Error "Downloaded file does not match expected hash.`n`tExpected: $FastBuildHash`n`tActual:   $ActualHash"
}

$null = Expand-Archive -Path $DownloadFile -DestinationPath $DownloadFolder -Force

$DownloadFolder
