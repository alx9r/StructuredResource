function New-TestInstructions
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true,
                   Position = 1,
                   ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName = $true)]
        [string]
        $ResourceName,

        [Parameter(Mandatory = $true,
                   Position = 2,
                   ValueFromPipelineByPropertyName = $true)]
        [string]
        $ModuleName
    )
    New-Object TestInstructions (New-TestParams @PSBoundParameters)
}

function Get-TestEnumerator
{
    [CmdletBinding()]
    param
    (
        [TestInstructions]
        $Enumerable
    )
    ,(
        Get-OrderedSteps |
            % { $_.Params = $Enumerable.Params; $_ }
    ).GetEnumerator()
}