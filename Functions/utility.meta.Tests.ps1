Import-Module StructuredResource -Force

InModuleScope StructuredResource {

Describe Get-ParameterText {
    function f { 
        param
        (
            $x,
            [Parameter(Mandatory,
                       ValueFromPipeline,
                       ValueFromPipelineByPropertyName,
                       Position = 1)]
            [AllowNull()]
            [string]
            $y
        )
    }
    $f = Get-Command f
    It 'returns basic text' {
        $r = $f | Get-ParameterAst x |
            Get-ParameterText

        $r | Should -BeOfType ([string])
        $r | Should -Be '$x'
    }
    It 'returns fully-loaded text' {
        $r = $f | Get-ParameterAst y |
            Get-ParameterText

        $r | Should -BeOfType ([string])
        $r | Should -Be @'
[Parameter(Mandatory,
                       ValueFromPipeline,
                       ValueFromPipelineByPropertyName,
                       Position = 1)]
            [AllowNull()]
            [string]
            $y
'@
    }
}

Describe New-Tester {
    function Get-Something { param($x,$y) }
    $c = Get-Command Get-Something
    Context 'basics' {
        It 'returns a new tester string' {
            $r = $c | New-Tester
            Write-Host $r
            $r | Should -BeOfType ([string])
        }
        It 'succeeds when interpreted as an expression' {
            $c | New-Tester | Invoke-Expression
        }
        It 'a tester function results' {
            $c | New-Tester | Invoke-Expression

            $r = Get-Item function:/Test-Something
            $r | Should -Not -BeNullOrEmpty
        }
    }
    Context 'behavior of resulting function' {
        $c | New-Tester | Invoke-Expression
        Mock Get-Something { 'something' } -Verifiable
        It 'returns exactly one boolean object' {
            $r = Test-Something -x 1 -y 2 -Value 'something'
            $r.Count | Should -Be 1
            $r | Should -BeOfType ([bool])
        }
        It 'returns true' {
            $r = Test-Something -x 1 -y 2 -Value 'something'
            $r | Should be $true
        }
        It 'returns false' {
            $r = Test-Something -x 1 -y 2 -Value 'something else'
            $r | Should be $false
        }
        It 'invokes getter' {
            Assert-MockCalled Get-Something 1 {
                $x -eq 1 -and
                $y -eq 2
            }
        }
    }
}
}