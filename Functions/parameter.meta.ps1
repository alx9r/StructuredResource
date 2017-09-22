function Get-ParameterMetaData
{
    [CmdletBinding()]
    param
    (
        [Parameter(Position = 1)]
        [string]
        $ParameterName,
        
        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true)]
        [System.Management.Automation.FunctionInfo]
        $FunctionInfo
    )
    process
    {
        if ( $null -eq $FunctionInfo.Parameters )
        {
            return
        }
        if ( -not $ParameterName )
        {
            return $FunctionInfo.Parameters.get_Values()
        }
        if ( $ParameterName -notin $FunctionInfo.Parameters.get_Keys() )
        {
            return
        }
        $FunctionInfo.Parameters.get_Item($ParameterName)
    }
}