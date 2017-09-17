Import-Module StructuredResource -Force

InModuleScope StructuredResource {

Describe Invoke-TestStub2 {
    Context 'Presence' {
        Context 'Corrigible' {
            BeforeEach { Reset-TestStub2 }
            It 'starts out absent' {
                $r = Invoke-TestStub2 Test Absent -Presence Corrigible
                $r | Should be $true
            }
            It 'gets set to present' {
                Invoke-TestStub2 Set Present -Presence Corrigible
                $r = Invoke-TestStub2 Test Present -Presence Corrigible
                $r | Should be $true
            }
            It 'false when present' {
                Invoke-TestStub2 Set Present -Presence Corrigible
                $r = Invoke-TestStub2 Test Absent -Presence Corrigible
                $r | Should be $false
            }
            It 'gets set back to absent' {
                Invoke-TestStub2 Set Present -Presence Corrigible
                Invoke-TestStub2 Set Absent -Presence Corrigible
                $r = Invoke-TestStub2 Test Absent -Presence Corrigible
                $r | Should be $true
            }
            It 'false when absent' {
                $r = Invoke-TestStub2 Test Present -Presence Corrigible
                $r | Should be $false
            }
        }
        Context 'Incorrigible' {
            AfterEach { Reset-TestStub2 }
            It 'starts out absent' {
                $r = Invoke-TestStub2 Test Absent -Presence Incorrigible
                $r | Should be $true
            }
            It 'remains absent' {
                Invoke-TestStub2 Set Present -Presence Incorrigible
                $r = Invoke-TestStub2 Test Absent -Presence Incorrigible
                $r | Should be $true
            }
        }
    }
    Context 'Property' {
        Context 'Corrigible' {
            BeforeEach { Reset-TestStub2 }
            It 'starts out empty' {
                Invoke-TestStub2 Set Present -Presence Corrigible
                $r = Invoke-TestStub2 Test Present -Presence Corrigible -Corrigible ([string]::Empty)
                $r | Should be $true
            }
            It 'becomes value' {
                Invoke-TestStub2 Set Present -Presence Corrigible -Corrigible 'value'
                $r = Invoke-TestStub2 Test Present -Presence Corrigible -Corrigible 'value'
                $r | Should be $true
            }
            It 'null leave value unchanged' {
                Invoke-TestStub2 Set Present -Presence Corrigible -Corrigible 'value'
                Invoke-TestStub2 Set Present -Presence Corrigible -Corrigible $null
                $r = Invoke-TestStub2 Test Present -Presence Corrigible -Corrigible 'value'
                $r | Should be $true
            }
            It 'becomes empty' {
                Invoke-TestStub2 Set Present -Presence Corrigible -Corrigible 'value'
                Invoke-TestStub2 Set Present -Presence Corrigible -Corrigible ([string]::Empty)
                $r = Invoke-TestStub2 Test Present -Presence Corrigible -Corrigible ([string]::Empty)
                $r | Should be $true
            }
            It 'false when value' {
                Invoke-TestStub2 Set Present -Presence Corrigible -Corrigible 'value'
                $r = Invoke-TestStub2 Test Present -Presence Corrigible -Corrigible ([string]::Empty)
                $r | Should be $false
            }
            It 'false when empty' {
                Invoke-TestStub2 Set Present -Presence Corrigible
                $r = Invoke-TestStub2 Test Present -Presence Corrigible -Corrigible 'value'
                $r | Should be $false
            }
        }
        Context 'Incorrigible' {
            BeforeEach { Reset-TestStub2 }
            It 'starts out empty' {
                Invoke-TestStub2 Set Present -Presence Corrigible
                $r = Invoke-TestStub2 Test Present -Presence Corrigible -Incorrigible ([string]::Empty)
                $r | Should be $true
            }
            It 'remains empty' {
                Invoke-TestStub2 Set Present -Presence Corrigible -Incorrigible 'value'
                $r = Invoke-TestStub2 Test Present -Presence Corrigible -Incorrigible ([string]::Empty)
                $r | Should be $true
            }
            It 'test false when set to non-empty' {
                Invoke-TestStub2 Set Present -Presence Corrigible -Incorrigible 'value'
                $r = Invoke-TestStub2 Test Present -Presence Corrigible -Incorrigible 'value'
                $r | Should be $false
            }
        }
    }
}
}