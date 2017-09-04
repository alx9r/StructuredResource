Import-Module StructuredDscResourceCheck -Force

InModuleScope StructuredDscResourceCheck {

Describe New-PresenceTest {
    function f {
        param
        (
            [Parameter(position=1)]$Mode,
            [Parameter(position=2)]$Ensure,
            $Key1
        )
        if ( $Key1 -eq 'throw' )
        {
            throw 'exception in f'
        }
    }
    $r = @{ Key1 = 'value' } | New-PresenceTest (Get-Command f)
    It 'outputs objects' {
        $r[0] | Should beOfType([pscustomobject])
        $r[-1] | Should beOfType([pscustomobject])
    }
    It 'populates named args' {
        $r[0].NamedArgs.Keys.Key1 | Should be 'value'
    }
    It 'populates scriptblock' {
        $r[0].Scriptblock | Should beOfType([scriptblock])
    }
    It 'populates message' {
        $r[0].Message | Should beOfType([string])
        $r[0].Message | Should not beNullOrEmpty
    }
    It 'every even object is the same (because it should be a reset)' {
        ($r | measure | % Count) % 2 | Should be 0
        $r[0].Scriptblock | Should be $r[2].Scriptblock
    }
    It 'every odd object is different (because it should be a different test)' {
        $r[1].Scriptblock | Should not be $r[3].Scriptblock
    }
    Context 'pipeline exception' {
        try
        {
            @{ Key1 = 'throw' } | 
                New-PresenceTest (Get-Command f) |
                Invoke-Scriptblock
        }
        catch
        {
            $e = $_
        }
        It 'passes an exception through' {
            $e | Should not beNullOrEmpty
        }
        It 'outer exception' {
            $e.Exception.Message | Should match 'reset'
        }
        It 'inner exception' {
            $e.Exception.InnerException.Message | Should match 'in f'
        }
    }
}
}