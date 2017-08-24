@(
    'testParamsType.ps1'
    'testStepType.ps1'
    'testInstructionsType.ps1'
) |
% { . "$($PSCommandPath | Split-Path -Parent)\$_" }
