Import-Module StructuredDscResourceCheck -Force

InModuleScope StructuredDscResourceCheck {

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

Describe Get-SortedTestIds {
    Mock ConvertTo-DependencyGraph {@{Name='dependency graph'}}  -Verifiable
    Mock Invoke-SortGraph { 'sorted graph' } -Verifiable
    It 'returns results of Invoke-SortGraph' {
        $r = Get-SortedTestIds @{name = 'input'}
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
}
