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

Describe Test-AttributeArgument {
    function f {
        param (
            [Parameter(position=1)]
            $x
        )
    }
    $p = Get-Command f |
        Get-ParameterMetaData x
    Context 'existence' {
        It 'true' {
            $r = $p | 
                Get-ParameterAttribute Parameter |
                Test-AttributeArgument Position
            $r | Should -Be $true
        }
        It 'false' {
            $r = $p |
                Get-ParameterAttribute Parameter |
                Test-AttributeArgument 'NotAnAttribute'
            $r | Should -Be $false
        }
    }
    Context 'value' {
        It 'true' {
            $r = $p |
                Get-ParameterAttribute Parameter |
                Test-AttributeArgument Position 1
            $r | Should be $true
        }
        It 'false' {
            $r = $p |
                Get-ParameterAttribute Parameter |
                Test-AttributeArgument Position 2
            $r | Should be $false
        }
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

Describe Test-CustomAttributeArgument {
    $a = [c] | Get-MemberProperty 'a' | Get-PropertyCustomAttribute 'DscProperty'
    Context 'existence' {
        It 'true' {
            $r = $a | Test-CustomAttributeArgument 'Key'
            $r | Should be $true
        }
        It 'false' {
            $r = $a | Test-CustomAttributeArgument 'non-existent'
            $r | Should be $false
        }
    }
    Context 'value' {
        Mock Get-CustomAttributeArgument { 'value' } -Verifiable
        It 'true' {
            $r = $a | Test-CustomAttributeArgument 'Key' 'value'
            $r | Should be $true
        }
        It 'false' {
            $r = $a | Test-CustomAttributeArgument 'Key' 'not value'
            $r | Should be $false
        }
        It 'invokes commands' {
            Assert-MockCalled Get-CustomAttributeArgument 2 {
                $ArgumentName -eq 'Key' -and
                $CustomAttributeData.AttributeType.Name -eq 'DscPropertyAttribute'
            }
        }
    }
}
}