function Get-ParameterAst
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
        $parameters = $FunctionInfo.ScriptBlock.Ast.Body.ParamBlock.Parameters
        if ( -not $ParameterName )
        {
            return $parameters
        }
        $parameters.Where({$_.Name.VariablePath.UserPath -eq $ParameterName})
    }
}