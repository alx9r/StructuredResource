Import-Module StructuredDscResourceCheck -Force

InModuleScope StructuredDscResourceCheck {

Describe New-PresenceTest {
    $testCases = @{Presence='Corrigible'} | 
        New-PresenceTest (Get-Command Invoke-ProcessTestStub2) |
        % { @{ o = $_; m = $_.Message } }
    It '<m>' -TestCases $testCases {
        param($o,$m)
        $o | Invoke-Scriptblock
    }
}
}