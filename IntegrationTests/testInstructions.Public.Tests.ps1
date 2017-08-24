Import-Module StructuredDscResourceCheck -Force

Describe 'Public API: New-TestInstructions' {
    It 'create instructions' {
        New-TestInstructions TestResource1 StructuredDscResourceCheck
    }
}

Describe 'Public API: Invoke-TestStep' {
    It 'invoke' {
        $i = New-TestInstructions TestResource1 StructuredDscResourceCheck
        $i | Invoke-TestStep
    }
}