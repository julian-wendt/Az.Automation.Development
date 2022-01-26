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

    # Get global environment settings
    $EnvironmentSettings = $Global:EnvironmentSettings |
        Get-Member -MemberType NoteProperty

    $Output = $null

    # Use value from environment settings
    if ($Name -in $EnvironmentSettings.Name) {
        Write-Verbose -Message "Use '$Name' from environment settings." -Verbose
        $Output = $Global:EnvironmentSettings.$Name
    }
    
    # Use value from vault
    $Secrets = Get-SecretInfo
    if ($Name -in $Secrets.Name) {
        Write-Verbose -Message "Use '$Name' from secret store. Overwrite existing." -Verbose
        $Output = Get-Secret -Name $Name -AsPlainText

        # Setup productive property name. This will be used if
        # environment settings have been loaded using -Productive switch.
        $ProductiveName = ($Name + '_Prd').ToString()
        if ($Global:UseProductiveValues -eq $true -and $ProductiveName -in $Secrets.Name) {
            Write-Verbose -Message 'Found productive value. Overwrite existing.' -Verbose
            $Output = Get-Secret -Name $ProductiveName -AsPlainText
        }
    }

    if ($null -ne $Output) {
        return $Output
    }
    
    Write-Error -Message "No variable with name '$name' found."
}