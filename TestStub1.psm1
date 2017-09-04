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

    [void] Set() { $this | Invoke-ProcessTestStub1 Set }
    [bool] Test() { return $this | Invoke-ProcessTestStub1 Test }

    [TestStub1] Get() { return $this }
}