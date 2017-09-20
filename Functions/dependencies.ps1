function ConvertTo-DependencyGraph
{
    [CmdletBinding()]
    param
    (
        [Parameter(position = 1,
                   Mandatory)]
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

function Get-OrderedTests
{
    [CmdletBinding()]
    param
    (
        [Parameter(ValueFromPipeline,
                   Mandatory)]
        [TestArgs]
        $TestArgs,

        [hashtable]
        $Tests = (Get-Tests)
    )
    Get-OrderedTestIds $Tests |
        % { 
            $test = New-Object StructuredResourceTest -Property $Tests.get_Item($_)
            $test.ID = $_
            $test.Params = $TestArgs
            $test
        }
}