$tests = @{
    'PB.1' = @{
        Message = 'Each resource is published using a class with a [DscResource()] attribute.'
        Prerequisites = 'T004'
    }
    'L.1' = @{
        Message = 'Each public resource class is accessible in a nested module of its parent.'
        Prerequisites = 'T001'
    }
    T001 = @{
        Message = 'Get TypeInfo from nested module.'
        Prerequisites = 'T002'
        Scriptblock = { $_ | Assert-NestedModuleType }
    }
    T002 = @{
        Message = 'Get nested module from module.'
        Prerequisites = 'T003'
        Scriptblock = { $_ | Assert-NestedModule }
    }
    T003 = @{
        Message = 'Get module.'
        Prerequisites = 'T008'
        Scriptblock = { $_ | Assert-ModuleImported }
    }
    T004 = @{
        Message = 'Check for [DscResource()] attribute.'
        Prerequisites = 'T001'
        Scriptblock = { $_ | Assert-DscResourceAttribute }
    }
    'PB.2' = @{
        Message = 'Each public resource is accessible using Get-DscResource.'
        Prerequisites = 'T005'
    }
    T005 = @{
        Message = 'Get resource using Get-DscResource.'
        Prerequisites = 'T003'
        Scriptblock = { $_ | Assert-DscResource }
    }
    'PB.3' = @{
        Message = 'Each public resource has a corresponding public function.'
        Prerequisites = 'T006'
    }
    'PB.4' = @{
        Message = 'The function corresponding to public resource ResourceName is named Invoke-ProcessResourceName.'
        Prerequisites = 'T006'
    }
    T006 = @{
        Message = 'Get public resource function.'
        Scriptblock = { $_ | Assert-PublicResourceFunction }
        Prerequisites = 'T003'
    }
    T007 = @{
        Message = 'Confirm module exists.'
        Scriptblock = { $_ | Assert-ModuleExists }
    }
    T008 = @{
        Message = 'Import module.'
        Prerequisites = 'T007'
        Scriptblock = { Import-Module $_.ModuleName }
    }
    'PR.1' = @{
        Message = 'Each public resource class has member variables with the [DscProperty()] attibute.'
        Prerequisites = 'T009'
    }
    T009 = @{
        Message = 'Check for properties with [DscProperty()] attribute.'
        Prerequisites = 'T001'
        Scriptblock = { $_ | Get-NestedModuleType | Assert-HasDscProperty }
    }
    'PR.2' = @{
        Message = 'Public resource class''s Ensure member variable'
        Prerequisites = 'T010','T011','T012'
    }
    T010 = @{
        Message = 'Public resource class''s Ensure property has [DscProperty()] attribute.'
        Prerequisites = 'T001'
        Scriptblock = { $_ | Get-NestedModuleType | Assert-DscProperty 'Ensure' }
    }
    T011 = @{
        Message = 'Public resource class''s Ensure property is of type [Ensure].'
        Prerequisites = 'T001'
        Scriptblock = { $_ | Get-NestedModuleType | Get-MemberProperty 'Ensure' | Get-PropertyType | Assert-Type ([Ensure]) }
    }
    T012 = @{
        Message = 'Public resource class''s Ensure property has default value "Present"'
        Prerequisites = 'T001'
        Scriptblock = { $_ | Get-NestedModuleType | Assert-PropertyDefault 'Ensure' 'Present' }
    }
    'PR.3' = @{
        Message = 'Other member variables of public resource classes have no default value.'
        Prerequisites = 'T013'
    }
    T013 = @{
        Message = 'DSC properties other than "Ensure" have no default value.'
        Prerequisites = 'T001'
        Scriptblock = { $_ | Get-NestedModuleType | Assert-NullDscPropertyDefaults -Exclude 'Ensure' }
    }
    'PR.4' = @{
        Message = 'Public resource function Mode parameter.'
        Prerequisites = 'T014','T015','T016','T017','T018','T019','T020'
    }
    T014 = @{
        Message = 'Public resource function has Mode parameter.'
        Prerequisites = 'T006'
        Scriptblock = { $_ | Get-PublicResourceFunction | Assert-Parameter 'Mode' }
    }
    T015 = @{
        Message = 'Public resource function Mode parameter is mandatory.'
        Prerequisites = 'T014'
        Scriptblock = { $_ | Get-PublicResourceFunction | Get-ParameterMetaData 'Mode' | Assert-FunctionParameterMandatory }
    }
    T016 = @{
        Message = 'Public resource function Mode parameter is of type [Mode].'
        Prerequisites = 'T014'
        Scriptblock = { $_ | Get-PublicResourceFunction | Get-ParameterMetaData 'Mode' | Get-FunctionParameterType | Assert-Type ([Mode]) }
    }
    T017 = @{
        Message = 'Public resource function Mode parameter is a positional argument.'
        Prerequisites = 'T014'
        Scriptblock = { $_ | Get-PublicResourceFunction | Get-ParameterMetaData 'Mode' | Assert-ParameterPositional }
    }
    T018 = @{
        Message = 'Public resource function Mode parameter is in position 1.'
        Prerequisites = 'T017'
        Scriptblock = { $_ | Get-PublicResourceFunction | Get-ParameterMetaData 'Mode' | Assert-ParameterPosition 1 }
    }
    T019 = @{
        Message = 'Public resource function Mode parameter is the first positional argument.'
        Prerequisites = 'T017'
        Scriptblock = { 
            $_ | Get-PublicResourceFunction | 
                Get-ParameterMetaData | 
                Select-OrderedParameters | 
                Assert-ParameterOrdinality 'Mode' 0 
        }
    }
    T020 = @{
        Message = 'Public resource function Mode parameter has no default value.'
        Prerequisites = 'T014'
        Scriptblock = { $_ | Get-PublicResourceFunction | Get-ParameterAst 'Mode' | Assert-FunctionParameterDefault -NoDefault }
    }
    'PR.5' = @{
        Message = 'Public resource function Ensure parameter.'
        Prerequisites = 'T021','T022','T023','T024','T025','T026','T027'
    }
    T021 = @{
        Message = 'Public resource function has Ensure parameter.'
        Prerequisites = 'T006'
        Scriptblock = { $_ | Get-PublicResourceFunction | Assert-Parameter 'Ensure' }
    }
    T022 = @{
        Message = 'Public resource function Ensure Parameter is optional.'
        Prerequisites = 'T021'
        Scriptblock = { $_ | Get-PublicResourceFunction | Get-ParameterMetaData 'Ensure' | Assert-FunctionParameterOptional}
    }
    T023 = @{
        Message = 'Public resource function Ensure parameter is of type [Ensure]'
        Prerequisites = 'T021'
        Scriptblock = { $_ | Get-PublicResourceFunction | Get-ParameterMetaData 'Ensure' | Get-FunctionParameterType | Assert-Type ([Ensure]) }
    }
    T024 = @{
        Message = 'Public resource function Ensure parameter is a positional argument.'
        Prerequisites = 'T021'
        Scriptblock = { $_ | Get-PublicResourceFunction | Get-ParameterMetaData 'Ensure' | Assert-ParameterPositional }
    }
    T025 = @{
        Message = 'Public resource function Ensure parameter is in position 2.'
        Prerequisites = 'T024'
        Scriptblock = { $_ | Get-PublicResourceFunction | Get-ParameterMetaData 'Ensure' | Assert-ParameterPosition 2 }
    }
    T026 = @{
        Message = 'Public resource function Ensure parameter is the second positional argument.'
        Prerequisites = 'T024'
        Scriptblock = {
            $_ | Get-PublicResourceFunction |
                Get-ParameterMetaData |
                Select-OrderedParameters |
                Assert-ParameterOrdinality 'Ensure' 1
        }
    }
    T027 = @{
        Message = 'Public resource function Ensure parameter has default value "Present".'
        Prerequisites = 'T021'
        Scriptblock = { $_ | Get-PublicResourceFunction | Get-ParameterAst 'Ensure' | Assert-FunctionParameterDefault 'Present' }
    }
    'PR.6' = @{
        Message = 'No public resource function parameters bind to pipeline value.'
        Prerequisites = 'T006'
        Scriptblock =  { $_ | Get-PublicResourceFunction | Get-ParameterMetaData | Assert-ParameterAttribute ValueFromPipeline $false }
    }
    'PR.7' = @{
        Message = 'Public resource parameters bind to pipeline object property values.'
        Prerequisites = 'T006'
        Scriptblock = { 
            $_ | 
                Get-PublicResourceFunction | 
                Get-ParameterMetaData | 
                Select-FunctionParameter -Not Common | 
                Assert-ParameterAttribute ValueFromPipelineByPropertyName $true
        }
    }
    'PR.8' = @{
        Message = 'A public resource class does not have have member variable Mode.'
        Prerequisites = 'T002'
        Scriptblock = { $_ | Get-NestedModuleType | Assert-MemberProperty -Not 'Mode' }
    }
    'PR.9' = @{
        Message = 'Each public resource function parameter is statically-typed.'
        Prerequisites = 'T006'
        Scriptblock = { 
            $_ | 
                Get-PublicResourceFunction | 
                Get-ParameterMetaData |
                Select-FunctionParameter -Not Common |
                Get-FunctionParameterType |
                Assert-Type -Not ([System.Object])
        }
    }
    'PR.10' = @{
        Message = 'Public resource function parameters cannot be [string]'
        Prerequisites = 'T006'
        Scriptblock = { 
            $_ | 
                Get-PublicResourceFunction | 
                Get-ParameterMetaData | 
                Select-FunctionParameter -Not Common |
                Get-FunctionParameterType |
                Assert-Type -not ([string])
        }
    }
    'PR.11' = @{
        Message = 'Public resource value-type parameters must be [Nullable[T]].'
        Prerequisites = 'T028'
    }
    T028 = @{
        Message = 'Public resource function parameters must be nullable.'
        Prerequisites = 'T006'
        Scriptblock = { 
            $_ | 
                Get-PublicResourceFunction | 
                Get-ParameterMetaData | 
                Select-FunctionParameter -Not Common | 
                ? { $_.Name -notin 'Ensure','Mode' } |
                Get-FunctionParameterType | 
                Assert-NullableType }
    }
    'PR.13' = @{
        Message = 'Public resource class value-type member variables must be [Nullable[T]]'
        Prerequisites = 'T029'
    }
    T029 = @{
        Message = 'Public resource class member variables must be nullable.'
        Prerequisites = 'T002'
        Scriptblock = {
            $_ |
                Get-NestedModuleType | 
                Get-MemberProperty |
                ? {$_.Name -ne 'Ensure' } |
                Get-PropertyType | 
                Assert-NullableType
        }
    }
    'PR.14' = @{
        Message = 'Public resource function parameters do not have the [AllowNull()] attribute.'
        Prerequisites = 'T006'
        Scriptblock = { 
            $_ |
                Get-PublicResourceFunction |
                Get-ParameterMetaData |
                Assert-ParameterAttribute 'AllowNull' $null    
        }
    }
    'PR.15' = @{
        Message = 'Each public resource class member variable has a corresponding public resource function parameter.'
        Prerequisites = 'T002'
        Scriptblock = {
            $function = $_ | Get-PublicResourceFunction
            $_ | Get-NestedModuleType | Get-MemberProperty |
                % { $function | Assert-Parameter $_.Name }
            }
    }
    'PR.16' = @{
        Message =  'Each public resource function parameter has a corresponding public resource class member variable.'
        Prerequisites = 'T002'
        Scriptblock = { 
            $type = $_ | Get-NestedModuleType
            $_ | Get-PublicResourceFunction | 
                Get-ParameterMetaData |
                Select-FunctionParameter -Not Common |
                ? { $_.Name -ne 'Mode' } |
                % { $type | Assert-MemberProperty $_.Name }        
        }
    }
}

function ConvertTo-DependencyGraph
{
    [CmdletBinding()]
    param
    (
        [Parameter(position = 1,
                   Mandatory = $true)]
        [hashtable]
        $Dependencies
    )
    $output = @{}
    foreach ( $key in $Dependencies.Keys )
    {
        $output.$key = $Dependencies.get_Item($key).Prerequisites
    }
    return $output
}

function Get-OrderedTestIds
{
    [CmdletBinding()]
    param
    (
        [Parameter(position = 1)]
        [hashtable]
        $Dependencies = $tests
    )

    ConvertTo-DependencyGraph $Dependencies | Invoke-SortGraph
}

function Get-OrderedSteps
{
    [CmdletBinding()]
    param
    (
        [Parameter(position = 1)]
        [hashtable]
        $Tests = $tests
    )
    Get-OrderedTestIds $Tests |
        % { 
            $step = New-Object TestStep -Property $Tests.get_Item($_)
            $step.ID = $_
            $step
        }
}