function Assert-Value
{
    param
    (
        [Parameter(Mandatory,
                   Position = 1)]
        $Expected,

        [Parameter(Mandatory,
                   ValueFromPipeline)]
        $Actual
    )
    process
    {
        if ( $Expected -ne $Actual )
        {
            throw "Expected $Actual to be $Expected."
        }
    }
}