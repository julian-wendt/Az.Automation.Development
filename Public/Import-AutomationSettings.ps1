function Import-AutomationSettings {

    # Suppress notifications about declared unused vars
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '', Scope = 'Function')]

    param (
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $false)]
        [switch]$Productive
    )

    try {

        if ((Test-Path -Path $Path -IsValid) -eq $false) {
            throw "File not found."
        }

        $Settings = Get-Content -Path $Path -Raw | ConvertFrom-Json
    }
    catch {
        throw "Failed to import automation environment settings. $PSItem"
    }

    if ($Productive.IsPresent) {
        # Overwrite common settings with settings from the productive tree
        $Settings = Merge-Objects -Object1 $Settings -Object2 $Settings.ProductiveEnvironment
    }
    
    $Global:AzSubscription = @{
        TenantId       = $Settings.TenantId
        SubscriptionId = $Settings.SubscriptionId
    }
    
    $Global:AzAutomationAccount = @{
        ResourceGroupName     = $Settings.ResourceGroupName
        AutomationAccountName = $Settings.AutomationAccountName
    }
 
    $Global:AzStorageAccount = @{
        ResourceGroupName = $Settings.ResourceGroupName
        AccountName       = $Settings.StorageAccountName
    }

    $Global:AzModulesContainer = $Settings.StorageContainers.Modules
    $Global:AzQueriesContainer = $Settings.StorageContainers.Queries

    $Global:LocalRunbookPath = $Settings.LocalDirectories.Runbooks
    $Global:LocalModulePath = $Settings.LocalDirectories.Modules
}