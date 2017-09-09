function Invoke-IntegrationTest
{
    param
    (
        [Parameter(Mandatory,
                   Position = 1)]
        [scriptblock]
        $Scriptblock,

        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [string]
        $ResourceName,

        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [string]
        $ModuleName,

        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [hashtable]
        $Arguments
    )
    process
    {
        $function = Get-PublicResourceFunction $ResourceName $ModuleName
        $structuredDscArgs = $function |
            Get-ParameterMetaData |
            New-StructuredArgs $Arguments
        $structuredDscArgs.CommandName = $function.Name

        try
        {
            $Scriptblock | Invoke-Scriptblock -NamedArgs $structuredDscArgs
        }
        catch
        {
            throw [System.Exception]::new(
                @"

ResourceName: $ResourceName
ModuleName: $ModuleName
StructuredArg: $($structuredDscArgs | ConvertTo-PsLiteralString)

"@,
                $_.Exception
            )
        }
    }
}
