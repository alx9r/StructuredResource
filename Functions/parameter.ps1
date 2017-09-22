Get-Command Get-ParameterMetaData |
    New-Tester -CommandName Test-Parameter -NoValue |
    Invoke-Expression

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

function Get-ParameterAttributeProper
{
    param
    (
        [Parameter(Mandatory = $true,
                   Position = 1)]
        $AttributeName,

        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true)]
        [System.Management.Automation.ParameterMetadata]
        $ParameterInfo
    )
    process
    {
        $ParameterInfo.Attributes.Where({$_.TypeId.Name -eq 'ParameterAttribute'}).$AttributeName
    }
}

function Get-ParameterAttributeOther
{
    param
    (
        [Parameter(Mandatory = $true,
                   Position = 1)]
        $AttributeName,

        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true)]
        [System.Management.Automation.ParameterMetadata]
        $ParameterInfo
    )
    process
    {
        $ParameterInfo.Attributes.Where({$_.TypeId.Name -eq "$AttributeName`Attribute"})
    }
}

function Get-ParameterAttribute
{
    param
    (
        [Parameter(Mandatory = $true,
                   Position = 1)]
        $AttributeName,

        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true)]
        [System.Management.Automation.ParameterMetadata]
        $ParameterInfo
    )
    process
    {
        if ( $result = $ParameterInfo | Get-ParameterAttributeOther $AttributeName )
        {
            return $result
        }
        return $ParameterInfo | Get-ParameterAttributeProper $AttributeName
    }
}

Get-Command Get-ParameterAttribute |
    New-Tester |
    Invoke-Expression

function Assert-ParameterAttribute
{
    param
    (
        [Parameter(Mandatory = $true,
                   Position = 1)]
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

function Assert-ParameterMandatory
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

function Assert-ParameterOptional
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

function Get-ParameterType
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
        try
        {
            $ParameterInfo.ParameterType
        }
        catch
        {
            throw New-Object System.Exception (
                "ParameterInfo.Name : $($ParameterInfo.Name)",
                $_.Exception
            )
        }
    }
}

Get-Command Get-ParameterType |
    New-Tester |
    Invoke-Expression

function Get-ParameterPosition
{
    param
    (
        [Parameter(Mandatory,
                   ValueFromPipeline)]
        [System.Management.Automation.ParameterMetadata]
        $ParameterInfo
    )
    process
    {
        Get-ParameterAttribute Position
    }
}

Get-Command Get-ParameterPosition |
    New-Tester |
    Invoke-Expression

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

function Test-ParameterHasDefault
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
        $null -ne $ParameterInfo.DefaultValue
    }
}

function Get-ParameterDefault
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
        if ( -not ($ParameterInfo | Test-ParameterHasDefault) )
        {
            return
        }
        $ParameterInfo.DefaultValue.SafeGetValue()
    }
}

function Test-ParameterDefault
{
    param
    (
        [Parameter(ParameterSetName = 'default_value',
                   Mandatory = $true,
                   Position = 1)]
        [AllowNull()]
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
        if ( $PSCmdlet.ParameterSetName -eq 'no_default_value' )
        {
            return -not ($ParameterInfo | Test-ParameterHasDefault)
        }
        $Default -eq ($ParameterInfo | Get-ParameterDefault)
    }
}

function Assert-ParameterDefault
{
    param
    (
        [Parameter(ParameterSetName = 'default_value',
                   Mandatory = $true,
                   Position = 1)]
        [AllowNull()]
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
        if ( Test-ParameterDefault @PSBoundParameters )
        {
            return
        }

        $actualDefault = $ParameterInfo | Get-ParameterDefault
        if ( $PSCmdlet.ParameterSetName -eq 'default_value' )
        {
            throw "Parameter $($ParameterInfo.Name.VariablePath.UserPath) has default value $actualDefault not default value $Default."
        }
        throw "Parameter $($ParameterInfo.Name.VariablePath.UserPath) has default value $actualDefault.  Expected no default."
    }
}

function Test-ParameterKind
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

function Select-Parameter
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
        if (Test-ParameterKind @PSBoundParameters )
        {
            $ParameterInfo
        }
    }
}