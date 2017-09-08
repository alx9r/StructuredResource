function Invoke-StructuredResourceTest
{
    [CmdletBinding()]
    param
    (
        [Parameter(ValueFromPipeline = $true)]
        [TestStep]
        $Step
    )
    process
    {
        $Step.Params | % $Step.Scriptblock
    }
}