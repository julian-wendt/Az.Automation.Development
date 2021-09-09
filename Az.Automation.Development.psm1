Set-StrictMode -Version 'Latest'

if (Test-Path -Path "$PSScriptRoot\Public") {
    $Public = Get-ChildItem -Path "$PSScriptRoot\Public\*.ps1"
}

if (Test-Path -Path "$PSScriptRoot\Private") {
    $Private = Get-ChildItem -Path "$PSScriptRoot\Private\*.ps1"
}

$Public + $Private | ForEach-Object {
    try {
        Import-Module -Name $_.FullName -ErrorAction 'Stop'
    }
    catch {
        Write-Error -Message "Failed to import function. $PSItem" -ErrorAction 'Stop'
    }
}