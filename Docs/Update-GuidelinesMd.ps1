Import-Module StructuredResource -Force
& (Get-Module StructuredResource) {
    . "$PSScriptRoot\helpers.ps1"

    New-GuidelinesMd |
        Set-Content "$PSScriptRoot\guidelines.md"
}
