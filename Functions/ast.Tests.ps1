Import-Module StructuredResource -Force

InModuleScope StructuredResource {

Describe Get-ModuleAst {
    foreach ( $values in @(
        @('Dynamic Module',(New-Module m { 'contents' })),
        @('Stub Module',(Get-NestedModule TestStub1 StructuredResource))
    ))
    {
        $testName,$module = $values
        Context $testName {
            $r = $module | 
                Get-ModuleAst
            It 'returns one object' {
                $r | measure | % Count | Should be 1
            }
            It 'returns AST' {
                $r | Should -BeOfType ([System.Management.Automation.Language.Ast])
            }
            It 'seems to have contents' {
                $r | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Describe Get-StatementAst {
    $a = {
        function f {}
        class c1 {}
        class c2 {}
    }.Ast.EndBlock

    Context 'no params' {
        $r = $a | Get-StatementAst
        It 'returns all' {
            $r | measure | % Count | Should -Be 3
        }
        It 'all objects are statement ASTs' {
            $r | Should -BeOfType ([System.Management.Automation.Language.StatementAst])
        }
    }
    Context '-ClassOnly' {
        $r = $a | Get-StatementAst -ClassOnly
        It 'returns two objects' {
            $r | measure | % Count | Should -Be 2
        }
        It 'the objects are for classes' {
            $r.IsClass | Should -Be $true,$true
        }
    }
    Context '-Filter' {
        $r = $a | Get-StatementAst c*
        It 'returns two objects' {
            $r | measure | % Count | Should -Be 2
        }
        It 'the objects have correct names' {
            $r.Name | Should -Be 'c1','c2'
        }
    }
}

Describe Get-FunctionMemberAst {
    $s = {
        class c {
            [void] m1 () {}
            [void] m2 () {}
            [void] x () {}
        }
    }.Ast.Endblock |
        Get-StatementAst c

    Context 'no params' {
        $r = $s | Get-FunctionMemberAst
        It 'returns all' {
            $r | measure | % Count | Should -Be 3
        }
        It 'the objects are function member ASTs' {
            $r | Should -BeOfType ([System.Management.Automation.Language.FunctionMemberAst])
        }
    }
    Context '-Filter' {
        $r = $s | Get-FunctionMemberAst m*
        It 'returns two objects' {
            $r | measure | % Count | Should -Be 2
        }
        It 'the objects have correct names' {
            $r.Name | Should -Be 'm1','m2'
        }
    }
}
}