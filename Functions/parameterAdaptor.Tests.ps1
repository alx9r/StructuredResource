Import-Module StructuredResource -Force

InModuleScope StructuredResource {

New-Psm1Module m {
    function f
    {
        [CmdletBinding()]
        param
        (
            $Mode,
            $Ensure,
            [StructuredResource('Key')]$Key,
            [StructuredResource('Hint')]$Hint,
            [StructuredResource('ConstructorProperty')]$CtorProp,
            $Property1,
            $Property2
        )
        process
        {
            $MyInvocation
        }
    }
} | Import-Module

Describe Test-StructuredResourceAttributeParameter {
    $p = Get-Command f | Get-ParameterMetaData 'Key'
    It 'true' {
        $r = $p | Test-StructuredResourceAttributeParameter 'Key'
        $r | Should be $true
    }
    It 'false : not match' {
        $r = $p | Test-StructuredResourceAttributeParameter 'Hint'
        $r | Should be $false
    }
    It 'false : non-existent' {
        $r = Get-Command f | Get-ParameterMetaData 'Mode' |
            Test-StructuredResourceAttributeParameter 'Key'
        $r | Should be $false
    }
}

Describe Test-StructuredKnownParameter {
    It 'returns <e> for <p>' -TestCases @(
        @{p='Mode';  e=$true},
        @{p='Ensure';e=$true},
        @{p='Key';   e=$false}
    ) {
        param($p,$e)

        $r = Get-Command f | Get-ParameterMetaData $p |
            Test-StructuredKnownParameter
        $r | Should be $e
    }
}

Describe Test-StructuredPropertyParameter {
    It 'returns <e> for <p>' -TestCases @(
        @{p='Mode';e=$false}
        @{p='Key';e=$false}
        @{p='Property1';e=$true}
    ) {
        param($p,$e)

        $r = Get-Command f | Get-ParameterMetaData $p |
            Test-StructuredPropertyParameter
        $r | Should be $e
    }
}

Describe Test-StructuredGroupParameter {
    It 'returns <e> for <p> in group <g>' -TestCases @(
        @{ p='Key';      g='Keys';      e=$true  }
        @{ p='Key';      g='Hints';     e=$false }
        @{ p='Key';      g='Properties';e=$false }
        @{ p='Hint';     g='Keys';      e=$false }
        @{ p='Hint';     g='Hints';     e=$true  }
        @{ p='Hint';     g='Properties';e=$false }
        @{ p='CtorProp'; g='Keys';      e=$false }
        @{ p='CtorProp'; g='Hints';     e=$true  }
        @{ p='CtorProp'; g='Properties';e=$true  }
        @{ p='Property1';g='Keys';      e=$false }
        @{ p='Property1';g='Hints';     e=$false }
        @{ p='Property1';g='Properties';e=$true  }
        @{ p='Property2';g='Keys';      e=$false }
        @{ p='Property2';g='Hints';     e=$false }
        @{ p='Property2';g='Properties';e=$true  }
    ) {
        param($p,$g,$e)

        $r = Get-Command f | Get-ParameterMetaData $p |
            Test-StructuredGroupParameter $g
        $r | Should be $e
    }
}

$allParams = @{
    Mode = 'mode'
    Ensure = 'ensure'
    Key = 'key'
    Hint = 'hint'
    CtorProp = 'ctorprop'
    Property1 = 'property1'
    Property2 = 'property2'
}
$minParams = @{
    Mode = 'mode'
    Key = 'key'
}
$nullParams = @{
    Mode = 'mode'
    Ensure = $null
    Key = 'key'
    Hint = $null
    CtorProp = $null
    Property1 = $null
    Property2 = $null
}

Describe New-StructuredArgumentGroup {
    Context 'BoundParameters' {
        Context 'all params' {
            $mi = f @allParams
            $c = $mi.MyCommand
            $p = $mi.BoundParameters
            It 'Keys' {
                $r = $c | Get-ParameterMetaData |
                    New-StructuredArgumentGroup Keys $p
                $r.Keys.Count | Should be 1
                $r.Key | Should be 'key'
            }
            It 'Hints' {
                $r = $c | Get-ParameterMetaData |
                    New-StructuredArgumentGroup Hints $p
                $r | Should beOfType ([hashtable])
                $r.Keys.Count | Should be 2
                $r.Hint | Should be 'hint'
                $r.CtorProp | Should be 'ctorprop'
            }
            It 'Properties' {
                $r = $c | Get-ParameterMetaData |
                    New-StructuredArgumentGroup Properties $p
                $r | Should beOfType ([hashtable])
                $r.Keys.Count | Should be 3
                $r.Property1 | Should be 'property1'
                $r.Property2 | Should be 'property2'
                $r.CtorProp | Should be 'ctorprop'
            }
        }
        Context 'omit optional params' {
            $mi = f @minParams
            $c = $mi.MyCommand
            $p = $mi.BoundParameters
            It '<n>' -TestCases @(
                @{n='Hints'}
                @{n='Properties'}
            ) {
                param($n)

                $r = $c | Get-ParameterMetaData |
                    New-StructuredArgumentGroup $n $p
                $r | Should beNullOrEmpty
            }
        }
        Context 'null optional params' {
            $mi = f @nullParams
            $c = $mi.MyCommand
            $p = $mi.BoundParameters
            It '<n>' -TestCases @(
                @{n='Hints'}
                @{n='Properties'}
            ) {
                param($n)
                $r = $c | Get-ParameterMetaData |
                    New-StructuredArgumentGroup $n $p
                $r | Should beNullOrEmpty
            }
        }
    }
    Context 'hashtable' {
        It 'Keys' {
            $r = Get-Command f | Get-ParameterMetaData |
                New-StructuredArgumentGroup Keys $allParams
            $r.Count | Should be 1
            $r.Key | Should be 'key'
        }
    }
}

Describe New-StructuredArgs {
    Mock New-StructuredArgumentGroup { 'return value' } -Verifiable    
    $r = Get-Command f | Get-ParameterMetaData |
        New-StructuredArgs $allParams
    It 'returns one hashtable' {
        $r | measure | % Count | Should be 1
        $r | Should beOfType([hashtable])
    }
    It 'populates item <g>' -TestCases @(
        @{g='Keys'}
        @{g='Hints'}
        @{g='Properties'}
    ) {
        param($g)
        $r.$g | Should match 'return value'
    }
    It 'has no other items' {
        $r.Count | Should be 3
    }
    It 'invokes commands' {
        Assert-MockCalled New-StructuredArgumentGroup 1 { $GroupName -eq 'Keys' }
        Assert-MockCalled New-StructuredArgumentGroup 1 { $GroupName -eq 'Hints' }
        Assert-MockCalled New-StructuredArgumentGroup 1 { $GroupName -eq 'Properties' }
        Assert-MockCalled New-StructuredArgumentGroup 1 {
            $NamedArguments.Key -eq 'key'
        }
    }
}

Describe Add-StructuredGroupParameters {
    Context 'all params' {
        $i = New-Object pscustomobject
        $r = $i | Add-StructuredGroupParameters (f @allParams)
        It 'returns nothing' {
            $r | Should beNullOrEmpty
        }
        It '-Passthru returns input object' {
            $i = New-Object pscustomobject
            $r = $i | Add-StructuredGroupParameters (f @allParams) -PassThru
            $r | Should be $i
        }
        It 'populates Keys' {
            $i.Keys.get_Keys().Count | Should be 1
            $i.Keys.get_Item('Key') | Should be 'key'
        }
        It 'populates Hints' {
            $i.Hints.get_Keys().Count | Should be 2
            $i.Hints.get_Item('Hint') | Should be 'hint'
            $i.Hints.get_Item('CtorProp') | Should be 'ctorprop'
        }
        It 'populates Properties' {
            $i.Properties.get_Keys().Count | Should be 3
            $i.Properties.get_Item('Property1') | Should be 'property1'
            $i.Properties.get_Item('Property2') | Should be 'property2'
            $i.Properties.get_Item('CtorProp') | Should be 'ctorprop'
        }
    }
    Context 'omit optional params' {
        $i = New-Object pscustomobject
        $r = $i | Add-StructuredGroupParameters (f @minParams)
        It 'omits Hints' {
            $i | Get-Member Hints | Should beNullOrEmpty
        }
        It 'omits Properties' {
            $i | Get-Member Properties | Should beNullOrEmpty
        }
    }
    Context 'null optional params' {
        $i = New-Object pscustomobject
        $r = $i | Add-StructuredGroupParameters (f @nullParams)
        It 'omits Hints' {
            $i | Get-Member Hints | Should beNullOrEmpty
        }
        It 'omits Properties' {
            $i | Get-Member Properties | Should beNullOrEmpty
        }
    }
}

Describe New-StructuredResourceArgs {
    Mock Add-StructuredGroupParameters {$InputObject} -Verifiable
    Context 'all params' {
        $r = f @allParams | New-StructuredResourceArgs @{
            Param1 = 'param1'
            Param2 = 'param2'
        }
        It 'returns a pscustomobject' {
            $r | measure | % Count | Should be 1
            $r | Should beOfType([pscustomobject])
        }
        It 'invokes commands' {
            Assert-MockCalled Add-StructuredGroupParameters 1 {
                $InvocationInfo.MyCommand.Name -eq 'f' -and
                $InvocationInfo.BoundParameters.Mode -and
                $PassThru
            }
        }
        It 'populates Mode' {
            $r.Mode | Should be 'mode'
        }
        It 'populates Ensure' {
            $r.Ensure | Should be 'ensure'
        }
        It 'populates input parameters' {
            $r.Param1 | Should be 'param1'
            $r.Param2 | Should be 'param2'
        }
        It 'populates module' {
            $r.Module.Name | Should be 'm'
        }
    }
    Context 'omit optional params' {
        $r = f @minParams | New-StructuredResourceArgs @{}
        It 'omits Ensure' {
            $r | Get-Member Ensure | Should beNullOrEmpty
        }
    }
    Context 'null optional params' {
        $r = f @nullParams | New-StructuredResourceArgs @{}
        It 'omits Ensure' {
            $r | Get-Member Ensure | Should beNullOrEmpty
        }
    }
}

Describe 'use New-StructuredResourceArgs' {
    function Invoke-SomeResource
    {
        [CmdletBinding()]
        param
        (
            $Mode,
            $Ensure,
            [StructuredResource('Key')]$Key,
            [StructuredResource('Hint')]$Hint,
            $Property1,
            $Property2
        )
        process
        {
            $params = $MyInvocation | 
                New-StructuredResourceArgs @{
                    Tester = 'Test-SomeResource'
                    Curer = 'Add-SomeResource'
                    Remover = 'Remove-SomeResource'
                    PropertyTester = 'Test-SomeResourceProperty'
                    PropertyCurer = 'Set-SomeResourceProperty'
                }
            $params | Invoke-StructuredResource
        }
    }
    Context 'all params' {
        Mock Invoke-StructuredResource { 'return value' } -Verifiable
        It 'passes through value' {
            $splat = @{
                Mode = 'Set'
                Ensure = 'Present'
                Key = 'key'
                Hint = 'hint'
                Property1 = 'property1'
                Property2 = 'property2'
            }
            $r = Invoke-SomeResource @splat
            $r | Should be 'return value'
        }
        It 'passes through resource parameters' {
            Assert-MockCalled Invoke-StructuredResource 1 {
                $Mode -eq 'Set' -and
                $Ensure -eq 'Present' -and
                $_Keys.Key -eq 'key' -and
                $Hints.Hint -eq 'hint' -and
                $Properties.Property1 -eq 'property1' -and
                $Properties.Property2 -eq 'property2'
            }
        }
        It 'passes through delegate names' {
            Assert-MockCalled Invoke-StructuredResource 1 {
                $Tester -eq 'Test-SomeResource' -and
                $Curer -eq 'Add-SomeResource' -and
                $Remover -eq 'Remove-SomeResource' -and
                $PropertyTester -eq 'Test-SomeResourceProperty' -and
                $PropertyCurer -eq 'Set-SomeResourceProperty'
            }
        }
    }
    Context 'omit optional params, keep all delegates' {
        Mock Invoke-StructuredResource { 'return value' } -Verifiable
        It 'passes through value' {
            $splat = @{
                Mode = 'Set'
                Key = 'key'
            }
            $r = Invoke-SomeResource @splat
            $r | Should be 'return value'
        }
        It 'omits omitted resource parameters' {
            Assert-MockCalled Invoke-StructuredResource 1 {
                $null -eq $Ensure -and
                $null -eq $Hints -and
                $null -eq $Properties
            }
        }
    }
    Context 'null optional params, keep all delegates' {
        Mock Invoke-StructuredResource { 'return value' } -Verifiable
        It 'passes through value' {
            $splat = @{
                Mode = 'Set'
                Ensure = 'Present'
                Key = 'key'
                Hint = $null
                Property1 = $null
                Property2 = $null
            }
            $r = Invoke-SomeResource @splat
            $r | Should be 'return value'
        }
        It 'omits omitted resource parameters' {
            Assert-MockCalled Invoke-StructuredResource 1 {
                $null -eq $Hints -and
                $null -eq $Properties
            }
        }
    }
    Context 'omit optional params and optional delegates' {
        function Invoke-SomeResource
        {
            [CmdletBinding()]
            param
            (
                $Mode,
                $Ensure,
                [StructuredResource('Key')]$Key,
                [StructuredResource('Hint')]$Hint,
                $Property1,
                $Property2
            )
            process
            {
                $MyInvocation | 
                    New-StructuredResourceArgs @{
                        Tester = 'Test-SomeResource'
                        Curer = 'Add-SomeResource'
                    } |
                    Invoke-StructuredResource
            }
        }

        Mock Invoke-StructuredResource { 'return value' } -Verifiable
        It 'passes through value' {
            $splat = @{
                Mode = 'Set'
                Key = 'key'
            }
            $r = Invoke-SomeResource @splat
            $r | Should be 'return value'
        }
        It 'omits omitted delegates' {
            Assert-MockCalled Invoke-StructuredResource 1 {
                $null -eq $Remover -and
                $null -eq $PropertyTester -and
                $null -eq $PropertyCurer
            }
        }
    }
}
}