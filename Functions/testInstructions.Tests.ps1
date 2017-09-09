Import-Module StructuredDscResourceCheck -Force

InModuleScope StructuredDscResourceCheck {

Describe New-StructuredResourceTest {
    Mock New-TestParams { 
        $obj = [TestParams]::new()
        $obj.ModuleName = 'resulting_module_name'
        $obj.ResourceName = 'resulting_resource_name'
        $obj.Arguments = @{ resulting_arg = 'arg' }
        $obj
    } -Verifiable
    Mock New-Object { 'object' } -Verifiable
    It 'returns object' {
        $r = New-StructuredResourceTest 'resource_name' 'module_name' @{ arg = 'arg' }

        $r | Should be 'object'
    }
    It 'invokes commands' {
        Assert-MockCalled New-TestParams 1 {
            $ResourceName -eq 'resource_name' -and
            $ModuleName -eq 'module_name' -and
            $Arguments.arg -eq 'arg'
        }
        Assert-MockCalled New-Object 1 {
            $TypeName -eq 'TestInstructions' -and
            $ArgumentList.ModuleName -eq 'resulting_module_name' -and
            $ArgumentList.ResourceName -eq 'resulting_resource_name'
        }
    }
}

Describe Get-TestEnumerator {
    $p = New-Object TestParams -Property @{
        ModuleName = 'module_name'
        ResourceName = 'resource_name'
    }
    Mock Get-OrderedSteps { 
        1,2 |
            % { 
                New-Object StructuredResourceTest -Property @{ 
                    ID = $_
                    Scriptblock = {}
                }
            }
    } -Verifiable
    It 'returns enumerator' {
        $ti = [TestInstructions]::new($p)
        
        $r = (Get-TestEnumerator -Enumerable $ti).GetType()

        $r.GetInterface('IEnumerator') |
            Should not beNullOrEmpty
    }
    It 'invokes commands' {
        Assert-MockCalled Get-OrderedSteps 1
    }
    It 'populates params' {
        $ti = [TestInstructions]::new($p)
        
        $r = Get-TestEnumerator -Enumerable $ti |
            % {$_}
        
        $r[0].Params.ModuleName | Should be 'module_name'
        $r[0].Params.ResourceName | Should be 'resource_name'
    }
}
}