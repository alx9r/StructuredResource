Import-Module StructuredResource -Force

InModuleScope StructuredResource {

Describe Assert-Value {
    It 'returns nothing' {
        $r = 'a' | Assert-Value 'a'
        $r | Should beNullOrEmpty
    }
    It 'throws' {
        { 'actual' | Assert-Value 'expected' } |
            Should throw 'Expected'
    }
}
}
