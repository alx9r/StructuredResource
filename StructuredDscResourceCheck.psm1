$moduleRoot = Split-Path -Path $MyInvocation.MyCommand.Path

# dot source the .ps1 files
"$moduleRoot\Functions\*.ps1" |
    Get-Item |
    ? { $_.Name -notmatch 'Tests\.ps1$' } |
    % { . $_.FullName }
