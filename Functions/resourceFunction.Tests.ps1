Import-Module StructuredDscResourceCheck -Force

InModuleScope StructuredDscResourceCheck {

Describe Get-ParameterMetaData {
    function f { param($x,$y) }
    It 'returns one parameter info object for existent parameter' {
        $r = Get-Command f | Get-ParameterMetaData 'x'
        $r.Count | Should be 1
        $r.Name | Should be 'x'
        $r | Should beOfType ([System.Management.Automation.ParameterMetadata])
    }
    It 'returns nothing for non-existent parameter' {
        $r = Get-Command f | Get-ParameterMetaData 'z'
        $r | Should beNullOrEmpty
    }
    It 'returns all parameters for omitted parameter name' {
        $r = Get-Command f | Get-ParameterMetaData
        $r.Count | Should be 2
    }
}

Describe Get-ParameterAst {
    function f { param($x,$y) }
    It 'returns parameter abstract syntax tree for existent parameter' {
        $r = Get-Command f | Get-ParameterAst 'x'
        $r.Count | Should be 1
        $r.Name | Should be '$x'
        $r | Should beOfType ([System.Management.Automation.Language.ParameterAst])
    }
    It 'returns nothing for non-existent parameter' {
        $r = Get-Command f | Get-ParameterAst 'z'
        $r | Should beNullOrEmpty
    }
    It 'returns all parameters for omitted parameter name' {
        $r = Get-Command f | Get-ParameterAst
        $r.Count | Should be 2
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

Describe Get-ParameterAttribute {
    function f {
        param(
        [Parameter(Position = 1,
                   Mandatory = $true)]
        $a
        )
    }
    $p = Get-Command f | Get-ParameterMetaData 'a'
    It 'returns exactly one object' {
        $r = $p | Get-ParameterAttribute 'Position'
        $r.Count | Should be 1
    }
    It 'returns the attribute selected' {
        $r = $p | Get-ParameterAttribute 'Position'
        $r | Should beOfType ([int])
    }
    It 'returns another attribute selected' {
        $r = $p | Get-ParameterAttribute 'Mandatory'
        $r | Should be $true
    }
}

Describe Test-ParameterAttribute {
    function f {param($a)}
    $p = Get-Command f | Get-ParameterMetaData 'a'    
    Context 'true' {
        Mock Get-ParameterAttribute { 'value' } -Verifiable
        It 'returns true for match' {
            $r = $p | Test-ParameterAttribute Position 'value'
            $r | Should beOfType ([bool])
            $r | Should be $true
        }
        It 'invokes commands' {
            Assert-MockCalled Get-ParameterAttribute 1 {
                $AttributeName -eq 'Position' -and
                $ParameterInfo.Name -eq 'a'
            }
        }
    }
    Context 'false' {
        Mock Get-ParameterAttribute { 'other value' }
        It 'returns false for mismatch' {
            $r = $p | Test-ParameterAttribute Position 'value'
            $r | Should be $false
        }
    }
}

Describe Assert-ParameterAttribute {
    function f {param($a)}
    $p = Get-Command f | Get-ParameterMetaData 'a'
    Context 'success' {
        Mock Test-ParameterAttribute { $true } -Verifiable
        It 'returns nothing' {
            $r = $p | Assert-ParameterAttribute Position 'value'
            $r | Should beNullOrEmpty
        }
        It 'invokes command' {
            Assert-MockCalled Test-ParameterAttribute 1 {
                $ParameterInfo.Name -eq 'a' -and
                $Value -eq 'value' -and
                $AttributeName -eq 'Position'
            }
        }
    }
    Context 'failure' {
        Mock Test-ParameterAttribute
        It 'throws' {
            { $p | Assert-ParameterAttribute Position 'value' } |
                Should throw 'not'
        }
    }
}

Describe Assert-FunctionParameterMandatory {
    function f {param($x)}
    $p = Get-Command f | Get-ParameterMetaData 'x'
    Context 'success' {
        Mock Test-ParameterAttribute { $true } -Verifiable
        It 'returns nothing' {
            $r = $p | Assert-FunctionParameterMandatory
            $r | Should beNullOrEmpty
        }
        It 'invokes command' {
            Assert-MockCalled Test-ParameterAttribute 1 {
                $ParameterInfo.Name -eq 'x' -and 
                $AttributeName -eq 'Mandatory' -and
                $Value -eq $true
            }
        }
    }
    Context 'failure' {
        Mock Test-ParameterAttribute
        It 'throws' {
            { $p | Assert-FunctionParameterMandatory } |
                Should throw 'not mandatory'
        }
    }
}

Describe Assert-FunctionParameterOptional {
    function f {param($x)}
    $p = Get-Command f | Get-ParameterMetaData 'x'
    Context 'success' {
        Mock Test-ParameterAttribute { $true } -Verifiable
        It 'returns nothing' {
            $r = $p | Assert-FunctionParameterOptional
            $r | Should beNullOrEmpty
        }
        It 'invokes command' {
            Assert-MockCalled Test-ParameterAttribute 1 {
                $ParameterInfo.Name -eq 'x' -and
                $Value -eq $false -and
                $AttributeName -eq 'Mandatory'
            }
        }
    }
    Context 'failure' {
        Mock Test-ParameterAttribute { $false }
        It 'throws' {
            { $p | Assert-FunctionParameterOptional } |
                Should throw 'not optional'
        }
    }
}

Describe Get-FunctionParameterType {
    function f { param([Int32]$x,$y) }
    It 'returns exactly one type info object' {
        $r = Get-Command f | Get-ParameterMetaData 'x' | 
            Get-FunctionParameterType
        $r.Count | Should be 1
        $r | Should beOfType ([System.Reflection.TypeInfo])
        $r.Name | Should be 'Int32'
    }
    It 'returns System.Object for a non-statically-typed parameter' {
        $r = Get-Command f | Get-ParameterMetaData 'y' |
            Get-FunctionParameterType
        $r.FullName | Should be 'System.Object'
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
    Context 'match' {
        Mock Test-FunctionParameterType { $true } -Verifiable
        It 'returns nothing' {
            $r = $p | Assert-FunctionParameterType ([int32])
            $r | Should beNullOrEmpty
        }
        It 'invokes command' {
            Assert-MockCalled Test-FunctionParameterType 1 {
                $ParameterInfo.Name -eq 'x' -and
                $Type.Name -eq 'Int32'
            }
        }
        It '-Not throws' {
            { $p | Assert-FunctionParameterType -Not ([int32]) } |
                Should throw 'is of type'
        }
        It 'invokes command' {
            Assert-MockCalled Test-FunctionParameterType 1 {
                $Type.Name -eq 'Int32'
            }
        }
    }
    Context 'not match' {
        Mock Test-FunctionParameterType
        It 'throws' {
            { $p | Assert-FunctionParameterType ([int32]) } |
                Should throw 'not of type'
        }
        It '-Not returns nothing' {
            $r = $p | Assert-FunctionParameterType -Not ([int32])
            $r | Should beNullOrEmpty
        }
    }
}

Describe Assert-ParameterPosition {
    function f { param($x) }
    $p = Get-Command f | Get-ParameterMetaData 'x'
    Context 'success' {
        Mock Test-ParameterAttribute { $true } -Verifiable
        It 'returns nothing' {
            $r = $p | Assert-ParameterPosition 1
            $r | Should beNullOrEmpty
        }
        It 'invokes command' {
            Assert-MockCalled Test-ParameterAttribute 1 {
                $ParameterInfo.Name -eq 'x' -and
                $Value -eq 1 -and
                $AttributeName -eq 'Position'
            }
        }
    }
    Context 'failure' {
        Mock Test-ParameterAttribute
        It 'throws' {
            { $p | Assert-ParameterPosition 1 } |
                Should throw 'not position'
        }
    }    
}

Describe Test-ParameterPositional {
    function f { param([Parameter(Position=1)]$x,$y) }
    It 'true' {
        $r = Get-Command f | Get-ParameterMetaData 'x' |
            Test-ParameterPositional
        $r | Should be $true
    }
    It 'false' {
        $r = Get-Command f | Get-ParameterMetaData 'y' |
            Test-ParameterPositional
        $r | Should be $false
    }
}

Describe Assert-ParameterPositional {
    function f { param($x) }
    $p = Get-Command f | Get-ParameterMetaData 'x'
    Context 'success' {
        Mock Test-ParameterPositional { $true } -Verifiable
        It 'returns nothing' {
            $r = $p | Assert-ParameterPositional
            $r | Should beNullOrEmpty
        }
        It 'invokes commands' {
            Assert-MockCalled Test-ParameterPositional 1 {
                $ParameterInfo.Name -eq 'x'
            }
        }
    }
    Context 'failure' {
        Mock Test-ParameterPositional
        It 'throws' {
            { $p | Assert-ParameterPositional } |
                Should throw 'not positional'
        }
    }
}

Describe Invoke-SortParametersByPosition {
    function f { param(
        [Parameter(Position = 2)]$a,
        [Parameter(Position = 1)]$b,
        $c
    )}
    It 'sorts' {
        $r = Get-Command f | Get-ParameterMetaData |
            Invoke-SortParametersByPosition
        $r[0].Name | Should be 'c'
        $r[-2].Name | Should be 'b'
        $r[-1].Name | Should be 'a'
    }
}

Describe Select-OrderedParameters {
    function f { param(
        [Parameter(Position = 2)]$a,
        [Parameter(Position = 1)]$b,
        $c
    )}
    $p = Get-Command f | Get-ParameterMetaData
    It 'returns an array' {
        $r = $p | Select-OrderedParameters
        ,$r | Should beOfType ([array])
    }
    It 'includes only positional parameters' {
        $r = $p | Select-OrderedParameters
        $r.Count | Should be 2
    }
    It 'first' {
        $r = $p | Select-OrderedParameters
        $r[0].Name | Should be 'b'
    }
    It 'second' {
        $r = $p | Select-OrderedParameters
        $r[1].Name | Should be 'a'
    }
}

Describe Get-ParameterOrdinality {
    function f { param(
        $a,
        $b,
        $c
    )}
    $p = Get-Command f | Get-ParameterMetaData
    It 'returns exactly one integer' {
        $r = $p | Get-ParameterOrdinality 'a'
        $r.Count | Should be 1
        $r | Should beOfType ([int])
    }
    It 'first returns 0' {
        $r = $p | Get-ParameterOrdinality 'a'
        $r | Should be 0
    }
    It 'second returns 1' {
        $r = $p | Get-ParameterOrdinality 'b'
        $r | Should be 1
    }
    It 'returns nothing for non-existent parameter' {
        $r = $p | Get-ParameterOrdinality 'x'
        $r | Should beNullOrEmpty
    }
}

Describe Test-ParameterOrdinality {
    function f { param(
        $a,
        $b,
        $c
    )}
    $p = Get-Command f | Get-ParameterMetaData
    It 'true' {
        $r = $p | Test-ParameterOrdinality 'a' 0
        $r | Should be $true
    }
    It 'false' {
        $r = $p | Test-ParameterOrdinality 'a' 1
        $r | Should be $false
    }
}

Describe Assert-ParameterOrdinality {
    function f {param($a)}
    $p = Get-Command f | Get-ParameterMetaData
    Context 'success' {
        Mock Test-ParameterOrdinality { $true } -Verifiable
        It 'returns nothing' {
            $r = $p | Assert-ParameterOrdinality 'a' 0
            $r | Should beNullOrEmpty
        }
        It 'invokes commands' {
            Assert-MockCalled Test-ParameterOrdinality -Times 1 {
                $ParameterInfo.Name -eq 'a'
                $ParameterName -eq 'a' -and
                $Ordinality -eq 0
            }
        }
    }
    Context 'failure' {
        Mock Test-ParameterOrdinality
        It 'throws' {
            { $p | Assert-ParameterOrdinality 'a' 0 } |
                Should throw 'not position ordinality'
        }
    }
}

Describe Get-FunctionParameterDefault {
    function f {param($a=1,$b)}
    $p = Get-Command f | Get-ParameterAst 'a'
    It 'returns exactly one object' {
        $r = $p | Get-FunctionParameterDefault
        $r.Count | Should be 1
    }
    It 'returns default value' {
        $r = $p | Get-FunctionParameterDefault
        $r | Should be 1
    }
    It 'returns nothing for no default value' {
        $r = Get-Command F | Get-ParameterAst 'b' |
            Get-FunctionParameterDefault
        $r | Should beNullOrEmpty
    }
}

Describe Test-FunctionParameterDefault {
    function f {param($a=1,$b)}
    Context 'default' {
        $p = Get-Command f | Get-ParameterAst 'a'
        It 'true' {
            $r = $p | Test-FunctionParameterDefault 1
            $r | Should be $true
        }
        It 'false' {
            $r = $p | Test-FunctionParameterDefault 0
            $r | Should be $false
        }
    }
    Context 'no default' {
        It 'true' {
            $r = Get-Command f | Get-ParameterAst 'b' |
                Test-FunctionParameterDefault -NoDefault
            $r | Should be $true
        }
        It 'false' {
            $r = Get-Command f | Get-ParameterAst 'a' |
                Test-FunctionParameterDefault -NoDefault
            $r | Should be $false
        }
    }
}

Describe Assert-FunctionParameterDefault {
    function f {param($a)}
    $p = Get-Command f | Get-ParameterAst
    Context 'success' {
        Mock Test-FunctionParameterDefault { $true } -Verifiable
        It 'returns nothing' {
            $r = $p | Assert-FunctionParameterDefault 1
            $r | Should beNullOrEmpty
        }
        It 'invokes commands' {
            Assert-MockCalled Test-FunctionParameterDefault 1 {
                $ParameterInfo.Name.VariablePath.UserPath -eq 'a' -and
                $Default -eq 1
            }
        }
    }
    Context 'failure' {
        Mock Test-FunctionParameterDefault
        It 'throws' {
            { $p | Assert-FunctionParameterDefault 1 } |
                Should throw 'not default value'
        }
    }
}

Describe Test-FunctionParameter {
    function f {[CmdletBinding()]param($a,$WhatIf)}
    $f = Get-Command f
    Context 'OptionalCommon' {
        It 'true' {
            $r = $f | Get-ParameterMetaData 'WhatIf' |
                Test-FunctionParameter OptionalCommon
            $r | Should be $true
        }
        It 'false' {
            $r = $f | Get-ParameterMetaData 'Verbose' |
                Test-FunctionParameter OptionalCommon
            $r | Should be $false
        }
    }
    Context 'MandatoryCommon' {
        It 'true' {
            $r = $f | Get-ParameterMetaData 'Verbose' |
                Test-FunctionParameter MandatoryCommon
            $r | Should be $true
        }
        It 'false' {
            $r = $f | Get-ParameterMetaData 'WhatIf' |
                Test-FunctionParameter MandatoryCommon
            $r | Should be $false
        }
    }
    Context 'Common' {
        It 'true' {
            $r = $f | Get-ParameterMetaData 'Verbose' |
                Test-FunctionParameter Common
            $r | Should be $true
        }
        It 'false' {
            $r = $f | Get-ParameterMetaData 'a' |
                Test-FunctionParameter Common
            $r | Should be $false
        }
    }
    Context '-Not Common' {
        It 'true' {
            $r = $f | Get-ParameterMetaData 'a' |
                Test-FunctionParameter -Not Common
            $r | Should be $true
        }
        It 'false' {
            $r = $f | Get-ParameterMetaData 'Verbose' |
                Test-FunctionParameter -Not Common
            $r | Should be $false
        }
    }
}
}