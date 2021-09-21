function Update-AutomationModule {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$Name,

        [Parameter(Mandatory = $false)]
        [switch]$Create,

        [Parameter(Mandatory = $false)]
        [switch]$AllowDowngrade
    )

    try {
        $LocalModules = Get-AutomationModule -Local
        $AzureModules = Get-AutomationModule -Azure
    }
    catch {
        Write-Error -Message "Failed to list modules. $PSItem"
    }

    # Pick module passed to function, remove other
    if (-not [string]::IsNullOrEmpty($Name)) {
        $Name = $Name.ToLower().Trim()

        if ($Name -notin $LocalModules.Name.ToLower()) {
            throw "Local runbook not found."
        }

        $LocalModules = $LocalModules | Where-Object { $_.Name.ToLower() -eq $Name }
    }

    foreach ($LocalModule in $LocalModules) {

        $Name, $AzureModule, $ArchivePath, $ModuleFiles = $null
        $Name = $LocalModule.Name

        # Check if module exist in Azure
        if ($LocalModule.Name -notin $AzureModules.Name -and $Create.IsPresent -eq $false) {
            Write-Warning -Message "Module '$Name' not exist in Azure. Use -Create to create a new module."
            continue
        }

        # Compare version in module manifests
        $AzureModule = $AzureModules | Where-Object { $_.Name -eq $LocalModule.Name }
        if ($LocalModule.Version -le $AzureModule.Version -and $AllowDowngrade.IsPresent -eq $false) {
            Write-Host -Message "Module '$Name' is up-to-date (Version)." -ForegroundColor 'Green'
            continue
        }

        try {
            # Generate zip file including all required module files
            $Path = Compress-ModuleFiles -Path $LocalModule.FullName -Version $LocalModule.Version
            
            # Upload zipped archive to storage account
            $Uri = New-StorageBlob -Path $Path -Container $Global:AzModulesContainer -ReturnUri
            
            # Install automation module in automation account
            New-AzAutomationModule @Global:AzAutomationAccount -Name $LocalModule.Name -ContentLinkUri $Uri | Out-Null

            # Remove zipped module
            Remove-Item -Path $Path -Force
        }
        catch {
            throw "Failed to update automation module. $PSItem"
        }

        Write-Host 'Done.'
    }
}