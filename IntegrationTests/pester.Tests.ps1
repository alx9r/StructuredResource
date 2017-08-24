Import-Module StructuredDscResourceCheck -Force

Describe "Public API: Pester Integration" {
    $h = @{}

    It 'create instructions' {
        $h.i = New-TestInstructions TestResource1 StructuredDscResourceCheck
    }
    foreach ( $step in $h.i )
    {
        It $step.Message {
            $step | Invoke-TestStep
        }
    }
}