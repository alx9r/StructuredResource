function Get-HashtableKey
{
    param
    (
        [Parameter(Position = 1,
                   Mandatory)]
        $KeyName,

        [Parameter(ValueFromPipeline,
                   Mandatory)]
        $Hashtable
    )
    process
    {
        $output = $Hashtable.get_Keys() -eq $KeyName
        try { $output }
        catch
        {
            throw [System.Exception]::new(
                "hashtable key $KeyName",
                $_.Exception
            )
        }
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

function Get-HashtableItem
{
    param
    (
        [Parameter(Position = 1,
                   Mandatory)]
        $KeyName,

        [Parameter(ValueFromPipeline,
                   Mandatory)]
        $Hashtable
    )
    process
    {
        $output = $Hashtable.get_Item($KeyName)
        try{$output}
        catch
        {
            throw [System.Exception]::new(
                "hashtable key $KeyName item $output",
                $_.Exception
            )
        }
    }
}

# function Test-HashtableItem
Get-Command Get-HashtableItem |
    New-Tester |
    Invoke-Expression

# function Assert-HashtableItem
Get-Command Test-HashtableItem |
    New-Asserter 'Hashtable item with key $KeyName has value $($Hashtable | Get-HashtableItem $Keyname) not $Value.' |
    Invoke-Expression
