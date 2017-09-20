Import-Module StructuredResource -Force

InModuleScope StructuredResource {

Describe New-StructuredResourceTest {
    Context 'basic' {
        Mock Get-OrderedTests { 'return value' } -Verifiable
        It 'returns object' {
            $r = New-StructuredResourceTest 'resource_name' 'module_name' @{ arg = 'arg' }

            $r | Should be 'return value'
        }
        It 'invokes commands' {
            Assert-MockCalled Get-OrderedTests 1 {
                $TestArgs.ResourceName -eq 'resource_name'
            }
        }
    }
    Mock Get-OrderedTests { New-Object StructuredResourceTest }
    Context '-Kind' {
        Mock Test-StructuredResourceTestKind { $true } -Verifiable
        It 'returns object' {
            $r = New-StructuredResourceTest 'resource_name' 'module_name' @{} -Kind 'Unit','Integration'
            $r | Should -BeOfType ([StructuredResourceTest])
        }
        It 'invokes commands' {
            Assert-MockCalled Test-StructuredResourceTestKind 1 {
                $Kind -eq 'Integration'
            }
            Assert-MockCalled Test-StructuredResourceTestKind 1 {
                $Kind -eq 'Unit'
            }
        }
    }
    Context 'omit -Arguments' {
        It 'throws' {
            { New-StructuredResourceTest 'resource_name' 'module_name' -Kind 'Integration' } |
                Should throw 'Arguments must be provided'
        }
    }
}
}