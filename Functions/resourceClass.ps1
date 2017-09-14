function Get-NestedModuleType
{
    [CmdletBinding()]
    param
    (
        [Parameter(Position = 1,
                   ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName = $true,
                   Mandatory = $true)]
        [Alias('ResourceName')]
        [string]
        $NestedName,

        [Parameter(Position = 2,
                   ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName = $true,
                   Mandatory = $true)]
        [Alias('ModuleName','ParentName')]
        [string]
        $Name
    )
    process
    {
        Get-NestedModule @PSBoundParameters |
            Get-TypeFromModule $NestedName
    }
}

function Assert-NestedModuleType
{
    [CmdletBinding()]
    param
    (
        [Parameter(Position = 1,
                   ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName = $true,
                   Mandatory = $true)]
        [Alias('ResourceName')]
        [string]
        $NestedName,

        [Parameter(Position = 2,
                   ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName = $true,
                   Mandatory = $true)]
        [Alias('ModuleName','ParentName')]
        [string]
        $Name
    )
    process
    {
        if ( Get-NestedModuleType @PSBoundParameters )
        {
            return
        }

        throw "Type $NestedName not found in module $NestedName."
    }
}


function New-NestedModuleInstance
{
    [CmdletBinding()]
    param
    (
        [Parameter(Position = 1,
                   ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName = $true,
                   Mandatory = $true)]
        [Alias('ResourceName')]
        [string]
        $NestedName,

        [Parameter(Position = 2,
                   ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName = $true,
                   Mandatory = $true)]
        [Alias('ModuleName','ParentName')]
        [string]
        $Name
    )
    process
    {
        Get-NestedModule @PSBoundParameters |
            New-ObjectFromModule $NestedName
    }
}

function Assert-NestedModuleInstance
{
    [CmdletBinding()]
    param
    (
        [Parameter(Position = 1,
                   ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName = $true,
                   Mandatory = $true)]
        [Alias('ResourceName')]
        [string]
        $NestedName,

        [Parameter(Position = 2,
                   ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName = $true,
                   Mandatory = $true)]
        [Alias('ModuleName','ParentName')]
        [string]
        $Name
    )
    process
    {
        if ( New-NestedModuleInstance @PSBoundParameters )
        {
            return
        }
        
        throw "Could not create object of type $NestedName from module $NestedName."
    }
}


function Get-DscResourceAttribute
{
    [CmdletBinding()]
    param
    (
        [Parameter(Position = 1,
                   ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName = $true,
                   Mandatory = $true)]
        [string]
        $ResourceName,

        [Parameter(Position = 2,
                   ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName = $true)]
        [string]
        $ModuleName
    )
    process
    {
        Get-NestedModule @PSBoundParameters |
            Get-TypeFromModule $ResourceName |
            % CustomAttributes | 
            ? {$_.AttributeType.Name -eq 'DscResourceAttribute' }
    }    
}

function Assert-DscResourceAttribute
{
    [CmdletBinding()]
    param
    (
        [Parameter(Position = 1,
                   ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName = $true,
                   Mandatory = $true)]
        [string]
        $ResourceName,

        [Parameter(Position = 2,
                   ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName = $true)]
        [string]
        $ModuleName
    )
    process
    {
        if ( -not (Get-DscResourceAttribute @PSBoundParameters) )
        {
            throw "[DscResource()] attribute not found on type $ResourceName in module $ModuleName."
        }
    }
}

function Assert-ResourceClassMethodBody
{
    param
    (
        [Parameter(Mandatory,
                   Position=1)]
        [Mode]
        $MethodName,

        [Parameter(Mandatory,
                   ValueFromPipeline)]
        [System.Management.Automation.Language.TypeDefinitionAst]
        $Ast
    )
    process
    {
        $s = $Ast | Get-FunctionMemberAst $MethodName | % Body | % Endblock | % Statements

        $fn = $Ast.Name | Get-PublicResourceFunctionCommandName

        $expectation = @{
            [Mode]::Test = "  Expected something like `"[bool] Test () { return `$this | $fn Test }`" in public resource class $($Ast.Name)."
            [Mode]::Set  = "  Expected something like `"[void] Set () { `$this | $fn Set }`" in public resource class $($Ast.Name)."
        }.$MethodName

        if ( ($s | measure | % Count) -ne 1 )
        {
            throw "Expected exactly one statement in method $MethodName."+$expectation
        }

        $pipelineElements = @{
            [Mode]::Test = $s.Pipeline.PipelineElements
            [Mode]::Set = $s.PipelineElements
        }.$MethodName

        if ( 'this' -ne $pipelineElements[0].Expression.VariablePath.UserPath )
        {
            throw "Missing `$this in pipeline for method $MethodName."+$expectation
        }

        if ( $fn -ne $pipelineElements[1].CommandElements[0].Value )
        {
            throw "Missing call to public resource function name $fn."+$expectation
        }

        if ( $null -eq $pipelineElements[1].CommandElements[1] )
        {
            throw "Missing mode parameter after function name $fn."+$expectation
        }

        $actual = $pipelineElements[1].CommandElements[1].Value            
        if ( $MethodName -ne $actual )
        {
            throw "Incorrect mode parameter after function name.  Expected $MethodName, found $actual."
        }
    }
}