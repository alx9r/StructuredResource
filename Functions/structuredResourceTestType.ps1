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


class StructuredResourceTestResult
{
    [StructuredResourceTest]$Test
    $TestOutput
    hidden [string] $_ID = (Accessor $this {
        get { $this.Test.ID }
    })
    Hidden [string] $_Message = (Accessor $this {
        get { $this.Test.ID }
    })
}

$splat = @{
    TypeName = 'StructuredResourceTestResult'
    DefaultDisplayPropertySet = 'ID','Message'
}
Update-TypeData @splat -ErrorAction SilentlyContinue
