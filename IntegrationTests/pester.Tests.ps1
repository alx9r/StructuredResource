Import-Module StructuredDscResourceCheck -Force

Describe "Public API: Pester Integration" {
    $h = @{}

    It 'create instructions' {
        $h.i = New-TestInstructions TestStub2 StructuredDscResourceCheck @{
            Presence = 'Corrigible'
            Corrigible = 'value'
        }
    }
    foreach ( $step in $h.i )
    {
        It $step.Message {
            $step | Invoke-StructuredResourceTest
        }
    }
}