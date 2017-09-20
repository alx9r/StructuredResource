Import-Module StructuredResource -Force

InModuleScope StructuredResource {

Describe New-StructuredResourceTest {
    Mock Get-OrderedTests { 'return value' } -Verifiable
    It 'returns object' {
        $r = New-StructuredResourceTest 'resource_name' 'module_name' @{ arg = 'arg' }

        $r | Should be 'return value'
    }
    It 'invokes commands' {
        Assert-MockCalled Get-OrderedTests 1 {
            $TestParams.ResourceName -eq 'resource_name'
        }
    }
}
}