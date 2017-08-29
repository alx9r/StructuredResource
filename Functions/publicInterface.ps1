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

        foreach ( $module in  $nestedModules | ? { $_.Name -like $NestedName } )
        {
            try
            {
                $module
            }
            catch
            {
                throw New-Object System.Exception (
                    "NestedName,Name: $NestedName,$Name",
                    $_.Exception
                )
            }
        }
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

function Get-PublicResourceFunctionCommandName
{
    [CmdletBinding()]
    param
    (
        [Parameter(Position = 1,
                   ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName = $true,
                   Mandatory = $true)]
        [string]
        $ResourceName
    )
    process
    {
        "Invoke-Process$ResourceName"
    }
}

function Get-PublicResourceFunction
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
        $splat = @{
            Name = Get-PublicResourceFunctionCommandName $ResourceName
            Module = $ModuleName
        }
        $command = Get-Command @splat -ea SilentlyContinue

        try
        {
            $command
        }
        catch
        {
            throw New-Object System.Exception (
                "ResourceName,ModuleName: $ResourceName,$ModuleName",
                $_.Exception
            )            
        }
    }
}

function Assert-PublicResourceFunction
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
        if ( -not (Get-PublicResourceFunction @PSBoundParameters) )
        {
            throw "Public resource function $(Get-PublicResourceFunctionCommandName $ResourceName) not found in module $ModuleName."
        }
    }    
}