Import-Module StructuredDscResourceCheck -Force

InModuleScope StructuredDscResourceCheck {

Describe Assert-ModuleExists {
    Mock Get-Module -Verifiable
    Context 'success' {
        Mock Get-Module -MockWith {'ModuleInfo'}
        It 'returns nothing' {
            $r = Assert-ModuleExists 'ModuleName'
            $r | Should beNullOrEmpty
        }
        It 'invokes commands' {
            Assert-MockCalled Get-Module 1 {
                $ListAvailable -and
                $Name -eq 'ModuleName'
            }
        }
    }
    Context 'Get-Module returns nothing' {
        It 'throws' {
            { Assert-ModuleExists 'ModuleName' } |
                Should throw 'not found'
        }
    }
}

Describe Assert-ModuleImported {
    Mock Get-Module -Verifiable
    Context 'success' {
        Mock Get-Module -MockWith {'ModuleInfo'}
        It 'returns nothing' {
            $r = Assert-ModuleImported 'ModuleName'
            $r  | Should beNullOrEmpty
        }
        It 'invokes commands' {
            Assert-MockCalled Get-Module 1 {
                -not $ListAvailable -and
                $Name -eq 'ModuleName'
            }
        }
    }
    Context 'Get-Module returns nothing' {
        It 'throws' {
            { Assert-ModuleImported 'ModuleName' } |
                Should throw 'not imported'
        }
    }
}

Describe Get-NestedModule {
    Mock Get-Module -Verifiable {
        New-Object psobject -Property @{
            NestedModules = 'nestedA','nestedB' |
                % { New-Object psobject -Property @{ Name = $_ } }
        }
    }
    Context 'success' {
        It 'returns selected nested module' {
            $r = Get-NestedModule 'nestedA' 'ModuleName'
            $r | measure | % Count | Should be 1
            $r.Name | Should be 'nestedA'
        }
        It 'invokes commands' {
            Assert-MockCalled Get-Module 1 {
                $ListAvailable -and
                $Name -eq 'ModuleName'
            }
        }
    }
    Context 'success, omit optional' {
        It 'returns all nested modules' {
            $r = Get-NestedModule -ParentName 'ModuleName'
            $r.Count | Should be 2
            $r[0].Name | Should be 'nestedA'
            $r[1].Name | Should be 'nestedB'
        }
    }
}

Describe Assert-NestedModule {
    Mock Get-NestedModule -Verifiable
    Context 'success' {
        Mock Get-NestedModule -Verifiable { 'ModuleInfo' }
        It 'returns nothing' {
            $r = Assert-NestedModule 'NestedName' 'Name' 
            $r | Should beNullOrEmpty
        }
        It 'invokes commands' {
            Assert-MockCalled Get-NestedModule 1 {
                $Name -eq 'Name' -and
                $NestedName -eq 'NestedName'
            }
        }
    }
    Context 'Get-NestedModule returns nothing' {
        It 'throws' {
            { Assert-NestedModule 'Name' 'NestedName' } |
                Should throw 'not found'
        }
    }
}

Describe Get-NestedModuleType {
    Mock Get-NestedModule -Verifiable { New-Module e9ddad25 {} }
    Mock Get-TypeFromModule -Verifiable { 'TypeInfo' }
    Context 'success' {
        It 'returns type info' {
            $r = Get-NestedModuleType 'NestedName' 'ModuleName'
            $r | Should be 'TypeInfo'
        }
        It 'invokes commands' {
            Assert-MockCalled Get-NestedModule 1 {
                $NestedName -eq 'NestedName' -and
                $Name -eq 'ModuleName'
            }
            Assert-MockCalled Get-TypeFromModule 1 {
                $ModuleInfo.Name -eq 'e9ddad25' -and
                $Name -eq 'NestedName'
            }
        }
    }
}

Describe Assert-NestedModuleType {
    Mock Get-NestedModuleType -Verifiable
    Context 'success' {
        Mock Get-NestedModuleType { 'TypeInfo' } -Verifiable
        It 'returns nothing' {
            $r = Assert-NestedModuleType 'NestedName' 'Name'
            $r | Should beNullOrEmpty
        }
        It 'invokes commands' {
            Assert-MockCalled Get-NestedModuleType 1 {
                $NestedName -eq 'NestedName' -and
                $Name -eq 'Name'
            }
        }
    }
    Context 'Get-NestedModuleType returns nothing' {
        It 'throws' {
            { Assert-NestedModuleType 'NestedName' 'Name' } |
                Should throw 'not found'
        }
    }
}

Describe New-NestedModuleInstance {
    Mock Get-NestedModule -Verifiable { New-Module bc23232f {} }
    Mock New-ObjectFromModule -Verifiable { 'new object' }
    Context 'success' {
        It 'returns instance' {
            $r = New-NestedModuleInstance 'NestedName' 'ModuleName'
            $r | Should be 'new object'
        }
        It 'invokes commands' {
            Assert-MockCalled Get-NestedModule 1 {
                $NestedName -eq 'NestedName' -and
                $Name -eq 'ModuleName'
            }
            Assert-MockCalled New-ObjectFromModule 1 {
                $ModuleInfo.Name -eq 'bc23232f' -and
                $Name -eq 'NestedName'
            }
        }
    }
}

Describe Assert-NestedModuleInstance {
    Mock New-NestedModuleInstance -Verifiable
    Context 'success' {
        Mock New-NestedModuleInstance {'instance'} -Verifiable
        It 'returns nothing' {
            $r = Assert-NestedModuleInstance 'NestedName' 'ModuleName'
            $r | Should beNullOrEmpty
        }
        It 'invokes commands' {
            Assert-MockCalled New-NestedModuleInstance 1 {
                $NestedName -eq 'NestedName' -and
                $Name -eq 'ModuleName'
            }
        }
    }
    Context 'New-NestedModuleInstance returns nothing' {
        It 'throws' {
            { Assert-NestedModuleInstance 'NestedName' 'ModuleName' } |
                Should throw 'Could not create object'
        }
    }
}

Describe Assert-DscResource {
    Mock Get-DscResource -Verifiable
    Context 'success' {
        Mock Get-DscResource -MockWith { 'DscResourceInfo' }
        It 'returns nothing' {
            $r = Assert-DscResource 'ResourceName' 'ModuleName'
            $r | Should beNullOrEmpty
        }
        It 'invokes commands' {
            Assert-MockCalled Get-DscResource 1 {
                $Name -eq 'ResourceName' -and
                $Module -eq 'ModuleName'
            }
        }
    }
    Context 'success, omit optional' {
        Mock Get-DscResource -MockWith { 'DscResourceInfo' }
        It 'returns nothing' {
            Assert-DscResource 'ResourceName'
        }
    }
    Context 'Get-DscResource returns nothing' {
        It 'throws' {
            { Assert-DscResource 'ResourceName' 'ModuleName' } |
                Should throw 'not found'
        }
    }
}
}
