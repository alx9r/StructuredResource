function Get-ParameterText
{
    param
    (
        [Parameter(Mandatory,
                   ValueFromPipeline)]
        [System.Management.Automation.Language.ParameterAst]
        $Parameter
    )
    process
    {
        $Parameter.Extent.Text
    }
}
function Get-ParamblockText
{
    [CmdletBinding(DefaultParameterSetName = 'FunctionInfo')]
    param
    (
        [Parameter(ParameterSetName = 'CmdletInfo',
                   ValueFromPipeline,
                   Mandatory)]
        [System.Management.Automation.CmdletInfo]
        $CmdletInfo,

        [Parameter(ParameterSetName = 'FunctionInfo',
                   ValueFromPipeline,
                   Mandatory)]
        [System.Management.Automation.FunctionInfo]
        $FunctionInfo
    )
    process
    {
        if ( $PSCmdlet.ParameterSetName -eq 'FunctionInfo' )
        {
            return ($FunctionInfo | Get-ParameterAst | Get-ParameterText) -join ",`r`n"
        }

        [System.Management.Automation.ProxyCommand]::GetParamBlock(
            [System.Management.Automation.CommandMetadata]::new($CmdletInfo)
        )
    }
}

function Get-CmdletBindingAttributeText
{
    param
    (
        [Parameter(ValueFromPipeline,
                   Mandatory)]
        [System.Management.Automation.CommandInfo]
        $CommandInfo
    )
    process
    {
        [System.Management.Automation.ProxyCommand]::GetCmdletBindingAttribute(
            [System.Management.Automation.CommandMetadata]::new($CommandInfo)
        )
    }
}

function New-Tester
{
    param
    (
        [parameter(Mandatory,
                   ValueFromPipeline)]
        [System.Management.Automation.CommandInfo]
        $Getter,

        [Parameter(Position=1)]
        [scriptblock]
        $EqualityTester = {$_.Actual -eq $_.Expected},

        [string]
        $CommandName,

        [switch]
        $NoValue
    )
    process
    {
        $testerName = @{
            $false = "Test-$($Getter.Noun)"
            $true  = $CommandName
        }.($PSBoundParameters.ContainsKey('CommandName'))

        $getterParamNamesLiteral = ( $Getter | Get-ParameterMetaData | % { "'$($_.Name)'" }) -join ','

        $valueParamsText = @{
            $true = ''
            $false = '[Parameter(Position = 100)]$Value'
        }.([bool]$NoValue)

        $paramsText = (($Getter | Get-ParamblockText),$valueParamsText | ? {$_} ) -join ','

        @"
            function $testerName
            {
                $($Getter | Get-CmdletBindingAttributeText)
                param
                (
                    $paramsText
                )
                process
                {
                    `$splat = @{}
                    $getterParamNamesLiteral | 
                        ? { `$PSBoundParameters.ContainsKey(`$_) } |
                        % { `$splat.`$_ = `$PSBoundParameters.get_Item(`$_) }

                    if ( `$PSBoundParameters.ContainsKey('Value') )
                    {
                        `$values = [pscustomobject]@{
                            Actual = $($Getter.Name) @splat
                            Expected = `$Value
                        }

                        return `$values | % {$EqualityTester}
                    }
                    return [bool](($($Getter.Name) @splat) -ne `$null)
                }
            }
"@
    }
}

function New-Asserter
{
    param
    (
        [parameter(Mandatory,
                   ValueFromPipeline)]
        [System.Management.Automation.CommandInfo]
        $Tester,

        [Parameter(ParameterSetName = 'string',
                   Mandatory,
                   Position = 1)]
        [string]
        $Message,

        [Parameter(ParameterSetName = 'scriptblock',
                   Mandatory,
                   Position = 1)]
        [scriptblock]
        $Scriptblock
    )
    process
    {
        $testerParamNamesLiteral = ( $Tester | Get-ParameterMetaData | % { "'$($_.Name)'" }) -join ','

        @"
            function Assert-$($Tester.Noun)
            {
                $($Tester | Get-CmdletBindingAttributeText)
                param
                (
                    $($Tester | Get-ParamblockText)
                )
                process
                {
                    `$splat = @{}
                    $testerParamNamesLiteral | 
                        ? { `$PSBoundParameters.ContainsKey(`$_) } |
                        % { `$splat.`$_ = `$PSBoundParameters.get_Item(`$_) }

                    if ( $($Tester.Name) @splat )
                    {
                        return
                    }
                    $(@{
                        string = "throw `"$Message`""
                        scriptblock = "throw [string](& {$Scriptblock})"
                    }.($PSCmdlet.ParameterSetName))
                }
            }
"@
    }
}