class StructuredResourceTestBase
{
    [string[]]$Prerequisites
    [string]$Message
    [scriptblock]$Scriptblock
}
class StructuredResourceTest : StructuredResourceTestBase
{
    [string]$ID
    [TestArgs]$Arguments
    hidden [string]$_FullMessage = (Accessor $this {
        get { "$($this.ID) - $($this.Message)" }
    })

    StructuredResourceTest(){}
    StructuredResourceTest ([StructuredResourceTestBase]$b)
    {
        $this.Prerequisites = $b.Prerequisites
        $this.Message = $b.Message
        $this.Scriptblock = $b.Scriptblock
    }
    StructuredResourceTest ( [hashtable] $h )
    {
        $this.Prerequisites = $h.Prerequisites
        $this.Message = $h.Message
        $this.Scriptblock = $h.Scriptblock
        $this.ID = $h.ID
        $this.Arguments = $h.Arguments
    }
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
