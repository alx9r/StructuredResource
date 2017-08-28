function Invoke-ProcessTestResource1
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true,
                   Position = 1)]
        [Mode]
        $Mode
    )
}