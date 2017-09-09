Import-Module StructuredDscResourceCheck -Force

Describe 'Public API' {
    $commands = Get-Command -Module StructuredDscResourceCheck
    It 'exports some functions...' {
        $commands | measure | % Count | Should beGreaterThan 1
    }
    It '...but not too many' {
        $commands | measure | % Count | Should beLessThan 10
    }
    Context 'help' {
        foreach ( $command in $commands )
        {
            Context $command.Name {
                $help = $command | Get-Help
                It 'has a synopsis' {
                    $help.Synopsis | Should not match $command.Name
                }
                It 'has a description' {
                    $help.Description | Should not beNullOrEmpty
                }
                It 'parameter <n> has a description' -TestCases @(
                    $help.parameters.parameter | 
                        % { @{ n=$_.Name; p=$_ } }
                ) {
                    param($n,$p)
                    $p.Description | Should not beNullOrEmpty
                }
            }
        }
    }
}