function Connect-AzureSubscription {

    try {
        Test-AutomationSettings
    }
    catch {
        throw "Failed to connect to Azure. $PSItem"
    }

    if (Test-AzureConnection) {
        Write-Host "Already connected to Azure." -ForegroundColor 'Green'
    }
    else {
        try {
            Connect-AzAccount @Global:AzSubscription | Out-Null
            Save-AzureConnection
        }
        catch {
            throw "Failed to authenticate on Azure. $PSItem"
        }
    }
}