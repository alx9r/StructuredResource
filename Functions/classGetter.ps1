function Get-TypeFromModule
{
    [CmdletBinding()]
    param
    (
        [Parameter(Position = 1,
                   ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName = $true,
                   Mandatory = $true)]
        [string]
        $Name,

        [Parameter(Position = 2,
                   ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName = $true,
                   Mandatory = $true)]
        [psmoduleinfo]
        $ModuleInfo
    )
    process
    {
        & ($ModuleInfo | Import-Module -PassThru).NewBoundScriptBlock(
            [scriptblock]::Create("[$Name]")
        )
        Remove-Module $ModuleInfo
    }
}

function New-ObjectFromModule
{
    [CmdletBinding()]
    param
    (
        [Parameter(Position = 1,
                   ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName = $true,
                   Mandatory = $true)]
        [string]
        $Name,

        [Parameter(Position = 2,
                   ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName = $true,
                   Mandatory = $true)]
        [psmoduleinfo]
        $ModuleInfo
    )
    process
    {
        & ($ModuleInfo | Import-Module -PassThru).NewBoundScriptBlock(
            [scriptblock]::Create("[$Name]::new()")
        )
        Remove-Module $ModuleInfo

    }
}
