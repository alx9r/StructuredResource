Import-Module StructuredDscResourceCheck -Force

Describe 'Public API: New-TestInstructions' {
    It 'create instructions' {
        New-TestInstructions TestStub2 StructuredDscResourceCheck
    }
}

Describe 'Public API: Invoke-TestStep' {
    It 'invoke' {
        $i = New-TestInstructions TestStub2 StructuredDscResourceCheck @{
            Presence = 'Corrigible'
        }
        $i | Invoke-TestStep
    }
}