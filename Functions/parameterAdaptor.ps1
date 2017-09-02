function Test-StructuredDscAttributeParameter
{
    param
    (
        [Parameter(Mandatory,
                   Position = 1)]
        [ValidateSet('Hint','Key','Property')]
        $GroupName,

        [Parameter(Mandatory,
                   ValueFromPipeline)]
        [System.Management.Automation.ParameterMetadata]
        $ParameterInfo
    )
    process
    {
        $GroupName -eq 
            (
                $ParameterInfo | 
                    Get-ParameterAttribute StructuredDsc | 
                    ? {$null -ne $_} | 
                    Get-AttributeArgument ParameterType
            )
    }
}

function Test-StructuredDscKnownParameter
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
        $ParameterInfo.Name -in 'Ensure','Mode'
    }
}

function Test-StructuredDscPropertyParameter
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
        ( $ParameterInfo | Test-StructuredDscAttributeParameter Property ) -or
        ( 
            -not ($ParameterInfo | Get-ParameterAttribute StructuredDsc) -and
            -not ($ParameterInfo | Test-StructuredDscKnownParameter) -and
            -not ($ParameterInfo | Test-ParameterKind Common )
        )
    }    
}

function New-StructuredDscParameterGroup
{
    param
    (
        [Parameter(Mandatory,
                   Position = 1)]
        [ValidateSet('Known','Key','Hint','Property')]
        $GroupName,

        [Parameter(Mandatory,
                   Position = 2)]
        #[PSBoundParametersDictionary]
        [System.Collections.Generic.Dictionary`2[System.String,System.Object]]
        $BoundParameters,

        [Parameter(Mandatory,
                   ValueFromPipeline)]
        [System.Management.Automation.ParameterMetadata]
        $ParameterInfo
    )
    begin
    {
        $output = @{}
    }
    process
    {
        $tester = @{
            Known = { $_ | Test-StructuredDscKnownParameter }
            Key =   { $_ | Test-StructuredDscAttributeParameter Key }
            Hint =  { $_ | Test-StructuredDscAttributeParameter Hint }
            Property = { $_ | Test-StructuredDscPropertyParameter }
        }.$GroupName

        if 
        ( 
            ( $ParameterInfo | ? $tester ) -and
            ( $ParameterInfo.Name -in $BoundParameters.get_Keys() )
        )
        {
            $output.($ParameterInfo.Name) = $BoundParameters.($ParameterInfo.Name)
        }
    }
    end
    {
        $output
    }
}

function Add-StructuredDscGroupParameters
{
    param
    (
        [Parameter(Mandatory,
                   Position = 1)]
        [System.Management.Automation.InvocationInfo]
        $InvocationInfo,

        [switch]
        $PassThru,

        [Parameter(Mandatory,
                   ValueFromPipeline)]
        [pscustomobject]
        $InputObject
    )
    process
    {
        $p = $InvocationInfo.BoundParameters
        $c = $InvocationInfo.MyCommand

        $outputName = @{
            Key = 'Keys'
            Hint = 'Hints'
            Property = 'Properties'
        }

        foreach ( $inputName in 'Key','Hint','Property' )
        {
            $outputName = @{
                Key = 'Keys'
                Hint = 'Hints'
                Property = 'Properties'
            }.$inputName

            $params = $c | Get-ParameterMetaData | New-StructuredDscParameterGroup $inputName $p
            if ( $params.Keys -ne $null )
            {
                $InputObject | Add-Member NoteProperty $outputName $params
            }
        }

        if ($PassThru)
        {
            $InputObject
        }
    }
}

function New-StructuredDscParameters
{
    param
    (
        [Parameter(Mandatory,
                   Position = 1)]
        [hashtable]
        $InputParams,

        [Parameter(Mandatory,
                   ValueFromPipeline)]
        $InvocationInfo
    )
    process
    {
        $outputParams = $InputParams.Clone()

        'Mode','Ensure' |
            ? { $_ -in $InvocationInfo.BoundParameters.get_Keys() } |
            % { $outputParams.$_ = $InvocationInfo.BoundParameters.get_Item($_) }

        [pscustomobject]$outputParams |
            Add-StructuredDscGroupParameters $InvocationInfo -PassThru
    }
}