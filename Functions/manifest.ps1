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
        $output = $ModuleInfo |
            Get-ModuleManifestPath |
            % { Get-Content $_ } |
            Out-String |
            Invoke-Expression
        try{$output}
        catch
        {
            throw [System.Exception]::new(
                "module manifest for $($ModuleInfo.Name) at path $($ModuleInfo | Get-ModuleManifestPath)",
                $_.Exception
            )
        }
    }
}
