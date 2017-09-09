function Invoke-StructuredResourceTest
{
    <#
	.SYNOPSIS
	Runs a structured resource test.
	
	.DESCRIPTION
	Invoke-StructuredResourceTest runs a test created using New-StructuredResourceTest.
	
	.PARAMETER InputObject
	The test object created using New-StructuredResourceTest.
    #>
    [CmdletBinding()]
    param
    (
        [Parameter(ValueFromPipeline = $true)]
        [StructuredResourceTest]
        $InputObject
    )
    process
    {
        $InputObject.Params | % $InputObject.Scriptblock
    }
}