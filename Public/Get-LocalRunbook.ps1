function Get-LocalRunbook {
    param(
        [Parameter(Mandatory = $false)]
        [string]$Name
    )

    try {
        $Runbooks = Get-ChildItem -Path $Global:LocalRunbookPath -File -Filter '*.ps1'
    }
    catch {
        throw "Failed to list local runbooks. $PSItem"
    }

    if ($Name) {
        $Name = $Name.ToLower().Trim()
        $Runbooks = $Runbooks | Where-Object { $_.BaseName.ToLower().Trim() -eq $Name }
    }


    return ($Runbooks | Select-Object -Property @{Name = "Name"; Expression = { $_.BaseName } }, LastWriteTime, FullName)
}