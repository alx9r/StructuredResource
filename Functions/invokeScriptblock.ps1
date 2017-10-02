function Invoke-Scriptblock
{
    [CmdletBinding(DefaultParameterSetName = 'arguments')]
    param
    (
        [Parameter(ParameterSetName = 'arguments',
                   Position = 1,
                   ValueFromPipelineByPropertyName)]
        [System.Object[]]
        $PositionalArgs=@(),

        [Parameter(ParameterSetName = 'arguments',
                   Position = 2,
                   ValueFromPipelineByPropertyName)]
        [hashtable]
        $NamedArgs=@{},

        [Parameter(ParameterSetName = 'pipeline',
                   ValueFromPipelineByPropertyName)]
        [System.Object[]]
        $PipelineObjects,

        [Parameter(Mandatory,
                   ValueFromPipeline,
                   ValueFromPipelineByPropertyName)]
        [scriptblock]
        $Scriptblock
    )
    process
    {
        if ( $PSCmdlet.ParameterSetName -eq 'pipeline' )
        {
            $PipelineObjects | % $Scriptblock
            return
        }
        & $Scriptblock @PositionalArgs @NamedArgs
    }
}
