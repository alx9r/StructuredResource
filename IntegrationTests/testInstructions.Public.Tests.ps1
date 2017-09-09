Import-Module StructuredResource -Force

Describe 'Public API: New-StructuredResourceTest' {
    It 'create instructions' {
        New-StructuredResourceTest TestStub2 StructuredResource
    }
}

Describe 'Public API: Invoke-StructuredResourceTest' {
    It 'invoke' {
        $i = New-StructuredResourceTest TestStub2 StructuredResource @{
            Presence = 'Corrigible'
        }
        $i | Invoke-StructuredResourceTest
    }
}