function Select-Argument
{
    param
    (
        [Parameter(Mandatory,
                   Position = 1)]
        [hashtable]
        $Arguments,

        [Parameter(Mandatory,
                   ValueFromPipeline)]
        [System.Management.Automation.ParameterMetadata]
        $ParameterInfo
    )
    process
    {
    }
}