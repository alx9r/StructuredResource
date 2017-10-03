Describe classes {
    class c {}
    It 'empty PowerShell class has a declared constructor' {
        [c].DeclaredConstructors |
            Should -Not -BeNullOrEmpty
    }
}