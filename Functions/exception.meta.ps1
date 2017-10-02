function Assert-PipelineException
{
    param
    (
        [Parameter(Position=1)]
        [System.Object[]]
        $PositionalArgs = @(),

        [Parameter(Position=2)]
        [hashtable]
        $NamedArgs = @{},

        [Parameter(Position=3)]
        [object[]]
        $PipelineObject,

        [psmoduleinfo]
        $Module,

        [Parameter(Mandatory)]
        [string[]]
        $MatchMessage,

        [Parameter(ValueFromPipeline,
                   Mandatory)]
        [System.Management.Automation.CommandInfo]
        $CommandInfo
    )
    process
    {
        $invoker = @{
            $false = { $PipelineObject | &         $CommandInfo.Name @PositionalArgs @NamedArgs }
            $true  = { $PipelineObject | & $Module $CommandInfo.Name @PositionalArgs @NamedArgs }
        }.($PSBoundParameters.ContainsKey('Module'))

        # exercise the pipeline
        & $invoker | % { $excersized = $true }

        if ( -not $excersized )
        {
            throw "Command $($CommandInfo.Name) did not output to pipeline."
        }

        # throw a downstream exception
        try
        {
            & $invoker | % { throw 'downstream' }
        }
        catch
        {
            $threw = $true
            $e = $_.Exception
        }

        if ( -not $threw )
        {
            throw "Command $($CommandInfo.Name) swallowed downstream exception."
        }

        if ( -not $e.InnerException )
        {
            throw "Command $($CommandInfo.Name) threw but no inner exception was found."
        }

        foreach ( $matcher in $MatchMessage )
        {
            if ( $e.Message -notmatch $matcher )
            {
                throw "Command $($CommandInfo.Name) threw wrong outer exception.  Expected message `"$($e.Message)`" to match `"$matcher`""
            }
        }

        if ( $e.InnerException -notmatch 'downstream' )
        {
            throw "Command $($CommandInfo.Name) threw wrong inner exception."
        }
    }
}
