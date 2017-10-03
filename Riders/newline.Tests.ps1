Describe newlines {
    It 'newline characters' {
        $r = [System.Environment]::NewLine.GetEnumerator() | % {[int] $_ }
        $r | Should -Be 13,10
    }
}