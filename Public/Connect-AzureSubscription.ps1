function Connect-AzureSubscription {

    $ConsoleConnected = $false
    
    $Variables = (Get-Variable -Scope 'Global').Name
    if ('AzAccountConnected' -in $Variables) {

        $Start = $Global:AzAccountConnected
        if ((New-TimeSpan -Start $Start -End (Get-Date)).Hours -lt 1) {
            $ConsoleConnected = $true
        }
    }

    if ($ConsoleConnected -eq $true) {
        $TimeRemaining = $Global:AzAccountConnected.AddHours(1) - (Get-Date)
        return "Auth token still valid for about $($TimeRemaining.Minutes) minutes."
    }

    try {
        Connect-AzAccount @Global:AzSubscription | Out-Null
        $Global:AzAccountConnected = Get-Date
    }
    catch {
        throw "Failed to authenticate on Azure."
    }
}