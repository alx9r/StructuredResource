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

Describe New-StructuredDscParameterGroup {
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

Describe Get-PersistentItemParameters {
    Context 'all params' {
        $r = f @allParams | Get-PersistentItemParameters
        It 'returns a pscustomobject' {
            $r | Should beOfType([pscustomobject])
        }
        It 'populates Keys' {
            $r.Keys.get_Keys().Count | Should be 1
            $r.Keys.get_Item('Key') | Should be 'Key'
        }
        It 'populates Hints' {
            $r.Hints.Keys.Count | Should be 1
            $r.Hints.Hint | Should be 'hint'
        }
        It 'populates Properties' {
            $r.Properties.Keys.Count | Should be 2
            $r.Properties.Property1 | Should be 'property1'
            $r.Properties.Property2 | Should be 'property2'
        }
    }
}
}