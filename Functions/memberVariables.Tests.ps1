Import-Module StructuredResource -Force

InModuleScope StructuredResource {

Describe Get-MemberProperty {
    class c { $a;$b }
    It 'returns all properties' {
        $r = [c] | Get-MemberProperty
        $r.Count | Should be 2
        $r | ? {$_.Name -eq 'a' } | Should not beNullOrEmpty
    }
    It 'returns selected property' {
        $r = [c] | Get-MemberProperty 'a'
        $r.Count | Should be 1
        $r.Name | Should be 'a'
    }
    It 'exception' {
        Get-Command Get-MemberProperty |
            Assert-PipelineException 'a' -Pipe ([c]) -Match 'property a','type c'
    }
}

Describe Test-MemberProperty {
    class c { $a }
    It 'true' {
        $r = [c] | Test-MemberProperty 'a'
        $r | Should be $true
    }
    It 'false' {
        $r = [c] | Test-MemberProperty 'b'
        $r | Should be $false
    }
}

Describe Assert-MemberProperty {
    class c {}
    Context 'exists' {
        Mock Test-MemberProperty { $true } -Verifiable
        It 'returns nothing' {
            $r = [c] | Assert-MemberProperty 'a'
            $r | Should beNullOrEmpty
        }
        It 'invokes command' {
            Assert-MockCalled Test-MemberProperty 1 {
                $TypeInfo.Name -eq 'c' -and
                $PropertyName -eq 'a'
            }
        }
        It '-Not throws' {
            { [c] | Assert-MemberProperty -Not 'a' } |
                Should throw 'a found'
        }
        It 'invokes command' {
            Assert-MockCalled Test-MemberProperty 1 {
                $PropertyName -eq 'a'
            }
        }
    }
    Context 'not exists' {
        Mock Test-MemberProperty -Verifiable
        It 'throws' {
            { [c] | Assert-MemberProperty 'a' } |
                Should throw 'a not found'
        }
        It '-Not returns nothing' {
            $r = [c] | Assert-MemberProperty -Not 'a'
            $r | Should beNullOrEmpty
        }
    }
}

[DscResource()]
class c {
    [DscProperty(Key,Mandatory)]
    [string]
    $a
    $b
    [void] Set() {}
    [bool] Test() { return $true }
    [c] Get() { return $this }
}

Describe Get-PropertyCustomAttribute {
    $p = [c] | Get-MemberProperty 'a'
    It 'returns one object' {
        $r = $p | Get-PropertyCustomAttribute 'DscProperty'
        $r.Count | Should be 1
    }
    It 'returns attribute object' {
        $r = $p | Get-PropertyCustomAttribute 'DscProperty'
        $r | Should beOfType ([System.Reflection.CustomAttributeData])
    }
    It 'returns nothing for non-existent attribute' {
        $r = $p | Get-PropertyCustomAttribute 'non-existent'
        $r | Should beNullOrEmpty
    }
}

Describe Assert-PropertyCustomAttribute {
    $p = [c] | Get-MemberProperty 'a'
    Context 'present' {
        Mock Test-PropertyCustomAttribute { $true } -Verifiable
        It 'returns nothing' {
            $r = $p | Assert-PropertyCustomAttribute 'b'
            $r | Should beNullOrEmpty
        }
        It '-Not throws' {
            { $p | Assert-PropertyCustomAttribute -Not 'b' } |
                Should throw 'exists'
        }
        It 'invokes commands' {
            Assert-MockCalled Test-PropertyCustomAttribute 2 {
                $PropertyInfo.Name -eq 'a' -and
                $AttributeName -eq 'b'
            }
        }
    }
    Context 'absent' {
        Mock Test-PropertyCustomAttribute { $false }
        It 'throws' {
            { $p | Assert-PropertyCustomAttribute 'b' } |
                Should throw 'not exist'
        }
        It '-Not returns nothing' {
            $r = $p | Assert-PropertyCustomAttribute -Not 'b'
            $r | Should beNullOrEmpty
        }
    }
}

Describe Test-DscPropertyRequired {
    $p = [c] | Get-MemberProperty 'a'
    Context 'success' {
        Mock Test-CustomAttributeArgument { $ArgumentName -eq 'Mandatory' } -Verifiable
        It 'true' {
            $r = $p | Test-DscPropertyRequired
            $r | Should be $true
        }
        It 'invokes commands' {
            Assert-MockCalled Test-CustomAttributeArgument 1 {
                $ArgumentName -eq 'Key' -and
                $Value -eq $true
            }
            Assert-MockCalled Test-CustomAttributeArgument 1 {
                $ArgumentName -eq 'Mandatory' -and
                $Value -eq $true
            }
        }
    }
    Context 'failure' {
        Mock Test-CustomAttributeArgument { $false }
        It 'false' {
            $r = $p | Test-DscPropertyRequired
            $r | Should be $false
        }
    }
}

Describe Get-PropertyType {
    class c { [string]$a }
    It 'returns type info' {
        $r = [c] |
            Get-MemberProperty |
            Get-PropertyType
        $r.Count | Should be 1
        $r.Name | Should be 'string'
        $r | Should beOfType ([System.Reflection.TypeInfo])
    }
}

Describe Get-PropertyDefault {
    class c { $a = 'default'; $b }
    It 'returns value' {
        $r = [c] |
            Get-PropertyDefault 'a'
        $r | Should be 'default'
    }
    It 'returns null' {
        $r = [c] |
            Get-PropertyDefault 'b'
        $null -eq $r | Should be $true
    }
}
}
