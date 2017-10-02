# function Test-Parameter
Get-Command Get-ParameterMetaData |
    New-Tester -CommandName Test-Parameter -NoValue |
    Invoke-Expression

#function Assert-Parameter
Get-Command Test-Parameter |
    New-Asserter 'Function $($FunctionInfo.Name) does not have parameter $ParameterName.' |
    Invoke-Expression

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

# function Test-ParameterAttribute
Get-Command Get-ParameterAttribute |
    New-Tester |
    Invoke-Expression

# function Assert-ParameterAttribute
Get-Command Test-ParameterAttribute |
    New-Asserter 'Parameter $($ParameterInfo.Name) attribute $AttributeName was $($ParameterInfo | Get-ParameterAttribute $AttributeName) not $Value.' |
    Invoke-Expression

function Test-ParameterMandatory
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
        $ParameterInfo | Test-ParameterAttribute Mandatory $true
    }
}

# function Assert-ParameterMandatory
Get-Command Test-ParameterMandatory |
    New-Asserter 'Parameter $($ParameterInfo.Name) is not mandatory.' |
    Invoke-Expression

function Test-ParameterOptional
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
        $ParameterInfo | Test-ParameterAttribute Mandatory $false
    }
}

# function Assert-ParameterOptional
Get-Command Test-ParameterOptional |
    New-Asserter 'Parameter $($ParameterInfo.Name) is not optional.)' |
    Invoke-Expression

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

# function Test-ParameterType
Get-Command Get-ParameterType |
    New-Tester |
    Invoke-Expression

# function Assert-ParameterType
Get-Command Test-ParameterType |
    New-Asserter 'Parameter $($Parameter.Name) is type $($ParameterInfo | Get-ParameterType) not $Value.' |
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
        $ParameterInfo | Get-ParameterAttribute Position
    }
}

# function Test-ParameterPosition
Get-Command Get-ParameterPosition |
    New-Tester |
    Invoke-Expression

# function Assert-ParameterPosition
Get-Command Test-ParameterPosition |
    New-Asserter 'Parameter $($ParameterInfo.Name) has position $($ParameterInfo | Get-ParameterAttribute Position) not position $Value.' |
    Invoke-Expression


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

# function Assert-ParameterPositional
Get-Command Test-ParameterPositional |
    New-Asserter 'Parameter $($ParameterInfo.Name) is not positional.' |
    Invoke-Expression

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
    [CmdletBinding(DefaultParameterSetName='default_value')]
    param
    (
        [Parameter(ParameterSetName = 'default_value',
                   Position = 1)]
        [AllowNull()]
        $Default,

        [Parameter(ParameterSetName = 'no_default_value',
                   Mandatory)]
        [switch]
        $NoDefault,

        [Parameter(Mandatory,
                   ValueFromPipeline)]
        [System.Management.Automation.Language.ParameterAst]
        $ParameterInfo
    )
    process
    {
        if ( $PSCmdlet.ParameterSetName -eq 'no_default_value' )
        {
            return -not ($ParameterInfo | Test-ParameterHasDefault)
        }
        if ( $PSBoundParameters.ContainsKey('Default') )
        {
            return $Default -eq ($ParameterInfo | Get-ParameterDefault)
        }
        return $ParameterInfo | Test-ParameterHasDefault
    }
}

# function Assert-ParameterDefault
Get-Command Test-ParameterDefault |
    New-Asserter {
        $actualDefault = $ParameterInfo | Get-ParameterDefault
        @{
            default_value = @{
                $true =  "Parameter $($ParameterInfo.Name.VariablePath.UserPath) has default value $actualDefault not default value $Default."
                $false = "Parameter $($ParameterInfo.Name.VariablePath.UserPath) has no default value."
            }.($PSBoundParameters.ContainsKey('Default'))
            no_default_value = "Parameter $($ParameterInfo.Name.VariablePath.UserPath) has default value $actualDefault.  Expected no default."
        }.($PSCmdlet.ParameterSetName)
    } |
    Invoke-Expression

function Test-ParameterKind
{
    param
    (
        [Parameter(ParameterSetName = 'affirmative',
                   Mandatory = $true,
                   Position = 1)]
        [ValidateSet('MandatoryCommon','OptionalCommon','Common')]
        [string]
        $Kind,

        [Parameter(ParameterSetName = 'negative',
                   Position = 2)]
        [ValidateSet('MandatoryCommon','OptionalCommon','Common')]
        [string]
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

# function Assert-ParameterKind
Get-Command Test-ParameterKind |
    New-Asserter {
        if ( $PSCmdlet.ParameterSetName -eq 'negative' )
        {
            "Parameter $($ParameterInfo.Name) is not of kind $Not."
        }
        "Parameter $($ParameterInfo.Name) is of kind $Kind."
    } |
    Invoke-Expression

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
