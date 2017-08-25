$tests = @{
    'PI.1' = @{
        Message = 'Each resource is published using a class with a [DscResource()] attribute.'
        Prerequisites = 'T004'
    }
    'L.1' = @{
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
        Prerequisites = 'T001'
        Scriptblock = { $_ | Assert-DscResourceAttribute }
    }
    'PI.2' = @{
        Message = 'Each public resource is accessible using Get-DscResource.'
        Prerequisites = 'T005'
    }
    T005 = @{
        Message = 'Get resource using Get-DscResource.'
        Scriptblock = { $_ | Assert-DscResource }
    }
    'PI.3' = @{
        Message = 'Each public resource has a corresponding public function.'
        Prerequisites = 'T006'
    }
    'PI.4' = @{
        Message = 'The function corresponding to public resource ResourceName is named Invoke-ProcessResourceName.'
        Prerequisites = 'T006'
    }
    T006 = @{
        Message = 'Get public resource function.'
        Scriptblock = { $_ | Assert-PublicResourceFunction }
        Prerequisites = 'T003'
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

function Get-OrderedTestIds
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

function Get-OrderedSteps
{
    [CmdletBinding()]
    param
    (
        [Parameter(position = 1)]
        [hashtable]
        $Tests = $tests
    )
    Get-OrderedTestIds $Tests |
        % { 
            $step = New-Object TestStep -Property $Tests.get_Item($_)
            $step.ID = $_
            $step
        }
}