Get-Command Test-Path |
    New-Asserter 'Item described at path $Path does not exist.' |
    Invoke-Expression