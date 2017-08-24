function Assert-ModuleExists
{
    [CmdletBinding()]
    param
    (
        [Parameter(Position = 1,
                   ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName = $true,
                   Mandatory = $true)]
        [Alias('ModuleName')]
        [string]
        $Name
    )
    process
    {
        if ( Get-Module $Name -ListAvailable )
        {
            return
        }

        throw "Module $Name not found."
    }
}

function Assert-ModuleImported
{
    [CmdletBinding()]
    param
    (
        [Parameter(Position = 1,
                   ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName = $true,
                   Mandatory = $true)]
        [Alias('ModuleName')]
        [string]
        $Name
    )
    process
    {
        if ( Get-Module $Name )
        {
            return
        }
        
        throw "Module $Name not imported."
    }
}

function Get-NestedModule
{
    [CmdletBinding()]
    param
    (
        [Parameter(Position = 1,
                   ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName = $true)]
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
        $nestedModules = Get-Module $Name -ListAvailable | % NestedModules

        if ( -not $NestedName )
        {
            return $nestedModules
        }

        return $nestedModules | ? { $_.Name -like $NestedName }
    }
}

function Assert-NestedModule
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
        if ( Get-NestedModule @PSBoundParameters )
        {
            return
        }

        throw "Nested module $NestedName not found module $Name."
    }
}

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

function Assert-DscResource
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
        $Name,

        [Parameter(Position = 2,
                   ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName = $true)]
        [Alias('ModuleName')]
        [string]
        $Module
    )
    process
    {
        if ( Get-DscResource @PSBoundParameters )
        {
            return
        }

        if ( -not $Module )
        {
            throw "DSC Resource $Name not found."
        }
        throw "DSC Resource $Name not found in module $Module."
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