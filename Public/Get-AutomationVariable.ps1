function Get-AutomationVariable {
    <#
    .SYNOPSIS
    Emulates "Get-AutomationVariable" from Azure Automation Account.
    
    .DESCRIPTION
    Intended for Azure Automation Runbook development on local machines, this function emulates the built-in Automation function "Get-AutomationVariable".
    Therefore the "Microsoft.PowerShell.SecretManagement" module is used to safely return sensitive information like secrets or keys. To store them, simply
    use the Set-Secret command". Less sensitive information can also be stored next to the environment details in the settings file.

    Set-Secret: https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.secretmanagement/set-secret?view=ps-modules

    .PARAMETER Name
    Automation variable name.
    
    .EXAMPLE
    Get-AutomationVariable -Name 'AppId'
    #>

    [Alias('Get-AutomationPSCredential')]
    param(
        [Parameter(Mandatory)]
        [string]$Name
    )

    $ErrorActionPreference = 'Stop'

    $Output = $null

    $PrdName = 'Prd' + $Name

    # Return value from environment settings
    $Variables = (Get-Variable -Scope 'Global').Name
    if ('EnvironmentSettings' -in $Variables) {
        if ($Global:EnvironmentSettings.$Name) {
            $Output = $Global:EnvironmentSettings.$Name

            if ($Global:UseProductiveValues -and $Global:EnvironmentSettings.$PrdName) {
                $Output = $Global:EnvironmentSettings.$PrdName
            }
        }
    }
    
    # Return value from vault
    $Secrets = Get-SecretInfo
    if ($Name -in $Secrets.Name) {
        $Output = Get-Secret -Name $Name -AsPlainText

        if ($Global:UseProductiveValues -and $PrdName -in $Secrets.Name) {
            $Output = Get-Secret -Name $PrdName -AsPlainText
        }
    }

    if ($null -ne $Output) {
        return $Output
    }
    
    Write-Error -Message "No variable with name '$name' found."
}