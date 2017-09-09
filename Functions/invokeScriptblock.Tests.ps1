Import-Module StructuredResource -Force

InModuleScope StructuredResource {

Describe Invoke-Scriptblock {
    Context 'no pipeline' {
        $sb = { 
            param($pos1,$pos2,$named1,$named2)
            [pscustomobject]@{
                pos1 = $pos1
                pos2 = $pos2
                named1 = $named1
                named2 = $named2
            }
        }
        It 'returns script output' {
            $r = $sb | Invoke-Scriptblock
            $r | measure | % count | Should be 1
            $r | Should beOfType ([pscustomobject])
        }
        It 'passes positional arguments' {
            $r = $sb | Invoke-Scriptblock 1,2
            $r.pos1 | Should be 1
            $r.pos2 | Should be 2
        }
        It 'passes named arguments' {
            $r = $sb | Invoke-Scriptblock -NamedArgs @{ named1 = 1; named2 = 2 }
            $r.named1 | Should be 1
            $r.named2 | Should be 2
        }
    }
    Context 'pipeline' {
        $sb = { $_ }
        It 'returns script output' {
            $r = $sb | Invoke-Scriptblock -PipelineObjects 1,2
            $r.Count | Should be 2
            $r[0] | Should be 1
            $r[1] | Should be 2
        }
    }
}
}