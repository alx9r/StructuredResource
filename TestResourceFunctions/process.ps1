function Invoke-ProcessTestResource1
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true,
                   Position = 1)]
        [Mode]
        $Mode,

        [Parameter(Position = 2)]
        [Ensure]
        $Ensure = 'Present'
    )
}