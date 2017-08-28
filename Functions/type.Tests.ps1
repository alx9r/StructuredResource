Import-Module StructuredDscResourceCheck -Force

InModuleScope StructuredDscResourceCheck {

Describe Test-Type {
    It 'true' {
        $r = [int] | Test-Type ([int])
        $r | Should be $true
    }
    It 'false' {
        $r = [int] | Test-Type ([string])
        $r | Should be $false
    }
}

Describe Assert-Type {
    Context 'match' {
        Mock Test-Type { $true } -Verifiable
        It 'returns nothing' {
            $r = [int] | Assert-Type ([int])
            $r | Should beNullOrEmpty
        }
        It '-not : throws' {
            { [int] | Assert-Type -not ([int]) } |
                Should throw 'type was int'
        }
        It 'invokes commands' {
            Assert-MockCalled Test-Type 2 {
                $Expected.Name -eq 'int32' -and
                $Actual.Name -eq 'int32'
            }
        }
    }
    Context 'mismatch' {
        Mock Test-Type { $false }
        It 'throws' {
            { [string] | Assert-Type ([int]) } |
                Should throw 'was type string'
        }
        It '-not : returns nothing' {
            $r = [int] | Assert-Type -not ([string])
            $r | Should beNullOrEmpty
        }
    }
}

Describe Test-ValueType {
    It 'true' {
        $r = [int] | Test-ValueType
        $r | Should be $true
    }
    It 'false' {
        $r = [string] | Test-ValueType
        $r | Should be $false
    }
}

Describe Assert-xValueType {
    Context 'is value type' {
        Mock Test-ValueType { $true } -Verifiable
        It 'returns nothing' {
            $r = [int] | Assert-ValueType
            $r | Should beNullOrEmpty
        }
        It 'Not throws' {
            { [int] | Assert-NotValueType } |
                Should throw 'is a value type'
        }
        It 'invokes commands' {
            Assert-MockCalled Test-ValueType 2 {
                $TypeInfo.Name -eq 'int32'
            }
        }
    }
    Context 'is not value type' {
        Mock Test-ValueType { $false }
        It 'throws' {
            { [string] | Assert-ValueType } |
                Should throw 'is not a value type'
        }
        It 'Not returns nothing' {
            $r = [string] | Assert-NotValueType
            $r | Should beNullOrEmpty
        }
    }
}

Describe Test-NullableType {
    It 'true : string' {
        $r = [string] | Test-NullableType
        $r | Should be $true
    }
    It 'true : Nullable[int]' {
        $r = [System.Nullable[int]] | Test-NullableType
        $r | Should be $true
    }
    It 'false: int' {
        $r = [int] | Test-NullableType
        $r | Should be $false
    }
}

Describe Assert-NullableType {
    Context 'success' {
        Mock Test-NullableType { $true } -Verifiable
        It 'returns nothing' {
            $r = [string] | Assert-NullableType
            $r | Should beNullOrEmpty
        }
        It 'invokes command' {
            Assert-MockCalled Test-NullableType 1 {
                $TypeInfo.Name -eq 'string'
            }
        }
    }
    Context 'failure' {
        Mock Test-NullableType { $false }
        It 'throws' {
            { [int] | Assert-NullableType } |
                Should throw 'not nullable'
        }
    }
}
}