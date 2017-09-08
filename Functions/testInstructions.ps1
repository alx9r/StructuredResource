function New-StructuredResourceTest
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory,
                   Position = 1,
                   ValueFromPipeline,
                   ValueFromPipelineByPropertyName)]
        [string]
        $ResourceName,

        [Parameter(Mandatory,
                   Position = 2,
                   ValueFromPipelineByPropertyName)]
        [string]
        $ModuleName,

        [Parameter(Position = 3,
                   ValueFromPipelineByPropertyName)]
        [hashtable]
        $Arguments
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
            ? { $_.Scriptblock } |
            % { $_.Params = $Enumerable.Params; $_ }
    ).GetEnumerator()
}