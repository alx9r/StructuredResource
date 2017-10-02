function Test-ModuleExists
{
    param
    (
        [Parameter(Position = 1,
                   ValueFromPipeline,
                   ValueFromPipelineByPropertyName,
                   Mandatory)]
        [Alias('ModuleName')]
        [string]
        $Name
    )
    process
    {
        return [bool](Get-Module $Name -ListAvailable)
    }
}

# function Assert-ModuleExists
Get-Command Test-ModuleExists |
    New-Asserter 'Module $Name not found.' |
    Invoke-Expression

function Test-ModuleImported
{
    param
    (
        [Parameter(Position = 1,
                   ValueFromPipeline,
                   ValueFromPipelineByPropertyName,
                   Mandatory)]
        [Alias('ModuleName')]
        [string]
        $Name
    )
    process
    {
        return [bool](Get-Module $Name)
    }
}

# function Assert-ModuleImported
Get-Command Test-ModuleImported |
    New-Asserter 'Module $Name not imported.' |
    Invoke-Expression

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

# function Test-NestedModule
Get-Command Get-NestedModule |
    New-Tester |
    Invoke-Expression

# function Assert-NestedModule
Get-Command Test-NestedModule |
    New-Asserter 'Nested module $NestedName not found module $Name.' |
    Invoke-Expression

function Test-DscResource
{
    param
    (
        [Parameter(Position = 1,
                   ValueFromPipeline,
                   ValueFromPipelineByPropertyName,
                   Mandatory)]
        [Alias('ResourceName')]
        [string]
        $Name,

        [Parameter(Position = 2,
                   ValueFromPipeline,
                   ValueFromPipelineByPropertyName)]
        [Alias('ModuleName')]
        [string]
        $Module
    )
    process
    {
        [bool](Get-DscResource @PSBoundParameters)
    }
}

# function Assert-DscResource
Get-Command Test-DscResource |
    New-Asserter {
        @{
            $true =  "DSC Resource $Name not found in module $Module."
            $false = "DSC Resource $Name not found."
        }.([bool]$Module)
    }|
    Invoke-Expression

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
        "Invoke-$ResourceName"
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

# function Test-PublicResourceFunction
Get-Command Get-PublicResourceFunction |
    New-Tester |
    Invoke-Expression

# function Assert-PublicResourceFunction
Get-Command Test-PublicResourceFunction |
    New-Asserter {"Public resource function $(Get-PublicResourceFunctionCommandName $ResourceName) not found in module $ModuleName."} |
    Invoke-Expression
