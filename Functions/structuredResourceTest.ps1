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
        [Parameter(ValueFromPipeline,
                   Mandatory)]
        [StructuredResourceTest]
        $InputObject
    )
    process
    {
        try
        {
            $testOutput = $InputObject.Arguments | % $InputObject.Scriptblock
        }
        catch
        {
            throw [System.Exception]::new(
                $($InputObject.FullMessage),
                $_.Exception
            )
        }

        New-Object StructuredResourceTestResult -Property @{
            TestOutput = $testOutput
            Test = $InputObject
        }
    }
}

function Get-StructuredResourceTestKind
{
    [CmdletBinding()]
    param
    (
        [Parameter(ValueFromPipeline,
                   Mandatory)]
        [StructuredResourceTest]
        $InputObject
    )
    process
    {
        if ( $InputObject.ScriptBlock -match 'IntegrationTest' )
        {
            return [TestKind]::Integration
        }
        return [TestKind]::Unit
    }
}

function Test-StructuredResourceTestKind
{
    [CmdletBinding()]
    param
    (
        [Parameter(Position=1,
                   Mandatory)]
        [TestKind]
        $Kind,

        [Parameter(ValueFromPipeline,
                   Mandatory)]
        [StructuredResourceTest]
        $InputObject
    )
    process
    {
        $Kind -eq ($InputObject | Get-StructuredResourceTestKind)
    }
}
