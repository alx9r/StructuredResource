Import-Module StructuredResource -Force

InModuleScope StructuredResource {

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

Describe Get-DscResourceAttribute {
    Mock Get-NestedModule { New-Module m {} } -Verifiable
    Mock Get-TypeFromModule {
        [DscResource()]
        class f0743ed1
        {
            [DscProperty(Key)]
            [string]
            $Key

            [void] Set() {}
            [bool] Test() {return $true}
            [f0743ed1] Get() { return $this }
        }
        return [f0743ed1]
    } -Verifiable
    It 'returns [DscResource()] attributes' {
        $r = Get-DscResourceAttribute 'ResourceName' 'ModuleName'
        $r.Count | Should be 1
        $r.AttributeType.Name | Should be 'DscResourceAttribute'
    }
    It 'invokes commands' {
        Assert-MockCalled Get-NestedModule 1 {
            $NestedName -eq 'ResourceName' -and
            $Name -eq 'ModuleName'
        }
        Assert-MockCalled Get-TypeFromModule 1 {
            $Name -eq 'ResourceName' -and
            $ModuleInfo
        }
    }
}

Describe Assert-DscResourceAttribute {
    Mock Get-DscResourceAttribute
    Context 'success' {
        Mock Get-DscResourceAttribute { 'attribute' } -Verifiable
        It 'returns nothing' {
            $r = Assert-DscResourceAttribute 'ResourceName' 'ModuleName'
            $r | Should beNullOrEmpty
        }
        It 'invokes commands' {
            Assert-MockCalled Get-DscResourceAttribute 1 {
                $ResourceName -eq 'ResourceName' -and
                $ModuleName -eq 'ModuleName'
            }
        }
    }
    Context 'Get-DscResourceAttribute returns nothing' {
        It 'throws' {
            {Assert-DscResourceAttribute 'ResourceName' 'ModuleName'} |
                Should throw 'not found'
        }
    }
}

}