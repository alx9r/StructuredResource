Import-Module StructuredResource -Force

InModuleScope StructuredResource {

Describe Assert-PipelineException {
    $sb = { Get-Command f | Assert-PipelineException -Match 'message' }
    It 'swallowed' {
        function f { try{1} catch{} }
        $sb | Should throw 'swallowed'
    }
    It 'did not output' {
        function f {}
        $sb | Should throw 'did not output'
    }
    It 'no inner exception' {
        function f {1}
        $sb | Should throw 'no inner exception'
    }
    It 'wrong outer exception' {
        function f {
            try {1}
            catch {
                throw [System.Exception]::new(
                    'wrong',
                    $_.Exception
                )
            }
        }
        $sb | Should throw 'wrong outer exception'
    }
    It 'wrong inner exception' {
        function f {
            try {1}
            catch {
                throw [System.Exception]::new(
                    'message',
                    [System.Exception]::new('inner')
                )
            }
        }
        $sb | Should throw 'wrong inner exception'
    }
    It 'success' {
        function f {
            try{1}
            catch
            {
                throw [System.Exception]::new(
                    'message',
                    $_.Exception
                )
            }
        }
        & $sb
    }
}
}
