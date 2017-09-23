Import-Module StructuredResource -Force

InModuleScope StructuredResource {

Describe Get-HashtableKey {
    $h = @{x=1}
    It 'returns key name' {
        $r = $h | Get-HashtableKey x
        $r | Should -Be x
    }
    It 'returns nothing' {
        $r = $h | Get-HashtableKey y
        $r | Should -BeNullOrEmpty
    }
    It 'exception' {
        Get-Command Get-HashtableKey | 
            Assert-PipelineException x -Pipe $h -Match 'x'
    }
}

Describe Get-HashtableItem {
    $h = @{x=1}
    It 'returns value' {
        $r = $h | Get-HashtableItem x
        $r | Should -Be 1
    }
    It 'returns nothing' {
        $r = $h | Get-HashtableItem y
        $r | Should -BeNullOrEmpty
    }
    It 'exception' {
        Get-Command Get-HashtableItem |
            Assert-PipelineException x -Pipe $h -Match 'x','1'
    }
}
}