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

        $getterParams = $Getter | Get-ParameterAst
        $getterParamNamesLiteral = ( $Getter | Get-ParameterMetaData | % { "'$($_.Name)'" }) -join ','
        $getterParamsText = ( $getterParams | Get-ParameterText ) -join ','

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