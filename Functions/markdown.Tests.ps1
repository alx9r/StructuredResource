Import-Module StructuredResource -Force

InModuleScope StructuredResource {

Describe ConvertTo-MdSection {
    Context 'leaf' {
        $r = [Section]@{
            Title = 'title'
            Text = 'text'
        } | ConvertTo-MdSection
        It 'outputs correct type' {
            $r | Should -BeOfType ([Text])
        }
        It 'outputs two objects' {
            $r.Count | Should -Be 2
        }
        It 'title' {
            $r[0].Format | Should be 'Title1'
            $r[0].Text | Should be 'title'
        }
        It 'text' {
            $r[1].Format | Should be 'None'
            $r[1].Text | Should be 'text'
        }
    }
    Context 'omit text' {
        It 'outputs nothing' {
            $r = [Section]@{
                Title = 'Title'
            } | ConvertTo-MdSection
            $r.Count | Should be 1
            $r.Text | Should be 'Title'
        }
    }
    Context 'nested' {
        $r = [Section]@{
            Title = 'outer title'
            Text = 'outer text'
            Sections = [Section]@{
                Title = 'inner title'
                Text = 'inner text'
            }
        } | ConvertTo-MdSection
        It 'contents' {
            $r | Should be @(
                [Text]::new('outer title','Title1')
                [Text]::new('outer text', 'None')
                [Text]::new('inner title','Title2')
                [Text]::new('inner text', 'None')
            )
        }
    }
}

Describe ConvertTo-MdText {
    It 'format <f>' -TestCases @(
        @{f='None';   t='text'}
        @{f='Title1'; t='# text' }
        @{f='Title2'; t='## text' }
        @{f='Bold';   t='**text**'}
    ) {
        param($f,$t)
        $r = ConvertTo-MdText text $f
        $r | Should be $t
    }
}
}
