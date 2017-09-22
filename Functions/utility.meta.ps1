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

function New-Tester
{
    param
    (
        [parameter(Mandatory,
                   ValueFromPipeline)]
        [System.Management.Automation.FunctionInfo]
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
        $getterName = $Getter.Name

        $testerName = @{
            $false = "Test-$($Getter.Noun)"
            $true  = $CommandName
        }.($PSBoundParameters.ContainsKey('CommandName'))

        $getterParamsText = ( $Getter | Get-ParameterAst | Get-ParameterText ) -join ','
        $getterParamNamesLiteral = ( $Getter | Get-ParameterMetaData | % { "'$($_.Name)'" }) -join ','

        $valueParamsText = @{
            $true = ''
            $false = '[Parameter(Position = 100)]$Value'
        }.([bool]$NoValue)

        $paramsText = ($getterParamsText,$valueParamsText | ? {$_} ) -join ','

        @"
            function $testerName
            {
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
                            Actual = $getterName @splat
                            Expected = `$Value
                        }

                        return `$values | % {$EqualityTester}
                    }
                    return [bool](($getterName @splat) -ne `$null)
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
        [System.Management.Automation.FunctionInfo]
        $Tester,

        [Parameter(Mandatory,
                   Position = 1)]
        [string]
        $Message
    )
    process
    {
        $testerName = $Tester.Name
        $asserterName = "Assert-$($Tester.Noun)"

        $testerParamNamesLiteral = ( $Tester | Get-ParameterMetaData | % { "'$($_.Name)'" }) -join ','
        $testerParamsText = ($Tester | Get-ParameterAst | Get-ParameterText) -join ','

        @"
            function $asserterName
            {
                param
                (
                    $testerParamsText
                )
                process
                {
                    `$splat = @{}
                    $testerParamNamesLiteral | 
                        ? { `$PSBoundParameters.ContainsKey(`$_) } |
                        % { `$splat.`$_ = `$PSBoundParameters.get_Item(`$_) }

                    if ( $testerName @splat )
                    {
                        return
                    }
                    throw "$Message"
                }
            }
"@
    }
}