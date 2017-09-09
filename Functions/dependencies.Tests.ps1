Import-Module StructuredResource -Force

InModuleScope StructuredResource {

$dependencies = @{
    1 = @{ Prerequisites = 2,4 }
    2 = @{ Prerequisites = 3 }
    3 = @{ Prerequisites = 4 }
}
Describe ConvertTo-DependencyGraph {
    It 'returns simplified hashtable' {
        $r = ConvertTo-DependencyGraph $dependencies

        $r.Keys.Count | Should be 3
        $r.get_Item(1) | Should be 2,4
        $r.get_Item(2) | Should be 3
        $r.get_Item(3) | Should be 4
    }
}

Describe Get-OrderedTestIds {
    Mock ConvertTo-DependencyGraph {@{Name='dependency graph'}}  -Verifiable
    Mock Invoke-SortGraph { 'sorted graph' } -Verifiable
    It 'returns results of Invoke-SortGraph' {
        $r = Get-OrderedTestIds @{name = 'input'}
        $r | Should be 'sorted graph'
    }
    It 'invokes commands' {
        Assert-MockCalled ConvertTo-DependencyGraph 1 {
            $Dependencies.Name -eq 'input'
        }
        Assert-MockCalled Invoke-SortGraph 1 {
            $Edges.Name -eq 'dependency graph'
        }
    }
}

Describe Get-OrderedSteps {
    $tests = @{
        1 = @{ Message = 'm1' }
        2 = @{ Message = 'm2' }
    }
    Mock Get-OrderedTestIds { 2,1 } -Verifiable
    It 'returns ordered list of tests' {
        $r = Get-OrderedSteps -Tests $tests

        $r.Count | Should be 2
        $r[0].ID | Should be 2
        $r[0].Message | Should be 'm2'
        $r[1].ID | Should be 1
        $r[1].Message | Should be 'm1'
    }
    It 'invokes commands' {
        Assert-MockCalled Get-OrderedTestIds 1 {
            $Dependencies.get_Item(1).Message -eq 'm1'
        }
    }
}
}
