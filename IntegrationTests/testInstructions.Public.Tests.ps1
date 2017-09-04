Import-Module StructuredDscResourceCheck -Force

Describe 'Public API: New-TestInstructions' {
    It 'create instructions' {
        New-TestInstructions TestStub1 StructuredDscResourceCheck
    }
}

Describe 'Public API: Invoke-TestStep' {
    It 'invoke' {
        $i = New-TestInstructions TestStub1 StructuredDscResourceCheck
        $i | Invoke-TestStep
    }
}