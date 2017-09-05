function Invoke-PresenceTest
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
        $keys = $function |
            Get-ParameterMetaData |
            New-StructuredDscArgumentGroup Keys $Arguments

        try
        {
            $Scriptblock | Invoke-Scriptblock -NamedArgs @{
                Keys = $keys
                CommandName = $function.Name
            }
        }
        catch
        {
            throw [System.Exception]::new(
                @"

ResourceName: $ResourceName
ModuleName: $ModuleName
Keys: $($keys | ConvertTo-PsLiteralString)
CommandName: $($function.Name)

"@,
                $_.Exception
            )
        }
    }
}
