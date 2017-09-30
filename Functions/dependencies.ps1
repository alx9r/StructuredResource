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
                   Mandatory,
                   ValueFromPipeline)]
        [hashtable]
        $Prerequisites
    )
    $output = @{}
    foreach ( $prereqKey in $Prerequisites.Keys )
    {
        foreach ( $depKey in $Prerequisites.get_Item($prereqKey).Prerequisites )
        {
            $output.$depKey = @($output.$depKey)+@($prereqKey) | ? {$null -ne $_}
        }
    }
    return $output
}

function Get-OrderedTestIds
{
    param
    (
        [Parameter(position = 1,
                   Mandatory,
                   ValueFromPipeline)]
        [hashtable]
        $Dependencies
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
                $test = [StructuredResourceTest]($Tests.$_)
                $test.ID = $_
                $test.Arguments = $TestArgs
                $test
            }
    }
}

function Get-DependentGuideline
{
    param
    (
        [Parameter(Position = 1,
                   Mandatory)]
        [string]
        $Id,

        [hashtable]
        $Tests = (Get-Tests)
    )
    Get-DependentGuidelineImpl $Id -Tests $Tests |
        select -Unique
}

function Get-DependentGuidelineImpl
{
    param
    (
        [Parameter(Position = 1,
                   Mandatory)]
        [string]
        $Id,

        [hashtable]
        $Tests,

        [hashtable]
        $Dependents
    )
    if ( -not $Dependents )
    {
        $Dependents = ConvertTo-DependentsGraph $Tests
    }

    foreach ( $dependent in $dependents.$Id )
    {
        if ( $dependent | Test-TestIdKind -Value 'Guideline' )
        {
            $dependent
        }
        else
        {
            Get-DependentGuidelineImpl $dependent -Tests $Tests -Dependents $Dependents
        }
    }
}