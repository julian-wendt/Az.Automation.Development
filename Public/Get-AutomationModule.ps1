function Get-AutomationModule {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$Name,

        [Parameter(Mandatory = $false)]
        [switch]$Azure,

        [Parameter(Mandatory = $false)]
        [switch]$Local
    )

    $ErrorActionPreference = 'Stop'

    $Modules = $null

    if ($Local.IsPresent) {
        try {
            $Modules = Get-ChildItem -Path $Global:LocalModulePath -Exclude '*.zip'
            $Modules = $Modules | Select-Object -Property Name, LastWriteTime, FullName

            foreach ($Module in $Modules) {
                
                $Version = $null
                
                try {
                    $Version = (Get-Module -Name $Module.FullName -ListAvailable).Version
                    $Module | Add-Member -NotePropertyName 'Version' -NotePropertyValue $Version
                }
                catch {
                    throw "Failed to add module version. $PSItem"
                }
            }
        }
        catch {
            throw "Failed to list local modules. $PSItem"
        }
    }
    
    if ($Azure.IsPresent -or $Local.IsPresent -eq $false) {
        try {
            $Modules = Get-AzAutomationModule @Global:AzAutomationAccount
            $Modules = $Modules | Select-Object -Property Name, Version, @{
                Name       = 'LastWriteTime'
                Expression = { $_.LastModifiedTime.DateTime }
            }
        }
        catch {
            throw "Failed to list modules in Azure. $PSItem"
        }
    }

    if (-not [string]::IsNullOrEmpty($Name)) {
        $Name = $Name.ToLower().Trim()
        $Modules = $Modules | Where-Object { $_.Name.ToLower().Trim() -eq $Name }
    }

    return $Modules
}