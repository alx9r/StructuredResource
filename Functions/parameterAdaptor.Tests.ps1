Import-Module StructuredDscResourceCheck -Force

InModuleScope StructuredDscResourceCheck {

function f
{
    [CmdletBinding()]
    param
    (
        $Mode,
        $Ensure,
        [StructuredDsc('Key')]$Key,
        [StructuredDsc('Hint')]$Hint,
        $Property1,
        $Property2
    )
    process
    {
        $MyInvocation
    }
}

Describe Test-StructuredDscAttributeParameter {
    $p = Get-Command f | Get-ParameterMetaData 'Key'
    It 'true' {
        $r = $p | Test-StructuredDscAttributeParameter 'Key'
        $r | Should be $true
    }
    It 'false : not match' {
        $r = $p | Test-StructuredDscAttributeParameter 'Hint'
        $r | Should be $false
    }
    It 'false : non-existent' {
        $r = Get-Command f | Get-ParameterMetaData 'Mode' |
            Test-StructuredDscAttributeParameter 'Key'
        $r | Should be $false
    }
}

Describe Test-StructuredDscKnownParameter {
    It 'returns <e> for <p>' -TestCases @(
        @{p='Mode';  e=$true},
        @{p='Ensure';e=$true},
        @{p='Key';   e=$false}
    ) {
        param($p,$e)

        $r = Get-Command f | Get-ParameterMetaData $p |
            Test-StructuredDscKnownParameter
        $r | Should be $e
    }
}

Describe Test-StructuredDscPropertyParameter {
    It 'returns <e> for <p>' -TestCases @(
        @{p='Mode';e=$false}
        @{p='Key';e=$false}
        @{p='Property1';e=$true}
    ) {
        param($p,$e)

        $r = Get-Command f | Get-ParameterMetaData $p |
            Test-StructuredDscPropertyParameter
        $r | Should be $e
    }
}

$allParams = @{
    Mode = 'mode'
    Ensure = 'ensure'
    Key = 'key'
    Hint = 'hint'
    Property1 = 'property1'
    Property2 = 'property2'
}
$minParams = @{
    Mode = 'mode'
    Key = 'key'
}

Describe New-StructuredDscParameterGroup {
    Context 'all params' {
        $mi = f @allParams
        $c = $mi.MyCommand
        $p = $mi.BoundParameters
        It 'Known' {
            $r = $c | Get-ParameterMetaData |
                New-StructuredDscParameterGroup Known $p
            $r | Should beOfType ([hashtable])
            $r.Keys.Count | Should be 2
            $r.Ensure | Should be 'ensure'
            $r.Mode | Should be 'mode'
        }
        It 'Key' {
            $r = $c | Get-ParameterMetaData |
                New-StructuredDscParameterGroup Key $p
            $r.Keys.Count | Should be 1
            $r.Key | Should be 'key'
        }
        It 'Hint' {
            $r = $c | Get-ParameterMetaData |
                New-StructuredDscParameterGroup Hint $p
            $r | Should beOfType ([hashtable])
            $r.Keys.Count | Should be 1
            $r.Hint | Should be 'hint'
        }
        It 'Property' {
            $r = $c | Get-ParameterMetaData |
                New-StructuredDscParameterGroup Property $p
            $r | Should beOfType ([hashtable])
            $r.Keys.Count | Should be 2
            $r.Property1 | Should be 'property1'
            $r.Property2 | Should be 'property2'
        }
    }
    Context 'omit optional params' {
        $mi = f @minParams
        $c = $mi.MyCommand
        $p = $mi.BoundParameters
        It 'Known' {
            $r = $c | Get-ParameterMetaData |
                New-StructuredDscParameterGroup Known $p
            $r.Keys.Count | Should be 1
            $r.Mode | Should be 'mode'
        }
        It 'Hint' {
            $r = $c | Get-ParameterMetaData |
                New-StructuredDscParameterGroup Hint $p
            $r | Should beNullOrEmpty
        }
        It 'Property' {
            $r = $c | Get-ParameterMetaData |
                New-StructuredDscParameterGroup Property $p
            $r | Should beNullOrEmpty
        }
    }
}

Describe Add-StructuredDscGroupParameters {
    Context 'all params' {
        $i = New-Object pscustomobject
        $r = $i | Add-StructuredDscGroupParameters (f @allParams)
        It 'returns nothing' {
            $r | Should beNullOrEmpty
        }
        It '-Passthru returns input object' {
            $i = New-Object pscustomobject
            $r = $i | Add-StructuredDscGroupParameters (f @allParams) -PassThru
            $r | Should be $i
        }
        It 'populates Keys' {
            $i.Keys.get_Keys().Count | Should be 1
            $i.Keys.get_Item('Key') | Should be 'Key'
        }
        It 'populates Hints' {
            $i.Hints.Keys.Count | Should be 1
            $i.Hints.Hint | Should be 'hint'
        }
        It 'populates Properties' {
            $i.Properties.Keys.Count | Should be 2
            $i.Properties.Property1 | Should be 'property1'
            $i.Properties.Property2 | Should be 'property2'
        }
    }
    Context 'omit optional params' {
        $i = New-Object pscustomobject
        $r = $i | Add-StructuredDscGroupParameters (f @minParams)
        It 'omits Hints' {
            $i | Get-Member Hints | Should beNullOrEmpty
        }
        It 'omits Properties' {
            $i | Get-Member Properties | Should beNullOrEmpty
        }
    }
}

Describe New-StructuredDscParameters {
    Mock Add-StructuredDscGroupParameters {$InputObject} -Verifiable
    Context 'all params' {
        $r = f @allParams | New-StructuredDscParameters @{
            Param1 = 'param1'
            Param2 = 'param2'
        }
        It 'returns a pscustomobject' {
            $r | measure | % Count | Should be 1
            $r | Should beOfType([pscustomobject])
        }
        It 'invokes commands' {
            Assert-MockCalled Add-StructuredDscGroupParameters 1 {
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
    }
    Context 'omit optional params' {
        $r = f @minParams | New-StructuredDscParameters @{}
        It 'omits Ensure' {
            $r | Get-Member Ensure | Should beNullOrEmpty
        }
    }
}
}