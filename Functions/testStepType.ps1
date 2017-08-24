class TestStep
{
    [string]$ID
    [string[]]$Prerequisites
    [string]$Message
    [TestParams]$Params
    [scriptblock]$Scriptblock
}

$splat = @{
    TypeName = 'TestStep'
    DefaultDisplayPropertySet = ‘ID’,'Prerequisites','Message'
}
Update-TypeData @splat -ErrorAction SilentlyContinue