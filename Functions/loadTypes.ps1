@(
    'testParamsType.ps1'
    'structuredResourceTestType.ps1'
    'testInstructionsType.ps1'
) |
% { . "$($PSCommandPath | Split-Path -Parent)\$_" }
