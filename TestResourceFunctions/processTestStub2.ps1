$testStub2 = @{
    Presence = 'Absent'
    Property = [string]::Empty
}

function Invoke-ProcessTestStub2
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName,
                   Position = 1)]
        [Mode]
        $Mode,

        [Parameter(Position = 2,
                   ValueFromPipelineByPropertyName)]
        [Ensure]
        $Ensure = 'Present',

        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [ValidateSet('Corrigible','Incorrigible')]
        [StructuredDsc('Key')]
        [string]
        $Presence,

        [Parameter(ValueFromPipelineByPropertyname)]
        [NullsafeString]
        $Incorrigible,

        [Parameter(ValueFromPipelineByPropertyname)]
        [NullsafeString]
        $Corrigible
    )
    process
    {
        $_presence = @{
            Corrigible = $testStub2.Presence
            Incorrigible = 'Absent'
        }.$Presence

        if ( $Mode -eq 'Test' -and
             $null -eq $Corrigible )
        {
            return $_presence -eq $Ensure
        }
        if ( $Mode -eq 'Test' )
        {
            return ( $_presence -eq $Ensure ) -and 
                   ( $testStub2.Property -eq $Corrigible )
        }

        $testStub2.Presence = @{
            Corrigible = $Ensure
            Incorrigible = 'Absent'
        }.$Presence
        
        if ($null -ne $Corrigible)
        {
            $testStub2.Property = $Corrigible.Value
        }
    }
}

function Reset-TestStub2 { 
    $testStub2.Presence = 'Absent'
    $testStub2.Property = [string]::Empty
}