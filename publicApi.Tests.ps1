Import-Module StructuredDscResourceCheck -Force

Describe 'Public API' {
    $r = Get-Command -Module StructuredDscResourceCheck
    It 'exports some functions...' {
        $r | measure | % Count | Should beGreaterThan 1
    }
    It '...but not too many' {
        $r | measure | % Count | Should beLessThan 10
    }
}