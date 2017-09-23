Import-Module StructuredResource -Force

InModuleScope StructuredResource {

Describe Get-HashtableKey {
    $h = @{x=1}
    It 'returns key name' {
        $r = $h | Get-HashtableKey x
        $r | Should -Be x
    }
    It 'returns nothing' {
        $r = $h | Get-HashtableKey y
        $r | Should -BeNullOrEmpty
    }
}
}