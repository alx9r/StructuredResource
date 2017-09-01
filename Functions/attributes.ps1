function Get-AttributeArgument
{
    param
    (
        [Parameter(Mandatory,
                   Position = 1)]
        [string]
        $ArgumentName,

        [Parameter(Mandatory,
                   ValueFromPipeline)]
        [System.Attribute]
        $Attribute
    )
    process
    {
        $Attribute.$ArgumentName
    }
}

function Get-CustomAttributeArgument
{
    param
    (
        [Parameter(Position = 1)]
        [string]
        $ArgumentName,

        [switch]
        $ValueOnly,

        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true)]
        [System.Reflection.CustomAttributeData]
        $CustomAttributeData
    )
    process
    {
        $object = $CustomAttributeData.NamedArguments |
            ? {$_.MemberName -eq $ArgumentName}

        if ( $ValueOnly )
        {
            return $object.TypedValue.Value
        }
        return $object
    }
}

function Test-CustomAttributeArgument
{
    param
    (
        [Parameter(Position = 1)]
        [string]
        $ArgumentName,

        [Parameter(Position = 2)]
        $Value,

        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true)]
        [System.Reflection.CustomAttributeData]
        $CustomAttributeData
    )
    process
    {
        if ( 'Value' -in $PSBoundParameters.get_Keys() )
        {
            return $Value -eq (
                $CustomAttributeData | 
                    Get-CustomAttributeArgument $ArgumentName -ValueOnly
            )
        }

        [bool]( $CustomAttributeData | Get-CustomAttributeArgument $ArgumentName )
    }
}