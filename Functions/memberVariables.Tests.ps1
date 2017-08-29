Import-Module StructuredDscResourceCheck -Force

InModuleScope StructuredDscResourceCheck {

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
    [DscProperty(Key)]
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

Describe Test-PropertyCustomAttribute {
    $p = [c] | Get-MemberProperty 'a'
    It 'true' {
        $r = $p | Test-PropertyCustomAttribute 'DscProperty'
        $r | Should be $true
    }
    It 'false' {
        $r = $p | Test-PropertyCustomAttribute 'non-existent'
        $r | Should be $false
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

Describe Test-DscProperty {
    It 'returns true' {
        $i = [c] |
            Get-MemberProperty |
            ? {$_.Name -eq 'a' }

        $r = $i | Test-DscProperty

        $r.Count | Should be 1
        $r | Should be $true
    }
    It 'returns false' {
        $i = [c] |
            Get-MemberProperty |
            ? {$_.Name -eq 'b' }

        $r = $i | Test-DscProperty

        $r.Count | Should be 1
        $r | Should be $false
    }
}

Describe Assert-HasDscProperty {
    It 'returns nothing' {
        $r = [c] | Assert-HasDscProperty
        $r | Should beNullOrEmpty
    }
    It 'throws' {
        class d {$a;$b}
        { [d] | Assert-HasDscProperty } |
            Should throw 'not found'
    }
}

Describe Assert-DscProperty {
    It 'returns nothing' {
        $r = [c] | Assert-DscProperty 'a'
        $r | Should beNullOrEmpty
    }
    It 'throws' {
        { [c] | Assert-DscProperty 'b' } |
            Should throw 'not found'
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

Describe Assert-PropertyDefault {
    class c { $a = 'default'; $b }
    Context 'string' {
        It 'returns nothing' {
            $r = [c] | 
                Assert-PropertyDefault 'a' 'default'

            $r | Should beNullOrEmpty
        }
        It 'throws on string mismatch' {
            { [c] | Assert-PropertyDefault 'a' 'other' } |
                Should throw 'does not match'
        }
    }
    Context 'null' {
        It 'returns nothing' {
            $r = [c] | 
                Assert-PropertyDefault 'b' $null

            $r | Should beNullOrEmpty
        }
        It 'throws on string mismatch' {
            { [c] | Assert-PropertyDefault 'b' 'other' } |
                Should throw 'does not match'
        }
    }
    Context 'non-existent property' {
        It 'returns nothing' {
            $r = [c] |
                Assert-PropertyDefault 'bogus' 'default'
            $r | Should beNullOrEmpty
        }
    }
}

Describe Assert-NullDscPropertyDefaults {
    Context 'returns nothing' {
        It 'empty class' {
            class c {}
            $r = [c] | Assert-NullDscPropertyDefaults
            $r | Should beNullOrEmpty
        }
    }
    Context 'does not throw' {
        It 'no DSC properties' {
            class c {$a = 'default'}
            [c] | Assert-NullDscPropertyDefaults
        }
        It 'null default DSC properties' {
            class c { [DscProperty()] $a; [DscProperty()] $b }
            [c] | Assert-NullDscPropertyDefaults
        }
        It 'excluded non-null DSC property' {
            class c { [DscProperty()] $a = 'default' }
            [c] | Assert-NullDscPropertyDefaults -Exclude 'a'
        }
    }
    It 'throws' {
        class c { [DscProperty()] $a = 'default' }
        { [c] | Assert-NullDscPropertyDefaults } |
            Should throw 'does not match'
    }
}
}