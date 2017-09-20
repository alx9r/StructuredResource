class StructuredResourceTest
{
    [string]$ID
    [string[]]$Prerequisites
    [string]$Message
    [TestArgs]$Params
    [scriptblock]$Scriptblock
}

$splat = @{
    TypeName = 'StructuredResourceTest'
    DefaultDisplayPropertySet = ‘ID’,'Prerequisites','Message'
}
Update-TypeData @splat -ErrorAction SilentlyContinue