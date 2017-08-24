class TestInstructions : System.Collections.IEnumerable {
    [TestParams]$Params

    [System.Collections.IEnumerator] GetEnumerator ()
    {
        return Get-TestEnumerator($this)
    }

    TestInstructions ( [TestParams] $Params )
    {
        $this.Params = $Params
    }
}
