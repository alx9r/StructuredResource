function Get-ParameterMetaData
{
    [CmdletBinding()]
    param
    (
        [Parameter(Position = 1)]
        [string]
        $ParameterName,
        
        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true)]
        [System.Management.Automation.FunctionInfo]
        $FunctionInfo
    )
    process
    {
        if ( -not $ParameterName )
        {
            return $FunctionInfo.Parameters.get_Values()
        }
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
        [Parameter(Position = 1)]
        [string]
        $ParameterName,
        
        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true)]
        [System.Management.Automation.FunctionInfo]
        $FunctionInfo
    )
    process
    {
        $parameters = $FunctionInfo.ScriptBlock.Ast.Body.ParamBlock.Parameters
        if ( -not $ParameterName )
        {
            return $parameters
        }
        $parameters.Where({$_.Name.VariablePath.UserPath -eq $ParameterName})
    }
}

function Test-Parameter
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true,
                   Position = 1)]
        [string]
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
        [string]
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

function Get-ParameterPosition
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
        $ParameterInfo.Attributes.Position
    }
}

function Test-ParameterPosition
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true,
                   Position = 1)]
        [int]
        $Position,

        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true)]
        [System.Management.Automation.ParameterMetadata]
        $ParameterInfo
    )
    process
    {
        [bool]($Position -eq ($ParameterInfo | Get-ParameterPosition))
    }
}

function Assert-ParameterPosition
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true,
                   Position = 1)]
        [int]
        $Position,

        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true)]
        [System.Management.Automation.ParameterMetadata]
        $ParameterInfo
    )
    process
    {
        if ( Test-ParameterPosition @PSBoundParameters )
        {
            return
        }
        $actualPosition = $ParameterInfo | Get-ParameterPosition
        throw "Parameter $($ParameterInfo.Name) has position $actualPosition not position $Position."
    }
}

function Test-ParameterPositional
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
        [int]::MinValue -ne ($ParameterInfo | Get-ParameterPosition)
    }
}

function Assert-ParameterPositional
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
        if ( $ParameterInfo | Test-ParameterPositional )
        {
            return
        }
        throw "Parameter $($ParameterInfo.Name) is not positional."
    }
}

Set-Alias Sort-ParametersByPosition Invoke-SortParametersByPosition
function Invoke-SortParametersByPosition
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true)]
        [System.Management.Automation.ParameterMetadata]
        $ParameterInfo
    )
    begin
    {
        $accumulator = New-Object System.Collections.Queue
    }
    process
    {
        $accumulator.Enqueue($ParameterInfo)
    }
    end
    {
        $accumulator | 
            Sort-Object @{ Expression = { $_.Attributes.Position } }
    }
}

function Select-OrderedParameters
{
    param
    (
        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true)]
        [System.Management.Automation.ParameterMetadata]
        $ParameterInfo
    )
    begin
    {
        $accumulator = New-Object System.Collections.Queue
    }
    process
    {
        $accumulator.Enqueue($ParameterInfo)
    }
    end
    {
        $accumulator |
            ? { $_ | Test-ParameterPositional } |
            Invoke-SortParametersByPosition
    }
}

function Get-ParameterOrdinality
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true,
                   Position = 1)]
        [string]
        $ParameterName,

        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true)]
        [System.Management.Automation.ParameterMetadata]
        $ParameterInfo
    )
    begin
    {
        $ordinality = 0
    }
    process
    {
        if ( $ParameterInfo.Name -eq $ParameterName )
        {
            return $ordinality
        }
        $ordinality++
    }
}

function Test-ParameterOrdinality
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true,
                   Position = 1)]
        [string]
        $ParameterName,

        [Parameter(Mandatory = $true,
                   Position = 2)]
        [int]
        $Ordinality,

        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true)]
        [System.Management.Automation.ParameterMetadata]
        $ParameterInfo
    )
    begin
    {
        $accumulator = New-Object System.Collections.Queue
    }
    process
    {
        $accumulator.Enqueue($ParameterInfo)
    }
    end
    {
        $Ordinality -eq ($accumulator | Get-ParameterOrdinality $ParameterName)
    }
}

function Assert-ParameterOrdinality
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true,
                   Position = 1)]
        [string]
        $ParameterName,

        [Parameter(Mandatory = $true,
                   Position = 2)]
        [int]
        $Ordinality,

        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true)]
        [System.Management.Automation.ParameterMetadata]
        $ParameterInfo
    )
    begin
    {
        $accumulator = New-Object System.Collections.Queue
    }
    process
    {
        $accumulator.Enqueue($ParameterInfo)
    }
    end
    {
        if ( $accumulator | Test-ParameterOrdinality $ParameterName $Ordinality )
        {
            return
        }
        $actualOrdinality = $accumulator | Get-ParameterOrdinality $ParameterName
        throw "Parameter $ParameterName has position ordinality $actualOrdinality not position ordinality $Ordinality."
    }
}

function Get-FunctionParameterDefault
{
    param
    (
        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true)]
        [System.Management.Automation.Language.ParameterAst]
        $ParameterInfo
    )
    process
    {
        if ( $null -eq $ParameterInfo.DefaultValue )
        {
            return
        }
        $ParameterInfo.DefaultValue.SafeGetValue()
    }
}

function Test-FunctionParameterDefault
{
    param
    (
        [Parameter(ParameterSetName = 'default_value',
                   Mandatory = $true,
                   Position = 1)]
        $Default,

        [Parameter(ParameterSetName = 'no_default_value',
                   Mandatory = $true)]
        [switch]
        $NoDefault,
                   
        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true)]
        [System.Management.Automation.Language.ParameterAst]
        $ParameterInfo
    )
    process
    {
        $Default -eq ($ParameterInfo | Get-FunctionParameterDefault)
    }
}

function Assert-FunctionParameterDefault
{
    param
    (
        [Parameter(ParameterSetName = 'default_value',
                   Mandatory = $true,
                   Position = 1)]
        $Default,

        [Parameter(ParameterSetName = 'no_default_value',
                   Mandatory = $true)]
        [switch]
        $NoDefault,
                   
        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true)]
        [System.Management.Automation.Language.ParameterAst]
        $ParameterInfo
    )
    process
    {
        if ( Test-FunctionParameterDefault @PSBoundParameters )
        {
            return
        }

        $actualDefault = $ParameterInfo | Get-FunctionParameterDefault
        if ( $PSCmdlet.ParameterSetName -eq 'default_value' )
        {
            throw "Parameter $($ParameterInfo.Name.VariablePath.UserPath) has default value $actualDefault not default value $Default."
        }
        throw "Parameter $($ParameterInfo.Name.VariablePath.UserPath) has default value $actualDefault.  Expected no default."
    }
}