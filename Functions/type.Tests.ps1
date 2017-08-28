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
}