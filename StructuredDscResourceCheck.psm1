$moduleRoot = Split-Path -Path $MyInvocation.MyCommand.Path

# load the type files...
. "$moduleRoot\Functions\LoadTypes.ps1"

# ...and then the remaining .ps1 files
"$moduleRoot\Functions\*.ps1",
"$moduleRoot\TestResourceFunctions\*.ps1",
"$moduleRoot\External\*.ps1" |
    Get-Item |
    ? {
        $_.Name -notmatch 'Tests\.ps1$' -and
        $_.Name -notmatch 'Types?\.ps1$'
    } |
    % { . $_.FullName }

# dot source the .ps1 files
"$moduleRoot\Functions\*.ps1" |
    Get-Item |
    ? { $_.Name -notmatch 'Tests\.ps1$' } |
    % { . $_.FullName }


# export public functions
Export-ModuleMember @(
    'New-StructuredArguments'
    'Invoke-StructuredResource'
    'New-StructuredResourceTest'
    'Invoke-StructuredResourceTest'
)