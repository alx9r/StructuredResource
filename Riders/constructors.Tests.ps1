Describe classes {
    class c {}
    It 'empty PowerShell class has a constructor' {
        [c].GetConstructors() |
            Should -Not -BeNullOrEmpty
    }
}