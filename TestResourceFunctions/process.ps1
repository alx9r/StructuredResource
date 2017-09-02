function Invoke-ProcessTestResource1
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true,
                   ValueFromPipelineByPropertyName = $true,
                   Position = 1)]
        [Mode]
        $Mode,

        [Parameter(Position = 2,
                   ValueFromPipelineByPropertyName = $true)]
        [Ensure]
        $Ensure = 'Present',

        [Parameter(ValueFromPipelineByPropertyname)]
        [StructuredDsc('Hint')]
        [NullsafeString]
        $SourcePath,

        [Parameter(Mandatory = $true,
                   ValueFromPipelineByPropertyname = $true)]
        [int]
        $SomeKey = 0,

        [Parameter(ValueFromPipelineByPropertyname = $true)]
        [NullsafeString]
        $SomeValue = 'some default'
    )
}