#----------------------------------------------------------------------------------------------------------------------
#
#----------------------------------------------------------------------------------------------------------------------
#Requires -PSEdition Core

[CmdletBinding()]
param (
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

& winget upgrade kitware.cmake --source winget --verbose --accept-source-agreements --disable-interactivity
