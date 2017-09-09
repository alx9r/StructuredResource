class StructuredResourceTestCollection : System.Collections.IEnumerable {
    [TestParams]$Params

    [System.Collections.IEnumerator] GetEnumerator ()
    {
        return Get-TestEnumerator($this)
    }

    StructuredResourceTestCollection ( [TestParams] $Params )
    {
        $this.Params = $Params
    }
}
