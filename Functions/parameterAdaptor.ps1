function Test-StructuredDscAttributeParameter
{
    param
    (
        [Parameter(Mandatory,
                   Position = 1)]
        [ValidateSet('Hint','Key','Property','ConstructorProperty')]
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

function Test-StructuredDscGroupParameter
{
    param
    (
        [Parameter(Mandatory,
                   Position = 1)]
        [ValidateSet('Keys','Hints','Properties')]
        $GroupName,

        [Parameter(Mandatory,
                   ValueFromPipeline)]
        [System.Management.Automation.ParameterMetadata]
        $ParameterInfo
    )
    process
    {
        & @{
            Keys =   { $_ | Test-StructuredDscAttributeParameter Key }
            Hints =  { ($_ | Test-StructuredDscAttributeParameter Hint) -or
                       ($_ | Test-StructuredDscAttributeParameter ConstructorProperty) }
            Properties = { ($_ | Test-StructuredDscPropertyParameter) -or
                           ($_ | Test-StructuredDscAttributeParameter ConstructorProperty) }
        }.$GroupName
    }
}

function New-StructuredDscArgumentGroup
{
    param
    (
        [Parameter(Mandatory,
                   Position = 1)]
        [ValidateSet('Keys','Hints','Properties')]
        $GroupName,

        [Parameter(ParameterSetName = 'BoundParameters',
                   Mandatory,
                   Position = 2)]
        #[PSBoundParametersDictionary]
        [System.Collections.Generic.Dictionary`2[System.String,System.Object]]
        $BoundParameters,

        [Parameter(ParameterSetName = 'hashtable',
                   Mandatory,
                   Position = 2)]
        [hashtable]
        $NamedArguments,

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
        $arguments = $BoundParameters,$NamedArguments | ? {$null -ne $_}
        if 
        ( 
            ( $ParameterInfo | ? {$_ | Test-StructuredDscGroupParameter $GroupName } ) -and
            ( $ParameterInfo.Name -in $arguments.get_Keys() ) -and
            ( $null -ne $arguments.get_Item($ParameterInfo.Name) )
        )
        {
            $output.($ParameterInfo.Name) = $arguments.($ParameterInfo.Name)
        }
    }
    end
    {
        $output
    }
}

function New-StructuredDscArgs
{
    param
    (
        [Parameter(ParameterSetName = 'BoundParameters',
                   Mandatory,
                   Position = 1)]
        #[PSBoundParametersDictionary]
        [System.Collections.Generic.Dictionary`2[System.String,System.Object]]
        $BoundParameters,

        [Parameter(ParameterSetName = 'hashtable',
                   Mandatory,
                   Position = 1)]
        [hashtable]
        $NamedArguments,

        [Parameter(Mandatory,
                   ValueFromPipeline)]
        [System.Management.Automation.ParameterMetadata]
        $ParameterInfo
    )
    begin
    {
        $parameters = New-Object System.Collections.Queue
    }
    process
    {
        $parameters.Enqueue($ParameterInfo)
    }
    end
    {
        $arguments = $BoundParameters,$NamedArguments | ? {$null -ne $_}
        @{
            Keys =       $parameters | New-StructuredDscArgumentGroup Keys $arguments
            Hints =      $parameters | New-StructuredDscArgumentGroup Hints $arguments
            Properties = $parameters | New-StructuredDscArgumentGroup Properties $arguments
        }
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

        foreach ( $name in 'Keys','Hints','Properties' )
        {
            $params = $c | Get-ParameterMetaData | New-StructuredDscArgumentGroup $name $p
            if ( $params.Keys -ne $null )
            {
                $InputObject | Add-Member NoteProperty $name $params
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
            ? { $null -ne $InvocationInfo.BoundParameters.get_Item($_) } |
            % { $outputParams.$_ = $InvocationInfo.BoundParameters.get_Item($_) }

        $InvocationInfo.MyCommand.Module |
            ? { $_ } |
            ? { $outputParams.Module = $_ }

        [pscustomobject]$outputParams |
            Add-StructuredDscGroupParameters $InvocationInfo -PassThru
    }
}
