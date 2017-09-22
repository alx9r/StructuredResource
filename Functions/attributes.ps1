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

Get-Command Get-AttributeArgument | New-Tester | Invoke-Expression

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

Get-Command Get-CustomAttributeArgument | 
    New-Tester { $_.Expected -eq $_.Actual.TypedValue.Value } |
    Invoke-Expression
