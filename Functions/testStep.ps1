function Invoke-TestStep
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