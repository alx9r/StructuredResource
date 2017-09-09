Import-Module StructuredResource -Force

InModuleScope StructuredResource {

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
    Context 'exception' {
        It 'rethrows on pipeline exception' {
            function g { 
                param( [Parameter(ValueFromPipeline = $true)]$a )
                process { throw 'exception in g' }
            }

            { Get-NestedModule 'nestedA' 'ModuleName' | g } |
                Should throw 'NestedName,Name'
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

Describe Get-PublicResourceFunctionCommandName {
    It 'returns correct name' {
        $r = Get-PublicResourceFunctionCommandName 'ResourceName'
        $r | Should be 'Invoke-ResourceName'
    }
}

Describe Get-PublicResourceFunction {
    Mock Get-PublicResourceFunctionCommandName { 'CommandName' } -Verifiable
    Mock Get-Command { 'command' } -Verifiable
    It 'returns command' {
        $r = Get-PublicResourceFunction 'ResourceName' 'ModuleName'
        $r | Should be 'command'
    }
    It 'invokes command' {
        Assert-MockCalled Get-PublicResourceFunctionCommandName 1 {
            $ResourceName -eq 'ResourceName'
        }
        Assert-MockCalled Get-Command 1 {
            $Name -eq 'commandName' -and
            $Module -eq 'ModuleName'
        }
    }
    It 'rethrows on pipeline exception' {
        function g { 
            param( [Parameter(ValueFromPipeline = $true)]$a )
            process { throw 'exception in g' }
        }

        { Get-PublicResourceFunction 'ResourceName' 'ModuleName' | g } |
            Should throw 'ResourceName,ModuleName'
    }
}

Describe Assert-PublicResourceFunction {
    Mock Get-PublicResourceFunction
    Context 'success' {
        Mock Get-PublicResourceFunction { 'function' } -Verifiable
        It 'returns nothing' {
            $r = Assert-PublicResourceFunction 'ResourceName' 'ModuleName'
            $r | Should beNullOrEmpty
        }
        It 'invokes command' {
            Assert-MockCalled Get-PublicResourceFunction 1 {
                $ResourceName -eq 'ResourceName' -and
                $ModuleName -eq 'ModuleName'
            }
        }
    }
    Context 'Get-PublicResourceFunction returns nothing' {
        It 'throws' {
            { Assert-PublicResourceFunction 'ResourceName' 'ModuleName' } |
                Should throw 'not found'
        }
    }
}
}
