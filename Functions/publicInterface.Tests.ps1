Import-Module StructuredResource -Force

InModuleScope StructuredResource {

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
}
