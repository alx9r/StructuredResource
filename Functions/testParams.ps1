function New-TestParams
{
    [CmdletBinding()]
    param
    (
        [Parameter(position = 1,
                   Mandatory)]
        $ResourceName,

        [Parameter(position = 2,
                   Mandatory)]
        $ModuleName,

        [Parameter(position = 3)]
        $Arguments                   
    )
    New-Object TestParams -Property $PSBoundParameters
}