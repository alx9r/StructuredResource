[DscResource()]
class TestResource1
{
    [DscProperty()]
    [Ensure]
    $Ensure = 'Present'

    [DscProperty(Key,Mandatory)]
    [int]
    $SomeKey

    [DscProperty()]
    [NullSafeString]
    $SourcePath

    [DscProperty()]
    [NullSafeString]
    $SomeValue = 'some default'

    [void] Set() { $this | Invoke-ProcessTestResource1 Set }
    [bool] Test() { return $this | Invoke-ProcessTestResource1 Test }

    [TestResource1] Get() { return $this }
}