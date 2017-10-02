Import-Module StructuredResource -Force

InModuleScope StructuredResource {

Describe ConvertTo-GuidelinesDocument {
    $r = 'A.3','A.2','T001','B.1','C.1','A.1' |
        % { [StructuredResourceTest]@{ ID=$_; Message = 'message' } } |
        ConvertTo-GuidelinesDocument 'Title' 'Text' @{
            A = 'aye'
            B = 'bee'
            C = 'see'
        }
    It 'outputs a section object' {
        $r | Should -BeOfType ([Section])
    }
    It 'populates title' {
        $r.Title | Should -Be 'Title'
    }
    It 'populates text' {
        $r.Text.Text | Should -Be 'Text'
    }
    Context 'groups' {
        It 'grouped and sorted' {
            $r.Sections.Count | Should -Be 3
            $r.Sections[0].Title | Should -Be 'A: Aye'
            $r.Sections[1].Title | Should -Be 'B: Bee'
            $r.Sections[2].Title | Should -Be 'C: See'
        }
    }
    Context 'guidelines' {
        It 'grouped and sorted' {
            $r.Sections[0].Sections.Count | Should be 3

            $r.Sections[0].Sections[0].Title | Should be 'A.1 message'
            $r.Sections[0].Sections[1].Title | Should be 'A.2 message'
            $r.Sections[0].Sections[2].Title | Should be 'A.3 message'

            $r.Sections[1].Sections[0].Title | Should be 'B.1 message'

            $r.Sections[2].Sections[0].Title | Should be 'C.1 message'
        }
    }
}

Describe ConvertTo-GuidelinesSection {
    $r = [StructuredResourceTest]@{
        ID = 'A.1'
        Message = 'message'
        Explanation = 'explanation'
    } | ConvertTo-GuidelinesSection
    It 'outputs a section object' {
        $r | Should -BeOfType ([Section])
    }
    It 'populates title' {
        $r.Title | Should -Be 'A.1 message'
    }
    It 'populates text' {
        $r.Text.Text | Should -Be 'explanation'
    }
}
}
