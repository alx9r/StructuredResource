Import-Module StructuredResource -Force

InModuleScope StructuredResource {

Describe Get-TypeFromModule {
    $moduleInfo = [psmoduleinfo]::new({class a67a9d14 {}})
    Mock Import-Module -Verifiable { $moduleInfo }
    Mock Remove-Module -Verifiable
    Context success {
        It 'returns type info' {
            $r = $moduleInfo | Get-TypeFromModule 'a67a9d14'
            $r.Name | Should be 'a67a9d14'
            $r | Should beOfType ([System.Reflection.TypeInfo])
        }
        It 'invokes commands' {
            Assert-MockCalled Import-Module 1 {
                $PassThru -and $ModuleInfo
            }
            Assert-MockCalled Remove-Module 1 { $moduleInfo }
        }
    }
}

Describe New-ObjectFromModule{
    $moduleInfo = [psmoduleinfo]::new({class a7f58a92 {}})
    Mock Import-Module -Verifiable { $moduleInfo }
    Mock Remove-Module -Verifiable
    Context success {
        It 'returns type info' {
            $r = $moduleInfo | New-ObjectFromModule 'a7f58a92'
            $r.GetType().Name | Should be 'a7f58a92'
        }
        It 'invokes commands' {
            Assert-MockCalled Import-Module 1 {
                $PassThru -and $ModuleInfo
            }
            Assert-MockCalled Remove-Module 1 { $moduleInfo }
        }
    }
}
}
