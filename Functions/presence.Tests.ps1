Import-Module StructuredDscResourceCheck -Force

InModuleScope StructuredDscResourceCheck {

Describe Invoke-PresenceTest {
    function f {
        param
        (
            [Parameter(position=1)]$Mode,
            [Parameter(position=2)]$Ensure,
            $Key1
        )
        if ( $Key1 -eq 'throw' )
        {
            throw 'exception in f'
        }
    }
    Mock Get-PublicResourceFunction { Get-Command f } -Verifiable
    Mock Get-ParameterMetaData { (Get-Command f).Parameters.Key1 } -Verifiable
    Mock New-StructuredDscArgumentGroup { @{ Key1 = 1 } } -Verifiable
    Mock Invoke-Scriptblock { 'scriptblock output' } -Verifiable
    $i = [pscustomobject]@{
        ResourceName = 'resource_name'
        ModuleName = 'module_name'
        Arguments = @{ arguments = 'arguments' }
    }
    $sb = {'scriptblock'}
    Context 'success' {
        It 'returns scriptblock output' {
            $r = $i | Invoke-PresenceTest $sb
            $r | Should be 'scriptblock output'
        }
        It 'invokes commands' {
            Assert-MockCalled Get-PublicResourceFunction 1 {
                $ResourceName -eq 'resource_name' -and
                $ModuleName -eq 'module_name'
            }
            Assert-MockCalled Get-ParameterMetaData 1 {
                $FunctionInfo.Name -eq 'f'
            }
            Assert-MockCalled New-StructuredDscArgumentGroup 1 {
                $GroupName -eq 'Keys' -and
                $NamedArguments.arguments -eq 'arguments'
            }
            Assert-MockCalled Invoke-Scriptblock 1 {
                [string]$Scriptblock -eq [string]{'scriptblock'} -and
                $NamedArgs.Keys.Key1 -eq 1
            }
        }
    }
    Context 'pipeline exception' {
        Mock Invoke-Scriptblock { throw 'in scriptblock' }
        try
        {
            $i | Invoke-PresenceTest $sb
        }
        catch
        {
            $e = $_
        }
        It 'passes an exception through' {
            $e | Should not beNullOrEmpty
        }
        It 'outer exception' {
            $e.Exception.Message | Should match 'CommandName: f'
        }
        It 'inner exception' {
            $e.Exception.InnerException.Message | Should match 'in scriptblock'
        }
    }
}
}