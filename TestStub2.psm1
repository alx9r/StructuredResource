[DscResource()]
class TestStub2
{
    [DscProperty()]
    [Ensure]
    $Ensure = 'Present'

    [DscProperty(Key,Mandatory)]
    [string]
    $Presence

    [DscProperty()]
    [NullSafeString]
    $Incorrigible

    [DscProperty()]
    [NullSafeString]
    $Corrigible

    [void] Set() { $this | Invoke-ProcessTestStub2 Set }
    [bool] Test() { return $this | Invoke-ProcessTestStub2 Test }

    [TestStub2] Get() { return $this }
}