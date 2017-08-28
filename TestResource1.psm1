[DscResource()]
class TestResource1
{
    [DscProperty(Key,Mandatory)]
    [string]
    $SomeKey

    [DscProperty()]
    [string]
    $SomeValue

    [DscProperty()]
    [Ensure]
    $Ensure

    [void] Set() { $this | Invoke-ProcessTestResource1 Set }
    [bool] Test() { return $this | Invoke-ProcessTestResource1 Test }

    [TestResource1] Get() { return $this }
}