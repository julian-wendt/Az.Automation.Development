function Compress-ModuleFiles {

    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $false)]
        [string]$Version
    )

    $Extensions = '*.ps1', '*.psd1', '*.psm1'

    # Setup archive path
    $ArchiveName = Split-Path -Path $Path -Leaf
    $ArchivePath = Split-Path -Path $Path -Parent
    $ArchivePath = $ArchivePath + '\' + $ArchiveName + '.zip'

    # Add version to file name
    if (-not [string]::IsNullOrEmpty($Version)) {
        $ArchivePath = $ArchivePath -replace '.zip', "-$Version.zip"
    }

    try {
        $ModuleFiles = Get-Item -Path $Path | Get-ChildItem -Recurse -Include $Extensions
    }
    catch {
        throw "Failed to collect all required module files. $PSItem"
    }

    try {
        $ModuleFiles | Compress-Archive -DestinationPath $ArchivePath -Force
    }
    catch {
        throw "Failed to compress module. $PSItem"
    }
    
    return $ArchivePath
}