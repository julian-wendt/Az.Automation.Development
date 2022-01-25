function Merge-Objects {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [System.Object]$Object1,

        [Parameter(Mandatory = $true)]
        [System.Object]$Object2
    )
    
    $Output = [ordered]@{}

    foreach ($Property in $Object1.PSObject.Properties) {
        $Output.Add($Property.Name, $Property.Value)
    }

    foreach ($Property in $Object2.PSObject.Properties) {
        if ($Property.Name -in $Output.Keys) {
            $Output.($Property.Name) = $Property.Value
        }
    }

    # Return object
    return ($Output | ConvertTo-Object)
}