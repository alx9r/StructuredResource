[DscResource()]
class TestStub1
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

    [void] Set() { $this | Invoke-TestStub1 Set }
    [bool] Test() { return $this | Invoke-TestStub1 Test }

    [TestStub1] Get() { return $this }
}