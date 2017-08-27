Import-Module StructuredDscResourceCheck -Force

InModuleScope StructuredDscResourceCheck {

Describe Get-ParameterMetaData {
    function f { param($x) }
    It 'returns one parameter info object' {
        $r = Get-Command f | Get-ParameterMetaData 'x'
        $r.Count | Should be 1
        $r.Name | Should be 'x'
        $r | Should beOfType ([System.Management.Automation.ParameterMetadata])
    }
    It 'returns nothing for non-existent parameter' {
        $r = Get-Command f | Get-ParameterMetaData 'y'
        $r | Should beNullOrEmpty
    }
}

Describe Get-ParameterAst {
    function f { param($x) }
    It 'returns parameter abstract syntax tree' {
        $r = Get-Command f | Get-ParameterAst 'x'
        $r.Count | Should be 1
        $r.Name | Should be '$x'
        $r | Should beOfType ([System.Management.Automation.Language.ParameterAst])
    }
    It 'returns nothing for non-existent parameter' {
        $r = Get-Command f | Get-ParameterAst 'y'
        $r | Should beNullOrEmpty
    }
}

Describe Test-Parameter {
    function f { param($x) }
    It 'true' {
        $r = Get-Command f | Test-Parameter 'x'
        $r | Should be $true
    }
    It 'false' {
        $r = Get-Command f | Test-Parameter 'y'
        $r | Should be $false
    }
}

Describe Assert-Parameter {
    function f { param($x) }
    Context 'success' {
        Mock Test-Parameter { $true } -Verifiable
        It 'returns nothing' {
            $r = Get-Command f | Assert-Parameter 'x'
            $r | Should beNullOrEmpty
        }
        It 'invokes commands' {
            Assert-MockCalled Test-Parameter 1 {
                $ParameterName -eq 'x' -and
                $FunctionInfo.Name -eq 'f'
            }
        }
    }
    Context 'failure' {
        Mock Test-Parameter
        It 'throws' {
            { Get-Command f | Assert-Parameter 'y' } |
                Should throw 'does not have parameter'
        }
    }
}

Describe Test-FunctionParameterMandatory {
    function f { 
        param(
            $a,

            [Parameter(Mandatory = $true)]
            $b
    )}
    It 'returns false for non-mandatory' {
        $r = Get-Command f |
            Get-ParameterMetaData 'a' |
            Test-FunctionParameterMandatory
        $r | Should be $false
    }
    It 'returns true for mandatory' {
        $r = Get-Command f |
            Get-ParameterMetaData 'b' |
            Test-FunctionParameterMandatory
        $r | Should be $true
    }
}

Describe Assert-FunctionParameterMandatory {
    function f {param($x)}
    $p = Get-Command f | Get-ParameterMetaData 'x'
    Context 'success' {
        Mock Test-FunctionParameterMandatory { $true } -Verifiable
        It 'returns nothing' {
            $r = $p | Assert-FunctionParameterMandatory
            $r | Should beNullOrEmpty
        }
        It 'invokes command' {
            Assert-MockCalled Test-FunctionParameterMandatory 1 {
                $ParameterInfo.Name -eq 'x'
            }
        }
    }
    Context 'failure' {
        Mock Test-FunctionParameterMandatory
        It 'throws' {
            { $p | Assert-FunctionParameterMandatory } |
                Should throw 'not mandatory'
        }
    }
}

Describe Get-FunctionParameterType {
    function f { param([Int32]$x) }
    It 'returns exactly one type info object' {
        $r = Get-Command f | Get-ParameterMetaData 'x' | 
            Get-FunctionParameterType
        $r.Count | Should be 1
        $r | Should beOfType ([System.Reflection.TypeInfo])
        $r.Name | Should be 'Int32'
    }
}

Describe Test-FunctionParameterType {
    function f { param([Int32]$x) }
    $p = Get-Command f | Get-ParameterMetaData 'x'
    It 'true' {
        $r = $p | Test-FunctionParameterType ([Int32])
        $r | Should be $true
    }
    It 'false' {
        $r = $p | Test-FunctionParameterType ([string])
        $r | Should be $false
    }    
}

Describe Assert-FunctionParameterType {
    function f { param([Int32]$x) }
    $p = Get-Command f | Get-ParameterMetaData 'x'
    Context 'success' {
        Mock Test-FunctionParameterType { $true } -Verifiable
        It 'returns nothing' {
            $r = $p | Assert-FunctionParameterType ([int32])
            $r | Should beNullOrEmpty
        }
        It 'invokes commands' {
            Assert-MockCalled Test-FunctionParameterType 1 {
                $ParameterInfo.Name -eq 'x' -and
                $Type.Name -eq 'Int32'
            }
        }
    }
    Context 'failure' {
        Mock Test-FunctionParameterType
        It 'throws' {
            { $p | Assert-FunctionParameterType ([int32]) } |
                Should throw 'not of type'
        }
    }
}
}