function New-StorageBlob {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [string]$Container,

        [Parameter(Mandatory = $false)]
        [switch]$ReturnUri
    )

    begin {
        $Variables = (Get-Variable -Scope 'Global').Name
        if ('StorageContext' -notin $Variables) {
            Write-Verbose -Message 'Setting up storage context...'
            $Global:StorageContext = New-StorageContext
        }

        # Get file name from path
        $Name = Split-Path -Path $Path -Leaf
    }

    process {
        try {
            # Upload file as Azure storage blob
            $Blob = Set-AzStorageBlobContent -Context $Global:StorageContext -File $Path -Container $Container -Blob $Name -Force
        }
        catch {
            throw "Failed to add new storage blob. $PSItem"
        }

        if ($ReturnUri.IsPresent) {
            try {
                # Create read-only SAS uri with expiration after 1 hour
                $Blob | New-AzStorageBlobSASToken -FullUri -Permission 'r' -Protocol 'HttpsOnly' -ExpiryTime (Get-Date).AddDays(1)
            }
            catch {
                throw "Failed to create SAS uri. $PSItem"
            }   
        }
    }
}