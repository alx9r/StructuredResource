Import-Module StructuredDscResourceCheck -Force

Describe StructuredDscAttribute {
    function f {
        param(
            [StructuredDsc(Hint)]
            $x,

            [StructuredDsc()]
            $y
        )
    }
    $f = Get-Command f 
    Context 'Hint' {
        It 'true' {
            $r = $f |
                Get-ParameterMetaData x |
                Get-ParameterAttribute StructuredDsc |
                Get-AttributeArgument Hint
            $r | Should be $true
        }
        It 'false' {
            $r = $f |
                Get-ParameterMetaData y |
                Get-ParameterAttribute StructuredDsc |
                Get-AttributeArgument Hint
            $r | Should be $false
        }
    }
}