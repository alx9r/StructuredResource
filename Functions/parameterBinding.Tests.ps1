Import-Module StructuredResource -Force

InModuleScope StructuredResource {
Describe Assert-NamedArgument {
    function f { param([hashtable]$x) }
    $p = Get-Command f | Get-ParameterMetaData
    It 'returns nothing' {
        $r = $p | Assert-NamedArgument @{ x = @{} }
        $r | Should -BeNullOrEmpty
    }
    Context 'throws when argument' {
        It 'is absent' {
            { $p | Assert-NamedArgument @{} } |
                Should -Throw 'not found'
        }
        It 'doesn''t convert' {
            { $p | Assert-NamedArgument @{ x = 1 } } |
                Should -Throw 'could not be converted'
        }
        It 'is null' {
            { $p | Assert-NamedArgument @{ x=$null} } |
                Should -Throw 'is null'
        }
    }
}

Describe Assert-ConstructorArgument {
    function f {
        param(
            [StructuredResource('ConstructorProperty')]$x,
            [StructuredResource('ConstructorProperty')]$y,
            $z
        )
    }
    $p = Get-Command f | Get-ParameterMetaData
    It 'returns nothing' {
        $r = $p | Assert-ConstructorArgument @{x=1;y=2}
        $r | Should -BeNullOrEmpty
    }
    Context 'constructor property argument' {
        It 'throws when absent' {
            { $p | Assert-ConstructorArgument @{x=1} } |
                Should -Throw 'Problem with argument'
        }
    }
}
}
