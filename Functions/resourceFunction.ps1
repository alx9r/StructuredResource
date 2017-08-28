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

function Get-ParameterAttribute
{
    param
    (
        [Parameter(Mandatory = $true,
                   Position = 1)]
        [ValidateSet('DontShow','HelpMessage','HelpMessageBaseName',
                     'HelpMessageResourceId','Mandatory','ParameterSetName',
                     'Position','TypeId','ValueFromPipeline',
                     'ValueFromPipelineByPropertyName','ValueFromRemainingArguments')]
        $AttributeName,

        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true)]
        [System.Management.Automation.ParameterMetadata]
        $ParameterInfo
    )
    process
    {
        $ParameterInfo.Attributes.$AttributeName
    }
}

function Test-ParameterAttribute
{
    param
    (
        [Parameter(Mandatory = $true,
                   Position = 1)]
        [ValidateSet('DontShow','HelpMessage','HelpMessageBaseName',
                     'HelpMessageResourceId','Mandatory','ParameterSetName',
                     'Position','TypeId','ValueFromPipeline',
                     'ValueFromPipelineByPropertyName','ValueFromRemainingArguments')]
        $AttributeName,

        [Parameter(Mandatory = $true,
                   Position = 2)]
        [AllowNull()]
        $Value,

        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true)]
        [System.Management.Automation.ParameterMetadata]
        $ParameterInfo
    )
    process
    {
        [bool]($Value -eq ($ParameterInfo | Get-ParameterAttribute $AttributeName))
    }
}

function Assert-ParameterAttribute
{
    param
    (
        [Parameter(Mandatory = $true,
                   Position = 1)]
        [ValidateSet('DontShow','HelpMessage','HelpMessageBaseName',
                     'HelpMessageResourceId','Mandatory','ParameterSetName',
                     'Position','TypeId','ValueFromPipeline',
                     'ValueFromPipelineByPropertyName','ValueFromRemainingArguments')]
        $AttributeName,

        [Parameter(Mandatory = $true,
                   Position = 2)]
        [AllowNull()]
        $Value,

        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true)]
        [System.Management.Automation.ParameterMetadata]
        $ParameterInfo
    )
    process
    {
        if ( Test-ParameterAttribute @PSBoundParameters )
        {
            return
        }
        $actualValue = $ParameterInfo | Get-ParameterAttribute  $AttributeName
        throw "Parameter $($ParameterInfo.Name) attribute $AttributeName was $actualValue not $Value."
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
        if ( $ParameterInfo | Test-ParameterAttribute Mandatory $true )
        {
            return
        }
        throw "Parameter $($ParameterInfo.Name) is not mandatory."
    }
}

function Assert-FunctionParameterOptional
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
        if ( $ParameterInfo | Test-ParameterAttribute Mandatory $false )
        {
            return
        }
        throw "Parameter $($ParameterInfo.Name) is not optional."
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
        if ( $ParameterInfo | Test-ParameterAttribute Position $Position )
        {
            return
        }
        $actualPosition = $ParameterInfo | Get-ParameterAttribute Position
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
        [int]::MinValue -ne ($ParameterInfo | Get-ParameterAttribute Position)
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

function Test-FunctionParameter
{
    param
    (
        [Parameter(ParameterSetName = 'affirmative',
                   Mandatory = $true,
                   Position = 1)]
        [ValidateSet('MandatoryCommon','OptionalCommon','Common')]
        $Kind,

        [Parameter(ParameterSetName = 'negative',
                   Position = 2)]
        [ValidateSet('MandatoryCommon','OptionalCommon','Common')]
        $Not,
                   
        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true)]
        [System.Management.Automation.ParameterMetadata]
        $ParameterInfo
    )
    process
    {
        $selector = $Kind,$Not | ? {$_}
        $nameList = @{
            Common = [System.Management.Automation.PSCmdlet]::CommonParameters +
                     [System.Management.Automation.PSCmdlet]::OptionalCommonParameters
            OptionalCommon = [System.Management.Automation.PSCmdlet]::OptionalCommonParameters
            MandatoryCommon = [System.Management.Automation.PSCmdlet]::CommonParameters

        }.$selector

        ( $nameList -contains $ParameterInfo.Name ) -xor
        ( $PSCmdlet.ParameterSetName -eq 'negative' )
    }
}

function Select-FunctionParameter
{
    param
    (
        [Parameter(ParameterSetName = 'affirmative',
                   Mandatory = $true,
                   Position = 1)]
        [ValidateSet('MandatoryCommon','OptionalCommon','Common')]
        $Kind,

        [Parameter(ParameterSetName = 'negative')]
        [ValidateSet('MandatoryCommon','OptionalCommon','Common')]
        $Not,
                   
        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true)]
        [System.Management.Automation.ParameterMetadata]
        $ParameterInfo
    )
    process
    {
        if (Test-FunctionParameter @PSBoundParameters )
        {
            $ParameterInfo
        }
    }
}