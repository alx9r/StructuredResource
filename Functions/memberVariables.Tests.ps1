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

Describe Assert-PropertyType {
    class c { [string]$a }
    It 'returns nothing' {
        $r = [c] |
            Get-MemberProperty |
            Assert-PropertyType ([string])
        $r | Should beNullOrEmpty
    }
    It 'throws' {
        { [c] |
            Get-MemberProperty |
            Assert-PropertyType ([int])
        } |
            Should throw 'not of type'
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