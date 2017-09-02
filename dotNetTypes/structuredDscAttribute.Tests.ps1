Import-Module StructuredDscResourceCheck -Force

Describe StructuredDscAttribute {
    function f {
        param(
            [StructuredDsc('Hint')]
            $x,

            [StructuredDsc()]
            $y
        )
    }
    $f = Get-Command f 
    Context 'ParameterType' {
        It 'takes value Hint' {
            $r = $f |
                Get-ParameterMetaData x |
                Get-ParameterAttribute StructuredDsc |
                Get-AttributeArgument ParameterType
            $r | Should be 'Hint'
        }
        It 'defaults to Property' {
            $r = $f |
                Get-ParameterMetaData y |
                Get-ParameterAttribute StructuredDsc |
                Get-AttributeArgument ParameterType
            $r | Should be 'Property'
        }
    }
}