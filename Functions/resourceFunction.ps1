function Get-ParameterMetaData
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true,
                   Position = 1)]
        $ParameterName,
        
        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true)]
        [System.Management.Automation.FunctionInfo]
        $FunctionInfo
    )
    process
    {
        if ( $ParameterName -notin $FunctionInfo.Parameters.get_Keys() )
        {
            return
        }
        $FunctionInfo.Parameters.get_Item($ParameterName)
    }
}

function Get-ParameterAst
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true,
                   Position = 1)]
        $ParameterName,
        
        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true)]
        [System.Management.Automation.FunctionInfo]
        $FunctionInfo
    )
    process
    {
        $FunctionInfo.ScriptBlock.Ast.Body.ParamBlock.Parameters.
            Where({$_.Name.VariablePath.UserPath -eq $ParameterName})
    }
}

function Test-Parameter
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true,
                   Position = 1)]
        $ParameterName,
        
        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true)]
        [System.Management.Automation.FunctionInfo]
        $FunctionInfo
    )
    process
    {
        [bool](Get-ParameterMetaData @PSBoundParameters)
    }    
}

function Assert-Parameter
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true,
                   Position = 1)]
        $ParameterName,
        
        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true)]
        [System.Management.Automation.FunctionInfo]
        $FunctionInfo
    )
    process
    {
        if ( Test-Parameter @PSBoundParameters )
        {
            return
        }
        throw "Function $($FunctionInfo.Name) does not have parameter $ParameterName."
    }
}

function Test-FunctionParameterMandatory
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true)]
        [System.Management.Automation.ParameterMetadata]
        $ParameterInfo
    )
    process
    {
        [bool]($ParameterInfo.Attributes | ? { $_.Mandatory })
    }
}

function Assert-FunctionParameterMandatory
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true)]
        [System.Management.Automation.ParameterMetadata]
        $ParameterInfo
    )
    process
    {
        if ( Test-FunctionParameterMandatory @PSBoundParameters )
        {
            return
        }

        throw "Parameter $($ParameterInfo.Name) is not mandatory."
    }
}

function Get-FunctionParameterType
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true)]
        [System.Management.Automation.ParameterMetadata]
        $ParameterInfo
    )
    process
    {
        return $ParameterInfo.ParameterType
    }
}

function Test-FunctionParameterType
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true,
                   Position = 1)]
        [System.Reflection.TypeInfo]
        $Type,

        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true)]
        [System.Management.Automation.ParameterMetadata]
        $ParameterInfo
    )
    process
    {
        $Type -eq ($ParameterInfo | Get-FunctionParameterType)
    }
}

function Assert-FunctionParameterType
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true,
                   Position = 1)]
        [System.Reflection.TypeInfo]
        $Type,

        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true)]
        [System.Management.Automation.ParameterMetadata]
        $ParameterInfo
    )
    process
    {
        if ( Test-FunctionParameterType @PSBoundParameters )
        {
            return
        }
        $actualType = $ParameterInfo | Get-FunctionParameterType
        throw "Parameter $($ParameterInfo.Name) is of type `"$actualType`" not of type `"$Type`"."
    }
}

