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

        [Parameter(ValueFromPipelineByPropertyname = $true)]
        [int]
        $SomeKey = 0,

        [Parameter(ValueFromPipelineByPropertyname = $true,
                   Mandatory = $true)]
        [string]
        $SomeValue = 'some default'
    )
}