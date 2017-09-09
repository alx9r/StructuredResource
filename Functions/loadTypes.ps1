@(
    'testParamsType.ps1'
    'structuredResourceTestType.ps1'
    'structuredResourceTestCollectionType.ps1'
) |
% { . "$($PSCommandPath | Split-Path -Parent)\$_" }
