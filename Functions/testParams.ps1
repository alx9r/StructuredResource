function New-TestParams
{
    [CmdletBinding()]
    param
    (
        [Parameter(position = 1,
                   Mandatory = $true)]
        $ResourceName,

        [Parameter(position = 2,
                   Mandatory = $true)]
        $ModuleName
    )
    New-Object TestParams -Property $PSBoundParameters
}