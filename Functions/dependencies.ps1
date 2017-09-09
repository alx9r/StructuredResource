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
        $Tests = (Get-Tests)
    )
    Get-OrderedTestIds $Tests |
        % { 
            $step = New-Object StructuredResourceTest -Property $Tests.get_Item($_)
            $step.ID = $_
            $step
        }
}