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
    Mock Get-ModuleManifestPath { 'some_path' } -Verifiable
    Mock Get-Content {'@{','x=1','}'} -Verifiable
    Context 'success' {
        It 'returns hashtable' {
            $r = $m | Get-ModuleManifest
            $r | Should -BeOfType ([hashtable])
        }
        It 'invokes commands' {
            Assert-MockCalled Get-ModuleManifestPath 1 {
                $ModuleInfo.Name -eq 'StructuredResource'
            }
            Assert-MockCalled Get-Content 1 {
                $Path -eq 'some_path'
            }
        }
    }
    It 'exception' {
        Get-Command Get-ModuleManifest |
            Assert-PipelineException -Pipe $m -Match 'StructuredResource','some_path'
    }
}
}
