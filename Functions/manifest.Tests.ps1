Import-Module StructuredResource -Force

InModuleScope StructuredResource {

Describe Get-ModuleManifestPath {
    $m = Get-Module StructuredResource
    It 'returns path' {
        $r = $m | Get-ModuleManifestPath
        $r | Should -Match 'StructuredResource\\StructuredResource\.psd1$'
    }
}

Describe Get-ModuleManifest {
    $m = Get-Module StructuredResource
    It 'returns hashtable' {
        $r = $m | Get-ModuleManifest
        $r | Should -BeOfType ([hashtable])
    }
}
}