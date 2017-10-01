Import-Module StructuredResource -Force

InModuleScope StructuredResource {

Describe Get-TestIdKind {
    It '<s> is <k>' -TestCases @(
        @{s='T001';k='Test'},
        @{s='C.1'; k='Guideline'}
    ) {
        param($s,$k)

        $r = $s | Get-TestIdKind
        $r | Should -BeOfType ([TestIdKind])
        $r | Should -Be $k
    }
    It 'null for unknown' {
        $r = 'unknown' | Get-TestIdKind
        $r | Should -BeNullOrEmpty
    }
}
Describe Get-TestIdNumber {
    It '<s> is <n>' -TestCases @(
        @{s='C.1';  n=1 }
        @{s='T001'; n=1 }
        @{s='T';    n=0 }
    ) {
        param($s,$n)
        $r = $s | Get-TestIdNumber
        $r | Should -BeOfType ([int])
        $r | Should -Be $n
    }
}
Describe Get-GuidelineGroup {
    It '<s> is <g>' -TestCases @(
        @{s='C.1';  g='C'}
        @{s='PR.1'; g='PR' }
    ) {
        param($s,$g)
        $r = $s | Get-GuidelineGroup
        $r | Should -Be $g
    }
    It 'empty for <n>' -TestCases @(
        @{s='T001'; n='T001'}
        @{s=$null;  n='null'}
        @{s='';     n='empty string' }
    ) {
        param($s,$n)
        $r = $s | Get-GuidelineGroup
        $r | Should -BeNullOrEmpty
    }
}
}
