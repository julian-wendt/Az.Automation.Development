function ConvertTo-Object {
    Begin {
        $Object = New-Object -TypeName 'Object'
    }
    
    Process {
        $_.GetEnumerator() | ForEach-Object {
            Add-Member -InputObject $Object -MemberType NoteProperty -Name $_.Name -Value $_.Value
        }  
    }
    
    End {
        return $Object
    }
}