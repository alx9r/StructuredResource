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
}