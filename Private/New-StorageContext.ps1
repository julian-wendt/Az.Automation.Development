function New-StorageContext {

    try {
        $Key = Get-AzStorageAccountKey @Global:AzStorageAccount | Select-Object -First 1 -ExpandProperty Value        
    }
    catch {
        throw "Failed to get storage account key. $PSItem"
    }

    try {
        $StorageAccountName = $Global:AzStorageAccount.AccountName
        New-AzStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $Key
    }
    catch {
        throw "Failed to setup storage context. $PSItem"
    }
}