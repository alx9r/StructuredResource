@(
    'testArgsType.ps1'
    'structuredResourceTestType.ps1'
    'testIdKindType.ps1'
) |
% { . "$($PSCommandPath | Split-Path -Parent)\$_" }
