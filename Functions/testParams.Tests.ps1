Import-Module StructuredDscResourceCheck -Force

InModuleScope StructuredDscResourceCheck {

Describe New-TestParams {
    Context 'mock' {
        Mock New-Object { 'object' } -Verifiable
        It 'returns object' {
            $r = New-TestParams 'resource_name' 'module_name'

            $r | Should be 'object'
        }
        It 'invokes commands' {
            Assert-MockCalled New-Object 1 {
                $TypeName -eq 'TestParams' -and
                $Property.ModuleName -eq 'module_name' -and
                $Property.ResourceName -eq 'resource_name'
            }
        }
    }
    Context 'real' {
        It 'populates fields' {
            $r = New-TestParams 'resource_name' 'module_name'

            $r.ResourceName | Should be 'resource_name'
            $r.ModuleName | Should be 'module_name'
        }
    }
}

}