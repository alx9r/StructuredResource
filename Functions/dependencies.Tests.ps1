Import-Module StructuredResource -Force

InModuleScope StructuredResource {

$prerequisites = @{
    1 = @{ Prerequisites = 2,4 }
    2 = @{ Prerequisites = 3 }
    3 = @{ Prerequisites = 4 }
}
Describe ConvertTo-PrerequisitesGraph {
    It 'returns simplified hashtable' {
        $r = ConvertTo-PrerequisitesGraph $prerequisites

        $r.Keys.Count | Should be 3
        $r.get_Item(1) | Should be 2,4
        $r.get_Item(2) | Should be 3
        $r.get_Item(3) | Should be 4
    }
}

Describe ConvertTo-DependentsGraph {
    It 'returns simplified hashtable' {
        $r = ConvertTo-DependentsGraph $prerequisites

        $r.Keys.Count | Should be 3
        $r.get_Item(2) | Should be 1
        $r.get_Item(3) | Should be 2
        $r.get_Item(4) | Should be 3,1
    }
}

Describe Get-OrderedTestIds {
    Mock ConvertTo-PrerequisitesGraph {@{Name='dependency graph'}}  -Verifiable
    Mock Invoke-SortGraph { 'sorted graph' } -Verifiable
    It 'returns results of Invoke-SortGraph' {
        $r = Get-OrderedTestIds @{name = 'input'}
        $r | Should be 'sorted graph'
    }
    It 'invokes commands' {
        Assert-MockCalled ConvertTo-PrerequisitesGraph 1 {
            $Prerequisites.Name -eq 'input'
        }
        Assert-MockCalled Invoke-SortGraph 1 {
            $Edges.Name -eq 'dependency graph'
        }
    }
}

Describe Get-OrderedTests {
    $t = @{
        1 = @{ Message = 'm1' }
        2 = @{ Message = 'm2' }
    }
    $a = New-Object TestArgs -Property @{
        ModuleName = 'module_name'
        ResourceName = 'resource_name'
        Arguments = @{ arg = 'uments' }
    }
    Mock Get-OrderedTestIds { 2,1 } -Verifiable
    Mock Get-DependentGuideline { 'D' } -Verifiable
    It 'returns ordered list of tests' {
        $r = Get-OrderedTests -Tests $t -TestArgs $a

        $r.Count | Should be 2
        $r[0].ID | Should be 2
        $r[0].Message | Should be 'm2'
        $r[0].Arguments.Arguments.arg | Should be 'uments'
        $r[1].ID | Should be 1
        $r[1].Message | Should be 'm1'
        $r[1].Arguments.Arguments.arg | Should be 'uments'
    }
    It 'invokes commands' {
        Assert-MockCalled Get-OrderedTestIds 1 {
            $Dependencies.get_Item(1).Message -eq 'm1'
        }
    }
}

Describe Get-DependentGuideline {
    $t = @{
        'A' = @{ Prerequisites = '1' }
        'B' = @{ Prerequisites = '1' }
        '1' = @{ Prerequisites = '2' }
    }
    Mock Test-TestIdKind { $Id -match '[A-Z]' }
    It 'returns guideline ID' {
        $r = Get-DependentGuideline 2 -Tests $t

        $r.Count | Should -Be 2
        'A' | Should -BeIn $r
        'B' | Should -BeIn $r
    }
    It 'invokes commands' {
        Assert-MockCalled Test-TestIdKind 1 {
            $Value -eq 'Guideline'
        }
    }
}
}
