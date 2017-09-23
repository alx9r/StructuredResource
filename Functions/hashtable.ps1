function Get-HashtableKey
{
    param
    (
        [Parameter(Position = 1)]
        $KeyName,
        
        [Parameter(ValueFromPipeline,
                   Mandatory)]
        $Hashtable
    )
    process
    {
        if ( $PSBoundParameters.ContainsKey('KeyName') )
        {
            return $Hashtable.get_Keys() -eq $KeyName
        }
        $Hashtable.get_Keys()
    }
}

# function Test-HashtableKey
Get-Command Get-HashtableKey |
    New-Tester -NoValue |
    Invoke-Expression

# function Assert-HashtableKey
Get-Command Test-HashtableKey |
    New-Asserter 'Key $KeyName not found.' |
    Invoke-Expression