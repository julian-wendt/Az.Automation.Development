function Test-AutomationSettings {
    
    $Properties = 'AzSubscription', 'AzAutomationAccount', 'AzStorageAccount', 'LocalRunbookPath', 'LocalModulePath'
    $Variables = (Get-Variable -Scope 'Global').Name

    $Missing = foreach ($Property in $Properties) {
        if ($Property -notin $Variables) {
            $Property
        }
    }

    if ($null -eq $Missing) {
        return $null
    }
    
    throw "Environment settings missing: $($Missing -join ', ')."
}