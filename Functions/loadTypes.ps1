@(
    'testParamsType.ps1'
    'structuredResourceTestType.ps1'
) |
% { . "$($PSCommandPath | Split-Path -Parent)\$_" }
