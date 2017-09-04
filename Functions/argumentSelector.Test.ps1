Import-Module StructuredDscResourceCheck -Force

InModuleScope StructuredDscResourceCheck {

Describe Select-Argument {
    function f { param($x,$y,$z) }
    $p = Get-Command f | 
        Get-ParameterMetaData | ? {$_.Name -ne 'x'}
    $r = @{x=1;y=2;z=3} | Select-Argument $p
    
    It 'returns one hashtable' {
        $r | measure | % Count | Should be 1
        $r | Should beOfType([hashtable])
    }
    It 'selects arguments for the parameters provided' {
        $r.y | Should be 2
        $r.z | Should be 3
    }
    It 'omits arguments for the parameters omitted' {
        $r.x | Should beNullOrEmpty
        $r.Count | Should be 2
    }
}
}