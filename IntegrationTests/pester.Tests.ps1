Import-Module StructuredResource -Force

Describe "Public API: Pester Integration" {
    $h = @{}

    It 'create instructions' {
        $h.i = New-StructuredResourceTest TestStub2 StructuredResource @{
            Presence = 'Corrigible'
            Corrigible = 'value'
            Incorrigible = ''
        }
    }
    foreach ( $step in $h.i )
    {
        It $step.Message {
            $step | Invoke-StructuredResourceTest
        }
    }
}