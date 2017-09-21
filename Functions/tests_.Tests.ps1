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
}
