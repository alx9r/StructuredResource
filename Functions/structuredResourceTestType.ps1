class StructuredResourceTestBase
{
    [string[]]$Prerequisites
    [string]$Message
    [scriptblock]$Scriptblock
    [string]$Explanation
}
class StructuredResourceTest : StructuredResourceTestBase
{
    [string]$ID
    [TestArgs]$Arguments
    hidden [string]$_FullMessage = (Accessor $this {
        get { "$($this.ID) - $($this.Message)" }
    })
    hidden [string]$_GuidelineGroup = (Accessor $this {
        get { $this.ID | Get-GuidelineGroup }
    })
    hidden [string]$_IdNumber = (Accessor $this {
        get { $this.ID | Get-TestIdNumber }
    })

    hidden Init([StructuredResourceTestBase]$b)
    {
        $this.Prerequisites = $b.Prerequisites
        $this.Message = $b.Message
        $this.Scriptblock = $b.Scriptblock
        $this.Explanation = $b.Explanation
    }

    StructuredResourceTest(){}
    StructuredResourceTest ([StructuredResourceTestBase]$b)
    {
        $this.Init($b)
    }
    StructuredResourceTest ([StructuredResourceTestBase]$b,[string]$ID)
    {
        $this.Init($b)
        $this.ID = $ID
    }
    StructuredResourceTest ( [hashtable] $h )
    {
        $this.Prerequisites = $h.Prerequisites
        $this.Message = $h.Message
        $this.Scriptblock = $h.Scriptblock
        $this.Explanation = $h.Explanation
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
