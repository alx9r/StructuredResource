function Assert-NamedArgument
{
    param
    (
        [Parameter(Mandatory,
                   Position = 1)]
        [hashtable]
        $Arguments,

        [Parameter(Mandatory,
                   ValueFromPipeline)]
        [System.Management.Automation.ParameterMetadata]
        $ParameterInfo
    )
    process
    {
        if ( $ParameterInfo.Name -notin $Arguments.get_Keys() )
        {
            throw "Argument $($ParameterInfo.Name) not found."
        }

        if ( $null -eq $Arguments.$($ParameterInfo.Name) )
        {
            throw "Argument $($ParameterInfo.Name) is null."
        }

        try
        {
            Invoke-Expression "[$($ParameterInfo.ParameterType.FullName)]`$Arguments.`$(`$ParameterInfo.Name)" |
                Out-Null
        }
        catch
        {
            throw [System.Exception]::new(
                "Argument $($ParameterInfo.Name) could not be converted to parameter type $($ParameterInfo.ParameterType)",
                $_.Exception
            )
        }
    }
}

function Assert-ConstructorArgument
{
    param
    (
        [Parameter(Mandatory,
                   Position = 1)]
        [hashtable]
        $Arguments,

        [Parameter(Mandatory,
                   ValueFromPipeline)]
        [System.Management.Automation.ParameterMetadata]
        $ParameterInfo
    )
    process
    {
        if
        (
            $ParameterInfo |
                Get-ParameterAttribute StructuredResource |
                ? {$null -ne $_} |
                Test-AttributeArgument ParameterType ConstructorProperty
        )
        {
            try
            {
                $ParameterInfo | Assert-NamedArgument $Arguments
            }
            catch
            {
                throw [System.Exception]::new(
                    "Problem with argument for constructor property $($ParameterInfo.Name)",
                    $_.Exception
                )
            }
        }
    }
}
