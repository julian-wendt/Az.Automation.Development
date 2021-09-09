function Publish-AzureRunbook {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    try {
        Publish-AzAutomationRunbook @Global:AzAutomationAccount -Name $Name
    }
    catch {
        throw "Failed to publish runbook. $PSItem"
    }
}