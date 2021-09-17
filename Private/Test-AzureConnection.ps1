function Test-AzureConnection {

    $Variables = (Get-Variable -Scope 'Global').Name
    
    # No connection found
    if ('AzAccountConnected' -notin $Variables) {
        Write-Warning -Message 'Not connected to Azure.'
        return
    }

    # Existing connection older than 1 hour
    if ((New-TimeSpan -Start ($Global:AzAccountConnected) -End (Get-Date)).Hours -gt 1) {
        Write-Warning -Message 'Not connected to Azure.'
        return
    }
    
    return $Global:AzAccountConnected
}