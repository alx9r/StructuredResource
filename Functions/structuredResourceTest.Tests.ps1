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
    }
    Mock f { 
        'result'
    } -Verifiable
    It 'returns output of scriptblock' {
        $r = $ts | Invoke-StructuredResourceTest
        $r | Should be 'result'
    }
    It 'invokes commands' {
        Assert-MockCalled f 1 {
            $ModuleName -eq 'module_name' -and
            $ResourceName -eq 'resource_name'
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