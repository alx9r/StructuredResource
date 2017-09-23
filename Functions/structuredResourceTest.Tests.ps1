Import-Module StructuredResource -Force

InModuleScope StructuredResource {

Describe Invoke-StructuredResourceTest {
    function f { 
        param
        (
            [Parameter(ValueFromPipelineByPropertyName = $true)]
            $ModuleName,

            [Parameter(ValueFromPipelineByPropertyName = $true)]
            $ResourceName

        )
    }
    $ts = New-Object StructuredResourceTest -Property @{
        Arguments = New-Object TestArgs -Property @{
            ModuleName = 'module_name'
            ResourceName = 'resource_name'
        }
        Scriptblock = { $_ | f }
        ID = 'ID'
        Message = 'Message'
    }
    Mock f { 'result' } -Verifiable
    Context 'success' {
        $r = $ts | Invoke-StructuredResourceTest
        It 'returns results object' {
            $r | Should -BeOfType ([StructuredResourceTestResult])
        }
        It 'populates fields' {
            $r.Test | Should -Be $ts
            $r.TestOutput | Should -Be 'result'
        }
        It 'invokes commands' {
            Assert-MockCalled f 1 {
                $ModuleName -eq 'module_name' -and
                $ResourceName -eq 'resource_name'
            }
        }
    }
    Context 'failure' {
        Mock f { throw 'mock threw' } -Verifiable
        It 'throws' {
            { $ts | Invoke-StructuredResourceTest } |
                Should throw
        }
        try { $ts | Invoke-StructuredResourceTest }
        catch { $e = $_.Exception }
        It 'outer exception' {
            $e | Should -Match 'ID - Message'
        }
        It 'inner exception' {
            $e.InnerException | Should -Match 'mock threw'
        }
    }
}

Describe Get-StructuredResourceTestKind {
    It 'Integration' {
        $r = New-Object StructuredResourceTest -Property @{ Scriptblock = {Invoke-IntegrationTest} } |
            Get-StructuredResourceTestKind
        $r | Should be 'Integration'
    }
    It 'Unit' {
        $r = New-Object StructuredResourceTest |
            Get-StructuredResourceTestKind
        $r | Should be 'Unit'
    }
}

Describe Test-StructuredResourceTestKind {
    $in = New-Object StructuredResourceTest -Property @{ Scriptblock = {'some scriptblock'} }
    Mock Get-StructuredResourceTestKind { [TestKind]::Integration } -Verifiable
    It 'true' {
        $r = $in | Test-StructuredResourceTestKind 'Integration'
        $r | Should be $true
    }
    It 'false' {
        $r = $in | Test-StructuredResourceTestKind 'Unit'
        $r | Should be $false
    }
    It 'invokes commands' {
        Assert-MockCalled Get-StructuredResourceTestKind 2 {
            [string]{'some scriptblock'} -eq $InputObject.Scriptblock
        }
    }
}
}