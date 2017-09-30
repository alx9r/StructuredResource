function ConvertTo-MdSection
{
    param
    (
        [int]
        $SectionDepth = 1,

        [Parameter(ValueFromPipeline)]
        [Section]
        $Section
    )
    process
    {
        [Text]::new($Section.Title,"Title$SectionDepth")

        $Section.Text | % { [Text]$_ }

        $Section.Sections | 
            ? {$_} |
            ConvertTo-MdSection ($SectionDepth+1)
    }
}

function ConvertTo-MdText
{
    param
    (
        [Parameter(ValueFromPipelineByPropertyName,
                   Position=1)]
        [string]
        $Text,

        [Parameter(ValueFromPipelineByPropertyName,
                   Position=2)]
        [TextFormat]
        $Format
    )
    process
    {
        if ( $Format -eq 'None' )
        {
            return $Text
        }
        if ( $Format -match 'Title' )
        {
            return "$('#'*([int]$Format)) $Text"
        }
        if ( $Format -match 'Bold' )
        {
            return "**$Text**"
        }
        throw "Formatting for format $Format not implemented."
    }
}