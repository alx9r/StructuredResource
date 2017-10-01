Import-Module StructuredResource -Force
& (Get-Module StructuredResource) {
    . "$PSScriptRoot\helpers.ps1"

    Describe guidelines.md {
        $guidelines = @{}
        It 'get new' {
            $guidelines.new = New-GuidelinesMd
            $guidelines.new | Should -Not -BeNullOrEmpty
        }
        It 'get existing' {
            $guidelines.existing = Get-Content "$PSScriptRoot\guidelines.md"
        }
        It 'same number of lines' {
            $guidelines.existing.Count | Should -Be $guidelines.new.Count
        }
        It 'lines match' {
            $i=0
            foreach($line in $guidelines.new)
            {
                $i++
                $guidelines.new[$i] | Should -Be $guidelines.existing[$i]
            }
        }
    }
}