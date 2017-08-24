[DscResource()]
class TestResource1
{
    [DscProperty(Key,Mandatory)]
    [string]
    $Key

    [DscProperty()]
    [string]
    $Value

    [void] Set() { $this | Invoke-ProcessTestResource1 Set }
    [bool] Test() { return $this | Invoke-ProcessTestResource1 Test }

    [TestResource1] Get() { return $this }
}