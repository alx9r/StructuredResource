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
        $EqualityTester = {$_.Actual -eq $_.Expected}
    )
    process
    {
        $getterName = $Getter.Name
        $testerName = "Test-$($Getter.Noun)"
        $getterParams = $Getter | 
                Get-ParameterAst
        $getterParamNamesLiteral = ( $Getter | Get-ParameterMetaData | % { "'$($_.Name)'" }) -join ','
        $getterParamsText = ( $getterParams | Get-ParameterText ) -join ','
        @"
            function $testerName
            {
                param
                (
                    $getterParamsText,

                    `$Value
                )
                process
                {
                    `$splat = @{}
                    $getterParamNamesLiteral | 
                        ? { `$PSBoundParameters.ContainsKey(`$_) } |
                        % { `$splat.`$_ = `$PSBoundParameters.get_Item(`$_) }

                    `$values = [pscustomobject]@{
                        Actual = $getterName @splat
                        Expected = `$Value
                    }

                     `$values | % {$EqualityTester}
                }
            }
"@
    }
}