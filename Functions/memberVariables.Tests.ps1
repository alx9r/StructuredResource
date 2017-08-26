Import-Module StructuredDscResourceCheck -Force

InModuleScope StructuredDscResourceCheck {

Describe Get-MemberProperties {
    class c { $a;$b }
    It 'returns type properties' {
        $r = [c] | Get-MemberProperties
        $r.Count | Should be 2
        $r | ? {$_.Name -eq 'a' } | Should not beNullOrEmpty
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
            Get-MemberProperties |
            ? {$_.Name -eq 'a' }

        $r = $i | Test-DscProperty

        $r.Count | Should be 1
        $r | Should be $true
    }
    It 'returns false' {
        $i = [c] |
            Get-MemberProperties |
            ? {$_.Name -eq 'b' }

        $r = $i | Test-DscProperty

        $r.Count | Should be 1
        $r | Should be $false
    }
}

Describe Assert-DscProperties {
    It 'returns nothing' {
        $r = [c] | Assert-DscProperties
        $r | Should beNullOrEmpty
    }
    It 'throws' {
        class d {$a;$b}
        { [d] | Assert-DscProperties } |
            Should throw 'not found'
    }
}
}