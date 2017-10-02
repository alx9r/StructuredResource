function Get-ModuleAst
{
    param
    (
        [Parameter(Mandatory,
                   ValueFromPipeline)]
        [psmoduleinfo]
        $Module
    )
    process
    {
        $d = & {
            if ( $Module.Definition )
            {
                return $Module.Definition
            }

            if ( $Module | Get-Module | % Definition )
            {
                return $Module | Get-Module | % Definition
            }

            $module | Import-Module
            if ( $Module | Get-Module | % Definition )
            {
                return $Module | Get-Module | % Definition
            }
        }

        if ( $d )
        {
            return [scriptblock]::Create($d).Ast
        }

        throw "Definition for module $($Module.Name) not found."
    }
}

function Get-StatementAst
{
    param
    (
        [Parameter(Position = 1)]
        [string]
        $Filter,

        [switch]
        $ClassOnly,

        [Parameter(Mandatory,
                   ValueFromPipeline)]
        [System.Management.Automation.Language.NamedBlockAst]
        $Ast
    )
    process
    {
        $s = $Ast.Statements
        if ( $ClassOnly ) { $s = $s | ? {$_.IsClass} }
        if ( $Filter )    { $s = $s | ? {$_.Name -like $Filter} }
        $s
    }
}

function Get-FunctionMemberAst
{
    param
    (
        [Parameter(Position = 1)]
        [string]
        $Filter,

        [Parameter(Mandatory,
                   ValueFromPipeline)]
        [System.Management.Automation.Language.TypeDefinitionAst]
        $Ast
    )
    process
    {
        $m = $Ast.Members
        if ( $Filter ) { $m = $m | ? {$_.Name -like $Filter} }
        $m
    }
}
