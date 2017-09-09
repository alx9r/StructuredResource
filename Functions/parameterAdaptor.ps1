function Test-StructuredResourceAttributeParameter
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
                    Get-ParameterAttribute StructuredResource | 
                    ? {$null -ne $_} | 
                    Get-AttributeArgument ParameterType
            )
    }
}

function Test-StructuredKnownParameter
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

function Test-StructuredPropertyParameter
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
        ( $ParameterInfo | Test-StructuredResourceAttributeParameter Property ) -or
        ( 
            -not ($ParameterInfo | Get-ParameterAttribute StructuredResource) -and
            -not ($ParameterInfo | Test-StructuredKnownParameter) -and
            -not ($ParameterInfo | Test-ParameterKind Common )
        )
    }    
}

function Test-StructuredGroupParameter
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
            Keys =   { $_ | Test-StructuredResourceAttributeParameter Key }
            Hints =  { ($_ | Test-StructuredResourceAttributeParameter Hint) -or
                       ($_ | Test-StructuredResourceAttributeParameter ConstructorProperty) }
            Properties = { ($_ | Test-StructuredPropertyParameter) -or
                           ($_ | Test-StructuredResourceAttributeParameter ConstructorProperty) }
        }.$GroupName
    }
}

function New-StructuredArgumentGroup
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
            ( $ParameterInfo | ? {$_ | Test-StructuredGroupParameter $GroupName } ) -and
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

function New-StructuredArgs
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
            Keys =       $parameters | New-StructuredArgumentGroup Keys $arguments
            Hints =      $parameters | New-StructuredArgumentGroup Hints $arguments
            Properties = $parameters | New-StructuredArgumentGroup Properties $arguments
        }
    }
}

function Add-StructuredGroupParameters
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
            $params = $c | Get-ParameterMetaData | New-StructuredArgumentGroup $name $p
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

function New-StructuredResourceArgs
{
    <#
	.SYNOPSIS
	Creates a new arguments object for invoking a structured resource.
	.DESCRIPTION
	New-StructuredResourceArgs creates a new object whose properties are suitable for passing to Invoke-StructuredResource as arguments via the pipeline.  Common arguments are determined from InvocationInfo which is usually obtained from the body of a public resource function.  The following arguments are populated from InvocationInfo:
	
	 - Mode: the value for Mode that was passed to the public resource function
	 - Ensure: the value for Ensure that was passed to the public resource function
	 - Module: the containing module of the public resource function
	 - Keys: a hashtable containing each of the public resource parameters bearing the [StructuredResource('Key')] attribute
	 - Hints: a hashtable containing each of the public resource parameters bearing either the [StructuredResource('Hint')] or [StructuredResource('ContstructorProperty')] attributes.
	 - Properties: a hashtable containing each of the public resource parameters other than Mode, Ensure, and those included in Keys or Hints.
	 
	Additional arguments can be included as properties of the object using InputArgs.
	
	.PARAMETER InputArgs
	A hashtable containing user-specified arguments that are included as properties of the new object.
	
	.PARAMETER InvocationInfo
	An InvocationInfo object containing the information from an invocation of a public resource function.  The Mode, Ensure, Module, Properties, Keys, and Hints properties of the new object are obtained from InvocationInfo.
    #>
    param
    (
        [Parameter(Mandatory,
                   Position = 1)]
        [hashtable]
        $InputArgs,

        [Parameter(Mandatory,
                   ValueFromPipeline)]
        [System.Management.Automation.InvocationInfo]
        $InvocationInfo
    )
    process
    {
        $outputParams = $InputArgs.Clone()

        'Mode','Ensure' |
            ? { $_ -in $InvocationInfo.BoundParameters.get_Keys() } |
            ? { $null -ne $InvocationInfo.BoundParameters.get_Item($_) } |
            % { $outputParams.$_ = $InvocationInfo.BoundParameters.get_Item($_) }

        $InvocationInfo.MyCommand.Module |
            ? { $_ } |
            ? { $outputParams.Module = $_ }

        [pscustomobject]$outputParams |
            Add-StructuredGroupParameters $InvocationInfo -PassThru
    }
}
