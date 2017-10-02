Import-Module StructuredResource -Force

InModuleScope StructuredResource {

Describe StructuredResourceAttribute {
    function f {
        param(
            [StructuredResource('Hint')]
            $x,

            [StructuredResource()]
            $y
        )
    }
    $f = Get-Command f
    Context 'ParameterType' {
        It 'takes value Hint' {
            $r = $f |
                Get-ParameterMetaData x |
                Get-ParameterAttribute StructuredResource |
                Get-AttributeArgument ParameterType
            $r | Should be 'Hint'
        }
        It 'defaults to Property' {
            $r = $f |
                Get-ParameterMetaData y |
                Get-ParameterAttribute StructuredResource |
                Get-AttributeArgument ParameterType
            $r | Should be 'Property'
        }
    }
}
}
