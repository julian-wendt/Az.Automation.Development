function Update-AzureRunbook {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$Name,

        [Parameter(Mandatory = $false)]
        [switch]$Create,

        [Parameter(Mandatory = $false)]
        [switch]$Publish,

        [Parameter(Mandatory = $false)]
        [string]$Type = 'PowerShell'
    )

    try {
        Write-Verbose -Message 'Get local runbooks...'
        $LocalRunbooks = Get-LocalRunbook

        Write-Verbose -Message 'Request Azure runbooks...'
        $AzureRunbooks = Get-AzureRunbook
    }
    catch {
        throw "Runbook lookup failed. $PSItem"
    }

    if ($null -ne $Name) {
        $Name = $Name -replace '.ps1'
        $Name = $Name.ToLower().Trim()

        if ($Name -notin $LocalRunbooks.Name) {
            throw "Local runbook not found."
        }

        # If $Name is not empty, remove other found runbooks from list
        $LocalRunbooks = $LocalRunbooks | Where-Object { $_.Name.ToLower() -eq $Name }
    }

    foreach ($LocalRunbook in $LocalRunbooks) {

        $Name, $Path, $Hash, $AzureRunbook, $RunbookParams = $null

        # Prepare strings
        $Name = $LocalRunbook.Name.ToLower().Trim()
        $Path = $LocalRunbook.FullName.ToLower().Trim()

        Write-Verbose -Message "Process runbook '$Name'"

        # Create file hash
        $Hash = (Get-FileHash -Path $LocalRunbook.FullName).Hash

        # Check if local runbook exists in Azure
        if ($LocalRunbook.Name -notin $AzureRunbooks.Name -and $Create.IsPresent -eq $false) {
            Write-Warning -Message "Runbook '$Name' not exist in Azure. Use parameter -Create to upload new runbooks."
            continue
        }

        # Get Azure runbook to compare LastWriteTime
        $AzureRunbook = $AzureRunbooks | Where-Object { $_.Name -eq $LocalRunbook.Name }
        if ($LocalRunbook.LastWriteTime -le $AzureRunbook.LastWriteTime) {
            Write-Host -Message "Runbook '$Name' is up-to-date (WriteTime)." -ForegroundColor 'Green'
            continue
        }

        # Compare file hashes. Skip upload on match.
        if ($AzureRunbook.Hash -and $AzureRunbook.Hash -eq $Hash) {
            Write-Host -Message "Runbook '$Name' is up-to-date (FileHash)." -ForegroundColor 'Green'
            continue
        }

        $RunbookParams = @{
            Name        = $Name
            Path        = $Path
            Type        = $Type
            Description = $Hash
        }

        if ($Publish.IsPresent) {
            $RunbookParams.Add('Publish', $true)
        }

        try {
            Import-AzAutomationRunbook @Global:AzAutomationAccount @RunbookParams -Force | Out-Null
        }
        catch {
            throw "Failed to import runbook into Azure. $PSItem"
        }
    }
}