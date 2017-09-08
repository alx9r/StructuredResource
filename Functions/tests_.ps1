function Get-Tests
{
@{
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
        Message = 'Each public resource class has properties with the [DscProperty()] attibute.'
        Prerequisites = 'T005'
    }
    'PR.2' = @{
        Message = 'Ensure public resource property.'
        Prerequisites = 'T010','T011','T012'
    }
    T010 = @{
        Message = 'Public resource class''s Ensure property has [DscProperty()] attribute.'
        Prerequisites = 'T001'
        Scriptblock = { $_ | Get-NestedModuleType | Get-MemberProperty 'Ensure' | Assert-PropertyCustomAttribute DscProperty }
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
    'PR.4' = @{
        Message = 'Mode public resource parameter.'
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
        Scriptblock = { $_ | Get-PublicResourceFunction | Get-ParameterMetaData 'Mode' | Assert-ParameterMandatory }
    }
    T016 = @{
        Message = 'Public resource function Mode parameter is of type [Mode].'
        Prerequisites = 'T014'
        Scriptblock = { $_ | Get-PublicResourceFunction | Get-ParameterMetaData 'Mode' | Get-ParameterType | Assert-Type ([Mode]) }
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
        Scriptblock = { $_ | Get-PublicResourceFunction | Get-ParameterAst 'Mode' | Assert-ParameterDefault -NoDefault }
    }
    'PR.5' = @{
        Message = 'Ensure public resource parameter.'
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
        Scriptblock = { $_ | Get-PublicResourceFunction | Get-ParameterMetaData 'Ensure' | Assert-ParameterOptional}
    }
    T023 = @{
        Message = 'Public resource function Ensure parameter is of type [Ensure]'
        Prerequisites = 'T021'
        Scriptblock = { $_ | Get-PublicResourceFunction | Get-ParameterMetaData 'Ensure' | Get-ParameterType | Assert-Type ([Ensure]) }
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
        Scriptblock = { $_ | Get-PublicResourceFunction | Get-ParameterAst 'Ensure' | Assert-ParameterDefault 'Present' }
    }
    'PR.6' = @{
        Message = 'No public resource parameters bind to pipeline value.'
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
                Select-Parameter -Not Common | 
                Assert-ParameterAttribute ValueFromPipelineByPropertyName $true
        }
    }
    'PR.8' = @{
        Message = 'No Mode public resource property.'
        Prerequisites = 'T002'
        Scriptblock = { $_ | Get-NestedModuleType | Assert-MemberProperty -Not 'Mode' }
    }
    'PR.9' = @{
        Message = 'Each public resource parameter is statically-typed.'
        Prerequisites = 'T006'
        Scriptblock = { 
            $_ | 
                Get-PublicResourceFunction | 
                Get-ParameterMetaData |
                Select-Parameter -Not Common |
                Get-ParameterType |
                Assert-Type -Not ([System.Object])
        }
    }
    'PR.10' = @{
        Message = 'Optional public resource parameters cannot be [string]'
        Prerequisites = 'T006'
        Scriptblock = { 
            $_ | 
                Get-PublicResourceFunction | 
                Get-ParameterMetaData | 
                Select-Parameter -Not Common |
                ? { $_ | Test-ParameterAttribute Mandatory $false } |
                Get-ParameterType |
                Assert-Type -not ([string])
        }
    }
    'PR.11' = @{
        Message = 'Optional value-type public resource parameters must be `[Nullable[T]]`.'
        Prerequisites = 'T028'
    }
    T028 = @{
        Message = 'Optional public resource parameters must be nullable.'
        Prerequisites = 'T006'
        Scriptblock = { 
            $_ | 
                Get-PublicResourceFunction | 
                Get-ParameterMetaData | 
                Select-Parameter -Not Common |
                ? { $_.Name -ne 'Ensure' }
                ? { $_ | Test-ParameterAttribute Mandatory $false } |
                Get-ParameterType | 
                Assert-NullableType }
    }
    'PR.13' = @{
        Message = 'Optional value-type public resource properties must be `[Nullable[T]]`.'
        Prerequisites = 'T029'
    }
    T029 = @{
        Message = 'Optional public resource properties must be nullable.'
        Prerequisites = 'T002'
        Scriptblock = {
            $_ |
                Get-NestedModuleType | 
                Get-MemberProperty |
                ? { $_.Name -ne 'Ensure' }
                ? { -not ($_ | Test-DscPropertyRequired) } |
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
        Message = 'Each public resource property has a corresponding public resource parameter.'
        Prerequisites = 'T002','T006'
        Scriptblock = {
            $function = $_ | Get-PublicResourceFunction
            $_ | Get-NestedModuleType | Get-MemberProperty |
                % { $function | Assert-Parameter $_.Name }
        }
    }
    'PR.16' = @{
        Message =  'Each public resource parameter has a corresponding public resource property.'
        Prerequisites = 'T002','T006'
        Scriptblock = { 
            $type = $_ | Get-NestedModuleType
            $_ | Get-PublicResourceFunction | 
                Get-ParameterMetaData |
                Select-Parameter -Not Common |
                ? { $_.Name -ne 'Mode' } |
                % { $type | Assert-MemberProperty $_.Name }        
        }
    }
    'PR.17' = @{
        Message = 'Defaults values match for corresponding public resource properties and parameters.'
        Prerequisites = 'T002','T006'
        Scriptblock = {
            $function = $_ | Get-PublicResourceFunction
            $type = $_ | Get-NestedModuleType
            $type | Get-MemberProperty |
                % { 
                    $function | 
                        Get-ParameterAst $_.Name |
                        Assert-ParameterDefault ($type | Get-PropertyDefault $_.Name )
                }
        }
    }
    'PR.18' = @{
        Message = 'Types match for corresponding public resource properties and parameters.'
        Prerequisites = 'T002','T006'
        Scriptblock = {
            $function = $_ | Get-PublicResourceFunction
            $_ | Get-NestedModuleType | 
                Get-MemberProperty |
                % { 
                    $function | 
                        Get-ParameterMetaData $_.Name |
                        Get-ParameterType |
                        Assert-Type ($_ | Get-PropertyType)
                }
        }
    }
    'PR.19' = @{
        Message = 'Mandatoriness matches for corresponding public resource properties and parameters.'
        Prerequisites = 'T002','T006'
        Scriptblock = {
            $function = $_ | Get-PublicResourceFunction
            $_ | Get-NestedModuleType | 
                Get-MemberProperty |
                % {
                    $assertion = @{
                        $true = 'Assert-ParameterMandatory'
                        $false = 'Assert-ParameterOptional'
                    }.([bool]($_ | Test-DscPropertyRequired))
                    $function | 
                        Get-ParameterMetaData $_.Name |
                        & $assertion        
                }
        }
    }
    'C.1' = @{
        Message = 'A resource can be set absent.'
        Prerequisites = 'PR.19'
        Scriptblock = {
            $_ | Invoke-IntegrationTest {
                param($CommandName,$Keys,$Hints,$Properties)
                & $CommandName Set Absent @Keys
                & $CommandName Test Absent @Keys | Assert-Value $true
            }
        }
    }
    'C.2' = @{
        Message = 'An absent resource can be added.'
        Prerequisites = 'C.1'
        Scriptblock = {
            $_ | Invoke-IntegrationTest {
                param($CommandName,$Keys,$Hints,$Properties)
                & $CommandName Set Absent @Keys
                & $CommandName Set Present @Keys @Hints
                & $CommandName Test Present @Keys | Assert-Value $true
            }
        }
    }
    'C.3' = @{
        Message = 'A present resource can be removed.'
        Prerequisites = 'C.2'
        Scriptblock = {
            $_ | Invoke-IntegrationTest {
                param($CommandName,$Keys,$Hints,$Properties)
                & $CommandName Set Absent @Keys
                & $CommandName Set Present @Keys @Hints
                & $CommandName Set Absent @Keys
                & $CommandName Test Absent @Keys | Assert-Value $true
            }
        }
    }
    'C.4' = @{
        Message = 'A present resource tests false for absence.'
        Prerequisites = 'C.2'
        Scriptblock = {
            $_ | Invoke-IntegrationTest {
                param($CommandName,$Keys,$Hints,$Properties)
                & $CommandName Set Absent @Keys
                & $CommandName Set Present @Keys @Hints
                & $CommandName Test Absent @Keys | Assert-Value $false
            }
        }
    }
    'C.5' = @{
        Message = 'An absent resource tests false for presence.'
        Prerequisites = 'C.1','C.3'
    }
    T030 = @{
        Message = 'An absent resource tests false for presence.'
        Prerequisites = 'C.5'
        Scriptblock = {
                $_ | Invoke-IntegrationTest {
                param($CommandName,$Keys,$Hints,$Properties)
                & $CommandName Set Absent @Keys
                & $CommandName Test Present @Keys | Assert-Value $false
            }
        }
    }
    T031 = @{
        Message = 'An absent resource tests false for presence after adding and removing it.'
        Prerequisites = 'C.5'
        Scriptblock = {
            $_ | Invoke-IntegrationTest {
                param($CommandName,$Keys,$Hints,$Properties)
                & $CommandName Set Absent @Keys
                & $CommandName Set Present @Keys @Hints
                & $CommandName Set Absent @Keys
                & $CommandName Test Present @Keys | Assert-Value $false
            }
        }
    }
    'C.6' = @{
        Message = 'Properties can be set after construction.'
        Prerequisites = 'C.2'
        Scriptblock = {
            $_ | Invoke-IntegrationTest {
                param($CommandName,$Keys,$Hints,$Properties)
                & $CommandName Set Absent @Keys
                & $CommandName Set Present @Keys @Hints
                & $CommandName Set Present @Keys @Properties
                & $CommandName Test Present @Keys @Properties | Assert-Value $true
            }            
        }
    }
    'C.7' = @{
        Message = 'A property can be set on construction.'
        Prerequisites = 'C.2'
        Scriptblock = {
            $_ | Invoke-IntegrationTest {
                param($CommandName,$Keys,$Hints,$Properties)
                & $CommandName Set Absent @Keys
                & $CommandName Set Present @Keys @Properties
                & $CommandName Test Present @Keys @Properties | Assert-Value $true
            }
        }
    }
}
}