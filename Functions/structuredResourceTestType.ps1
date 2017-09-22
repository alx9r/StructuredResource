class StructuredResourceTest
{
    [string]$ID
    [string[]]$Prerequisites
    [string]$Message
    [TestArgs]$Arguments
    [scriptblock]$Scriptblock
    hidden [string]$_FullMessage = (Accessor $this {
        get { "$($this.ID) - $($this.Message)" }
    })
}

$splat = @{
    TypeName = 'StructuredResourceTest'
    DefaultDisplayPropertySet = ‘ID’,'Prerequisites','Message'
}
Update-TypeData @splat -ErrorAction SilentlyContinue