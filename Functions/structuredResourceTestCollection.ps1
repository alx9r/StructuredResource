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

    .PARAMETER Kind
    The kind of tests to include.  Omitting this parameter will include all kinds.
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
        $Arguments,

        [TestKind[]]
        $Kind
    )
    process
    {
        if
        (
            -not $Arguments -and 
            ( 
                -not $Kind -or 
                ($Kind -contains 'Integration')
            )
        )
        {
            throw 'Arguments must be provided for integration tests.  Provide a value for either the Kind or Arguments parameter.'
        }

        $p = [hashtable]$PSBoundParameters
        $p.Remove('Kind')

        if ( $Kind )
        {
            return New-Object TestArgs -Property $p |
                Get-OrderedTests |
                ? { 
                    foreach ( $k in $Kind )
                    {
                        $_ | Test-StructuredResourceTestKind $k
                    }
                }
        }
        New-Object TestArgs -Property $p |
            Get-OrderedTests
    }
}
