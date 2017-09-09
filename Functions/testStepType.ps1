class StructuredResourceTest
{
    [string]$ID
    [string[]]$Prerequisites
    [string]$Message
    [TestParams]$Params
    [scriptblock]$Scriptblock
}

$splat = @{
    TypeName = 'StructuredResourceTest'
    DefaultDisplayPropertySet = ‘ID’,'Prerequisites','Message'
}
Update-TypeData @splat -ErrorAction SilentlyContinue