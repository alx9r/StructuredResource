Import-Module StructuredDscResourceCheck -Force

Describe 'Public API: New-StructuredResourceTest' {
    It 'create instructions' {
        New-StructuredResourceTest TestStub2 StructuredDscResourceCheck
    }
}

Describe 'Public API: Invoke-StructuredResourceTest' {
    It 'invoke' {
        $i = New-StructuredResourceTest TestStub2 StructuredDscResourceCheck @{
            Presence = 'Corrigible'
        }
        $i | Invoke-StructuredResourceTest
    }
}