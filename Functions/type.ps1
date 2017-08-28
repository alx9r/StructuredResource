function Test-Type
{
    [CmdletBinding()]
    param
    (
        [Parameter(Position = 1,
                   Mandatory = $true)]
        [System.Reflection.TypeInfo]
        $Expected,

        [Parameter(ValueFromPipeline = $true,
                   Mandatory = $true)]
        [System.Reflection.TypeInfo]
        $Actual
    )
    process
    {
        $Expected.IsEquivalentTo($Actual)
    }
}

function Assert-Type
{
    [CmdletBinding()]
    param
    (
        [Parameter(ParameterSetName = 'affirmative',
                   Position = 1,
                   Mandatory = $true)]
        [System.Reflection.TypeInfo]
        $Expected,

        [Parameter(ParameterSetName = 'negative')]
        $not,

        [Parameter(ValueFromPipeline = $true,
                   Mandatory = $true)]
        [System.Reflection.TypeInfo]
        $Actual
    )
    process
    {
        $_expected = $Expected,$not | ? {$_}

        if
        ( 
            ( $Actual | Test-Type $_expected ) -xor
            ( $PSCmdlet.ParameterSetName -eq 'negative' )
        )
        {
            return
        }

        if ( $PSCmdlet.ParameterSetName -eq 'affirmative' )
        {
            throw "Expected type $_expected, was type $Actual."
        }

        throw "Type was $Actual."
    }
}