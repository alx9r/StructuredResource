$tests = @{
    'PI.0' = @{
        Message = 'Each resource is published using a class with a [DscResource()] attribute.'
        Prerequisites = 'T004'
    }
    'PI.1' = @{
        Message = 'Each public resource class is accessible in a nested module of its parent.'
        Prerequisites = 'T001'
    }
    T001 = @{
        Message = 'Get TypeInfo from nested module.'
        Prerequisites = 'T002'
        Scriptblock = { $_ | Assert-NestedModuleType }
    }
    T002 = @{
        Message = 'Get nested module from module.'
        Prerequisites = 'T003'
        Scriptblock = { $_ | Assert-NestedModule }
    }
    T003 = @{
        Message = 'Get module.'
        Scriptblock = { $_ | Assert-ModuleExists }
    }
    T004 = @{
        Message = 'Check for [DscResource()] attribute.'
        Scriptblock = { $_ | Assert-DscResourceAttribute }
    }
}

function Get-Test
{
    [CmdletBinding()]
    param
    (
        [Parameter(Position = 1,
                   ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyname = $true,
                   Mandatory = $true)]
        [string]
        $ID,

        [hashtable]
        $Dependencies = $tests
    )
    process
    {
    }
}

function ConvertTo-DependencyGraph
{
    [CmdletBinding()]
    param
    (
        [Parameter(position = 1,
                   Mandatory = $true)]
        [hashtable]
        $Dependencies
    )
    $output = @{}
    foreach ( $key in $Dependencies.Keys )
    {
        $output.$key = $Dependencies.get_Item($key).Prerequisites
    }
    return $output
}

function Get-SortedTestIds
{
    [CmdletBinding()]
    param
    (
        [Parameter(position = 1)]
        [hashtable]
        $Dependencies = $tests
    )

    ConvertTo-DependencyGraph $Dependencies | Invoke-SortGraph
}