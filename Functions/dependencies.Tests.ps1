Import-Module StructuredResource -Force

InModuleScope StructuredResource {

$dependencies = @{
    1 = @{ Prerequisites = 2,4 }
    2 = @{ Prerequisites = 3 }
    3 = @{ Prerequisites = 4 }
}
Describe ConvertTo-PrerequisitesGraph {
    It 'returns simplified hashtable' {
        $r = ConvertTo-PrerequisitesGraph $dependencies

        $r.Keys.Count | Should be 3
        $r.get_Item(1) | Should be 2,4
        $r.get_Item(2) | Should be 3
        $r.get_Item(3) | Should be 4
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
            $Dependencies.Name -eq 'input'
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
}
