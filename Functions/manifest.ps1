function Get-ModuleManifestPath
{
    param
    (
        [Parameter(ValueFromPipeline,
                   Mandatory)]
        [psmoduleinfo]
        $ModuleInfo
    )
    process
    {
        "$($ModuleInfo.ModuleBase)\$($ModuleInfo.Name).psd1"
    }
}

function Get-ModuleManifest
{
    param
    (
        [Parameter(ValueFromPipeline,
                   Mandatory)]
        [psmoduleinfo]
        $ModuleInfo
    )
    process
    {
        $ModuleInfo | 
            Get-ModuleManifestPath | 
            % { Get-Content $_ } | 
            Out-String | 
            Invoke-Expression
    }
}