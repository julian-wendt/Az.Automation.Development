function Import-AutomationSettings {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $false)]
        [switch]$Productive
    )

    try {
        $Global:EnvironmentSettings = Get-Content -Path $Path -Raw | ConvertFrom-Json
    }
    catch {
        throw "Failed to import automatin environment settings. $PSItem"
    }

    $Variables = (Get-Variable -Scope 'Global').Name

    if ('AzSubscription' -notin $Variables) {
        New-Variable -Name 'AzSubscription' -Scope 'Global' -Value @{
            TenantId       = $Global:EnvironmentSettings.TenantId
            SubscriptionId = $Global:EnvironmentSettings.SubscriptionId
        }
    }
    
    if ('AzAutomationAccount' -notin $Variables) {
        New-Variable -Name 'AzAutomationAccount' -Scope 'Global' -Value @{
            ResourceGroupName     = $Global:EnvironmentSettings.ResourceGroupName
            AutomationAccountName = $Global:EnvironmentSettings.AutomationAccountName
        }
    }

    if ('LocalRunbookPath' -notin $Variables) {
        New-Variable -Name 'LocalRunbookPath' -Scope 'Global' -Value $Global:EnvironmentSettings.LocalRunbookPath
    }

    # Replace default dev values with productive values
    if ($Productive.IsPresent -and $Global.AzAutomationAccount) {
        $Global:AzAutomationAccount.ResourceGroupName = $Global:EnvironmentSettings.PrdResourceGroupName
        $Global:AzAutomationAccount.AutomationAccountName = $Global:EnvironmentSettings.PrdAutomationAccountName
    }
}