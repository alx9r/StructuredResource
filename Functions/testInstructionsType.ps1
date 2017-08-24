class TestInstructions : System.Collections.IEnumerable {
    [TestParams]$Params

    [System.Collections.IEnumerator] GetEnumerator ()
    {
        return Get-TestEnumerator($this.Params)
    }

    TestInstructions ( [TestParams] $Params )
    {
        $this.Params = $Params
    }
}

class TestInstructionEnumerator : System.Collections.IEnumerator
{
    $UnderlyingEnumerator

    TestInstructionEnumerator ( $Enumerable )
    {
        $this.UnderlyingEnumerator = $Enumerable.GetEnumerator()
    }

    [object] get_Current()
    {
        return $this.UnderlyingEnumerator.get_Current()
    }

    [bool] MoveNext()
    {
        return $this.UnderlyingEnumerator.MoveNext()
    }

    Reset ()
    {
        $this.UnderlyingEnumerator.Reset()
    }

    Dispose ()
    {
        $this.UnderlyingEnumerator.Dispose()
    }
}