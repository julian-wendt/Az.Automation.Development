function Get-AzureRunbook {
    param(
        [Parameter(Mandatory = $false)]
        [string]$Name,

        [Parameter(Mandatory = $false)]
        [switch]$Published
    )

    try {
        $AllRunbooks = (Get-AzAutomationRunbook @Global:AzAutomationAccount).Name
    }
    catch {
        throw "Failed to list runbooks. $PSItem"
    }

    # Enrich single runbook details
    $Runbooks = foreach ($Runbook in $AllRunbooks) {
        try {
            Get-AzAutomationRunbook @Global:AzAutomationAccount -Name $Runbook
        }
        catch {
            throw "Failed to request details for runbook '$Runbook'. $PSItem"
        }
    }
    
    if ($Name) {
        $Runbooks = $Runbooks | Where-Object { $_.Name -eq $Name }
    }

    if ($Published.IsPresent) {
        $Runbooks = $Runbooks | Where-Object { $_.State -eq 'Published' }
    }

    $WriteLabel = @{Name = "LastWriteTime"; Expression = { $_.LastModifiedTime.DateTime } }
    $HashLabel = @{Name = "Hash"; Expression = { $_.Description } }
    
    return ($Runbooks | Select-Object -Property Name, State, $WriteLabel, $HashLabel)
}