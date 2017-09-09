function Invoke-StructuredResourceTest
{
    <#

    #>
    [CmdletBinding()]
    param
    (
        [Parameter(ValueFromPipeline = $true)]
        [StructuredResourceTest]
        $Test
    )
    process
    {
        $Test.Params | % $Test.Scriptblock
    }
}