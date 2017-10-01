function ConvertTo-GuidelinesDocument
{
    param
    (
        [Parameter(Mandatory,
                   Position=1)]
        [string]
        $Title,

        [Parameter(Mandatory,
                   Position = 2)]
        [string]
        $Text,

        [Parameter(Mandatory,
                   Position = 3)]
        [hashtable]
        $SectionTitleLookup,

        [Parameter(Mandatory,
                   ValueFromPipeline)]
        $Test
    )
    begin
    {
        $t = [System.Collections.Queue]::new()
    }
    process
    {
        if ( [TestIdKind]::Guideline -eq ($Test.ID | Get-TestIdKind) )
        {
            $t.Enqueue($Test)
        }
    }
    end
    {
        $sections = $t |
            Group-Object GuidelineGroup |
            Sort-Object Name |
            % {
                [Section]@{
                    Title = "$($_.Name): $($SectionTitleLookup.$($_.Name))"
                    Sections = $_.Group |
                        Sort-Object IdNumber |
                        ConvertTo-GuidelinesSection
                }
            }

        [Section]@{
            Title = $Title
            Text = $Text
            Sections = [Section[]]$sections
        }
    }
}
function ConvertTo-GuidelinesSection
{
    param
    (
        [Parameter(Mandatory,
                   ValueFromPipeline)]
        [StructuredResourceTest]
        $Test
    )
    process
    {
        [Section]@{
            Title = "$($Test.ID) $($Test.Message)"
            Text = $Test.Explanation
        }
    }
}