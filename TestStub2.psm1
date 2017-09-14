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

    [void] Set() { $this | Invoke-TestStub2 Set }
    [bool] Test() { return $this | Invoke-TestStub2 }

    [TestStub2] Get() { return $this }
}