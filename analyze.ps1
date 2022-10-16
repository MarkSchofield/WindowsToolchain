<#====================================================================================================================#
Runs cmake-lint on all `.cmake` files in the Git repository
=====================================================================================================================#>
$Root = $PSScriptRoot

function IsGitHubAction {
    $env:GITHUB_ACTIONS -eq 'true'
}

function ReportError([string] $File, [string] $LineNumber, [string] $Message) {
    if (IsGitHubAction) {
        Write-Output "::error file=$File,line=$LineNumber::$Message"
    } else {
        Write-Output $Message
    }
}

$Git = Get-Command git -ErrorAction SilentlyContinue
if (-not $Git) {
    Write-Error "Unable to find 'git'."
}

$CMakeLint = Get-Command cmake-lint -ErrorAction SilentlyContinue
if (-not $CMakeLint) {
    Write-Error "Unable to find 'cmake-lint'."
}

$Failed = $false;
$CMakeFiles = & $Git ls-files "$Root/*.cmake"

foreach ($CMakeFile in $CMakeFiles) {
    & $CMakeLint $CMakeFile |
    ForEach-Object {
        if ($_ -match '^([^:]*):(\d+):(.*)$') {
            ReportError -File $Matches[1] -LineNumber $Matches[2] -Message $_
            $Failed = $true
        }
        else {
            Write-Output $_
        }
    }
}

exit ($Failed ? 1 : 0)
