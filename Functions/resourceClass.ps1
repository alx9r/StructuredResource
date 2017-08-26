function Get-NestedModuleType
{
    [CmdletBinding()]
    param
    (
        [Parameter(Position = 1,
                   ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName = $true,
                   Mandatory = $true)]
        [Alias('ResourceName')]
        [string]
        $NestedName,

        [Parameter(Position = 2,
                   ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName = $true,
                   Mandatory = $true)]
        [Alias('ModuleName','ParentName')]
        [string]
        $Name
    )
    process
    {
        Get-NestedModule @PSBoundParameters |
            Get-TypeFromModule $NestedName
    }
}

function Assert-NestedModuleType
{
    [CmdletBinding()]
    param
    (
        [Parameter(Position = 1,
                   ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName = $true,
                   Mandatory = $true)]
        [Alias('ResourceName')]
        [string]
        $NestedName,

        [Parameter(Position = 2,
                   ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName = $true,
                   Mandatory = $true)]
        [Alias('ModuleName','ParentName')]
        [string]
        $Name
    )
    process
    {
        if ( Get-NestedModuleType @PSBoundParameters )
        {
            return
        }

        throw "Type $NestedName not found in module $NestedName."
    }
}


function New-NestedModuleInstance
{
    [CmdletBinding()]
    param
    (
        [Parameter(Position = 1,
                   ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName = $true,
                   Mandatory = $true)]
        [Alias('ResourceName')]
        [string]
        $NestedName,

        [Parameter(Position = 2,
                   ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName = $true,
                   Mandatory = $true)]
        [Alias('ModuleName','ParentName')]
        [string]
        $Name
    )
    process
    {
        Get-NestedModule @PSBoundParameters |
            New-ObjectFromModule $NestedName
    }
}

function Assert-NestedModuleInstance
{
    [CmdletBinding()]
    param
    (
        [Parameter(Position = 1,
                   ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName = $true,
                   Mandatory = $true)]
        [Alias('ResourceName')]
        [string]
        $NestedName,

        [Parameter(Position = 2,
                   ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName = $true,
                   Mandatory = $true)]
        [Alias('ModuleName','ParentName')]
        [string]
        $Name
    )
    process
    {
        if ( New-NestedModuleInstance @PSBoundParameters )
        {
            return
        }
        
        throw "Could not create object of type $NestedName from module $NestedName."
    }
}


function Get-DscResourceAttribute
{
    [CmdletBinding()]
    param
    (
        [Parameter(Position = 1,
                   ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName = $true,
                   Mandatory = $true)]
        [string]
        $ResourceName,

        [Parameter(Position = 2,
                   ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName = $true)]
        [string]
        $ModuleName
    )
    process
    {
        Get-NestedModule @PSBoundParameters |
            Get-TypeFromModule $ResourceName |
            % CustomAttributes | 
            ? {$_.AttributeType.Name -eq 'DscResourceAttribute' }
    }    
}

function Assert-DscResourceAttribute
{
    [CmdletBinding()]
    param
    (
        [Parameter(Position = 1,
                   ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName = $true,
                   Mandatory = $true)]
        [string]
        $ResourceName,

        [Parameter(Position = 2,
                   ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName = $true)]
        [string]
        $ModuleName
    )
    process
    {
        if ( -not (Get-DscResourceAttribute @PSBoundParameters) )
        {
            throw "[DscResource()] attribute not found on type $ResourceName in module $ModuleName."
        }
    }
}

