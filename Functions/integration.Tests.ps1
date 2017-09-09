Import-Module StructuredResource -Force

InModuleScope StructuredResource {

Describe Invoke-IntegrationTest {
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
    Mock New-StructuredDscArgs { @{ Keys='k';Hints='h';Properties='p' } } -Verifiable
    Mock Invoke-Scriptblock { 'scriptblock output' } -Verifiable
    $i = [pscustomobject]@{
        ResourceName = 'resource_name'
        ModuleName = 'module_name'
        Arguments = @{ arguments = 'arguments' }
    }
    $sb = {'scriptblock'}
    Context 'success' {
        It 'returns scriptblock output' {
            $r = $i | Invoke-IntegrationTest $sb
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
            Assert-MockCalled New-StructuredDscArgs 1 {
                $NamedArguments.arguments -eq 'arguments'
            }
            Assert-MockCalled Invoke-Scriptblock 1 {
                [string]$Scriptblock -eq [string]{'scriptblock'} -and
                $NamedArgs.CommandName -eq 'f' 
                $NamedArgs.Keys -eq 'k' -and
                $NamedArgs.Hints -eq 'h' -and
                $NamedArgs.Properties -eq 'p'
            }
        }
    }
    Context 'pipeline exception' {
        Mock Invoke-Scriptblock { throw 'in scriptblock' }
        try
        {
            $i | Invoke-IntegrationTest $sb
        }
        catch
        {
            $e = $_
        }
        It 'passes an exception through' {
            $e | Should not beNullOrEmpty
        }
        It 'outer exception' {
            $e.Exception.Message | Should match "CommandName='f'"
        }
        It 'inner exception' {
            $e.Exception.InnerException.Message | Should match 'in scriptblock'
        }
    }
}
}