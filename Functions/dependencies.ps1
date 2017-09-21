function ConvertTo-PrerequisitesGraph
{
    param
    (
        [Parameter(position = 1,
                   Mandatory)]
        [hashtable]
        $Prerequisites
    )
    $output = @{}
    foreach ( $key in $Prerequisites.Keys )
    {
        $output.$key = $Prerequisites.get_Item($key).Prerequisites
    }
    return $output
}

function ConvertTo-DependentsGraph
{
    param
    (
        [Parameter(position = 1,
                   Mandatory)]
        [hashtable]
        $Prerequisites
    )
    $output = @{}
    foreach ( $prereqKey in $Prerequisites.Keys )
    {
        foreach ( $depKey in $Prerequisites.get_Item($prereqKey).Prerequisites )
        {
            $output.$depKey = $output.$depKey,$prereqKey | ? {$null -ne $_}
        }
    }
    return $output
}

function Get-OrderedTestIds
{
    param
    (
        [Parameter(position = 1)]
        [hashtable]
        $Dependencies = $tests
    )

    ConvertTo-PrerequisitesGraph $Dependencies | Invoke-SortGraph
}

function Get-OrderedTests
{
    param
    (
        [Parameter(ValueFromPipeline,
                   Mandatory)]
        [TestArgs]
        $TestArgs,

        [hashtable]
        $Tests = (Get-Tests)
    )
    process
    {
        Get-OrderedTestIds $Tests |
            % { 
                $test = New-Object StructuredResourceTest -Property $Tests.get_Item($_)
                $test.ID = $_
                $test.Arguments = $TestArgs
                $test
            }
    }
}