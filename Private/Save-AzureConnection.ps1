function Save-AzureConnection {
    # Suppress notifications about declared unused vars
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '', Scope = 'Function')]
    
    $Global:AzAccountConnected = Get-Date
}