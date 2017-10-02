Import-Module StructuredResource -Force

InModuleScope StructuredResource {

Describe Get-AttributeArgument {
    function f {
        param (
            [Parameter(Position=1)]$x
        )
    }
    $a = Get-Command f |
        Get-ParameterMetaData x |
        Get-ParameterAttribute Parameter
    It 'returns argument' {
        $r = $a | Get-AttributeArgument Position
        $r | Should -Be 1
    }
}

[DscResource()]
class c {
    [DscProperty(Key,Mandatory)]
    [string]
    $a

    [void] Set() {}
    [bool] Test() { return $true }
    [c] Get() { return $this }
}

Describe Get-CustomAttributeArgument {
    $a = [c] | Get-MemberProperty 'a' | Get-PropertyCustomAttribute 'DscProperty'
    Context 'whole object' {
        It 'returns one object' {
            $r = $a | Get-CustomAttributeArgument 'Key'
            $r.Count | Should be 1
        }
        It 'returns argument object' {
            $r = $a | Get-CustomAttributeArgument 'Key'
            $r | Should beOfType([System.Reflection.CustomAttributeNamedArgument])
        }
        It 'returns nothing for non-existent argument' {
            $r = $a | Get-CustomAttributeArgument 'non-existent'
            $r | Should beNullOrEmpty
        }
    }
    Context '-ValueOnly' {
        It 'returns value' {
            $r = $a | Get-CustomAttributeArgument 'Key' -ValueOnly
            $r | Should be $true
        }
    }
}
}
