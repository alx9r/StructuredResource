function New-StructuredResourceTest
{
    <#
	.SYNOPSIS
	Creates an object for testing a structured resource.
	
	.DESCRIPTION
	New-StructuredResourceTest creates an object for testing a structured resource.  The tests can be invoked by piping the object to Invoke-StructuredResourceTest.
	
	.PARAMETER ResourceName
	The name of the structured resource to test.
	
	.PARAMETER ModuleName
	The name of the module containing the structured resource to test.
	
	.PARAMETER Arguments
	A hashtable containing the arguments used to perform integration tests on the resource. 
    #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory,
                   Position = 1,
                   ValueFromPipeline,
                   ValueFromPipelineByPropertyName)]
        [string]
        $ResourceName,

        [Parameter(Mandatory,
                   Position = 2,
                   ValueFromPipelineByPropertyName)]
        [string]
        $ModuleName,

        [Parameter(Position = 3,
                   ValueFromPipelineByPropertyName)]
        [hashtable]
        $Arguments
    )
    New-Object TestInstructions (New-TestParams @PSBoundParameters)
}

function Get-TestEnumerator
{
    [CmdletBinding()]
    param
    (
        [TestInstructions]
        $Enumerable
    )
    ,(
        Get-OrderedSteps |
            ? { $_.Scriptblock } |
            % { $_.Params = $Enumerable.Params; $_ }
    ).GetEnumerator()
}