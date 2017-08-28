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

function Test-ValueType
{
    param
    (
        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true)]
        [System.Reflection.TypeInfo]
        $TypeInfo
    )
    process
    {
        $TypeInfo.IsValueType
    }
}

function Assert-ValueType
{
    param
    (
        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true)]
        [System.Reflection.TypeInfo]
        $TypeInfo
    )
    process
    {
        if ( $TypeInfo | Test-ValueType )
        {
            return
        }
        throw "$TypeInfo is not a value type."
    }
}

function Assert-NotValueType
{
    param
    (
        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true)]
        [System.Reflection.TypeInfo]
        $TypeInfo
    )
    process
    {
        if ( -not ($TypeInfo | Test-ValueType) )
        {
            return
        }
        throw "$TypeInfo is a value type."
    }
}

function Test-NullableType
{
    param
    (
        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true)]
        [System.Reflection.TypeInfo]
        $TypeInfo
    )
    process
    {
        if ( -not ($TypeInfo | Test-ValueType) )
        {
            return $true
        }
        if 
        (
            $TypeInfo.IsGenericType -and
            $TypeInfo.GetGenericTypeDefinition().Name -eq 'Nullable`1'
        )
        {
            return $true
        }

        return $false
    }
}

function Assert-NullableType
{
    param
    (
        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true)]
        [System.Reflection.TypeInfo]
        $TypeInfo
    )
    process
    {
        if ( $TypeInfo | Test-NullableType )
        {
            return
        }

        throw "$TypeInfo is not nullable."
    }
}