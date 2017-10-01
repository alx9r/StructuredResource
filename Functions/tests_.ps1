function Get-TestIdKind
{
    param
    (
        [Parameter(Mandatory,
                   ValueFromPipeline)]
        [AllowNull()]
        [AllowEmptyString()]
        [string]
        $Id
    )
    process
    {
        if ( $Id -match '^T[0-9]{3}$' )
        {
            return [TestIdKind]::Test
        }
        if ( $Id -match '^[A-Z]{1,2}\.[0-9]+$' )
        {
            return [TestIdKind]::Guideline
        }
    }
}

function Get-TestIdNumber
{
    param
    (
        [Parameter(Mandatory,
                   ValueFromPipeline)]
        [AllowNull()]
        [AllowEmptyString()]
        $Id
    )
    process
    {
        [int]($Id |
            Select-String '^[A-Z]{1,2}\.?([0-9]+)$' |
            % { $_.Matches.Captures.Groups[1].Value })
    }
}

function Get-GuidelineGroup
{
    param
    (
        [Parameter(Mandatory,
                   ValueFromPipeline)]
        [AllowNull()]
        [AllowEmptyString()]
        [string]
        $Id
    )
    process
    {
        $Id | 
            Select-String '^([A-Z]{1,2})\.[0-9]+$' |
            % { $_.Matches.Captures.Groups[1].Value }
    }
}

Get-Command Get-TestIdKind | New-Tester | Invoke-Expression

function Get-Tests
{
@{
    'PB.1' = [StructuredResourceTestBase]@{
        Message = 'Each resource is published using a class with a `[DscResource()]` attribute.'
        Prerequisites = 'T004'
        Explanation = @'
This is as opposed to using MOF files to publish resources.

**Reason**

The particulars of the class can easily be tested using PowerShell.  Testing the same information in a MOF-based resource would require a parser for MOF files.
'@
    }
    'L.1' = [StructuredResourceTestBase]@{
        Message = 'Each public resource class is accessible in a nested module of its parent.'
        Prerequisites = 'T001'
        Explanation = @'
**Reason**

This is to simplify discovery of public resource classes by automated tests. Discovery of nested modules is trivial.
'@
    }
    'L.2' = [StructuredResourceTestBase]@{
        Message = 'Related public resources are published in a single parent module'
        Explanation = @'
**Reason**

Related resources usually share an amount of utility code.  Publishing related resources in a single parent module facilitates sharing a single copy of such utility code.

**Enforcement**

Invoke `Get-DscResource` for each of the related public resources and confirm that the module name is the parent module. 
'@
    }
    T001 = [StructuredResourceTestBase]@{
        Message = 'Get TypeInfo from nested module.'
        Prerequisites = 'T002'
        Scriptblock = { $_ | Assert-NestedModuleType }
    }
    T002 = [StructuredResourceTestBase]@{
        Message = 'Get nested module from module.'
        Prerequisites = 'T003'
        Scriptblock = { $_ | Assert-NestedModule }
    }
    T003 = [StructuredResourceTestBase]@{
        Message = 'Get module.'
        Prerequisites = 'T008'
        Scriptblock = { $_ | Assert-ModuleImported }
    }
    T004 = [StructuredResourceTestBase]@{
        Message = 'Check for [DscResource()] attribute.'
        Prerequisites = 'T001'
        Scriptblock = { $_ | Assert-DscResourceAttribute }
    }
    'PB.2' = [StructuredResourceTestBase]@{
        Message = 'Each public resource is accessible using Get-DscResource.'
        Prerequisites = 'T005'
        Explanation = @'
**Reason**

There might be subtle differences between the public resource class and the resultant object produced by PowerShell/WMF. Accessing the resultant object from `Get-DscResource` enables testing public resource properties as interpreted by PowerShell/WMF.
'@
    }
    T005 = [StructuredResourceTestBase]@{
        Message = 'Get resource using Get-DscResource.'
        Prerequisites = 'T004','T038'
        Scriptblock = { $_ | Assert-DscResource }
    }
    T037 = [StructuredResourceTestBase]@{
        Message = 'There is a module manifest.'
        Scriptblock = {
            Get-Module $_.ModuleName |
                Get-ModuleManifestPath |
                Assert-Path
        }
    }
    T038 = [StructuredResourceTestBase]@{
        Message = 'The module manifest has a DscResourcesToExport entry.'
        Prerequisites = 'T037'
        Scriptblock = {
            Get-Module $_.ModuleName |
                Get-ModuleManifest |
                Assert-HashtableKey DscResourcesToExport
        }
    }
    T039 = [StructuredResourceTestBase]@{
        Message = 'The module manifest DscResourcesToExport entry is *.'
        Prerequisites = 'T038'
        Scriptblock = {
            Get-Module $_.ModuleName |
                Get-ModuleManifest |
                Assert-HashtableItem DscResourcesToExport '*'
        }
    }
    'PB.3' = [StructuredResourceTestBase]@{
        Message = 'Each public resource has a corresponding public function.'
        Prerequisites = 'T006'
        Explanation = @'
**Reason**

Functions are more easily tested than classes.  Exposing a public function that is also invoked by the resource facilitates isolated testing.
'@
    }
    'PB.4' = [StructuredResourceTestBase]@{
        Message = 'The function corresponding to public resource ResourceName is named Invoke-ResourceName.'
        Prerequisites = 'T006'
        Explanation = @'
**Reason**

This is to simplify discovery of the public function from the public resource class and vice versa.
'@
    }
    'PB.5' = [StructuredResourceTestBase]@{
        Message = 'The module is output by `Get-Module -ListAvailable`'
        Explanation = @'
**Reason**

This simplifies testing because the module and its DSC resources are accessed by name alone.
'@
    }
    T006 = [StructuredResourceTestBase]@{
        Message = 'The public resource function exists.'
        Scriptblock = { $_ | Assert-PublicResourceFunction }
        Prerequisites = 'T003'
    }
    T007 = [StructuredResourceTestBase]@{
        Message = 'Confirm module exists.'
        Scriptblock = { $_ | Assert-ModuleExists }
    }
    T008 = [StructuredResourceTestBase]@{
        Message = 'Import module.'
        Prerequisites = 'T007'
        Scriptblock = { Import-Module $_.ModuleName }
    }
    'PR.1' = [StructuredResourceTestBase]@{
        Message = 'Each public resource class has properties with the `[DscProperty()]` attibute.'
        Prerequisites = 'T005'
        Explanation = @'
**Reason**

Parameters are passed to class-based resources via public resource class properties with the `[DscProperty()]` attribute.  A resource must have at least one such property.
'@
    }
    'PR.2' = [StructuredResourceTestBase]@{
        Message = 'Ensure public resource property.'
        Prerequisites = 'T010','T011','T012'
        Explanation = @'
A public resource class has an optional `Ensure` property.  It is of type `[Ensure]` and has default value `Present`.

**Reason**

The name `Ensure` should only be used to specify whether a resource is present or absent because that is its customary meaning in PowerShell DSC. `Ensure` is of type `[Ensure]` so that it can only take the values `Present` and `Absent`.  `Ensure` has default value `Present` because omitting `Ensure` should cause the resource to ensure presence.
'@
    }
    'PR.3' = [StructuredResourceTestBase]@{
        Message = '<del>PR.3: Other public resource properties have no default value</del>'
        Explanation = @'
**Reason**

<del>Omitting optional parameters means the configuration affected by the parameter should remain unchanged.  A default value for a public resource property defeats that behavior because the configuration gets set to the default value when the parameter is omitted.</del>

This rule was removed because a resource author could reasonably opt that an omitted value should change the affected configuration to a default value.  A user can still override such behavior by specifying `$null` for such a parameter thereby preventing any change to the affected configuration.
'@
    }
    T010 = [StructuredResourceTestBase]@{
        Message = 'Public resource class''s Ensure property has [DscProperty()] attribute.'
        Prerequisites = 'T001'
        Scriptblock = { $_ | Get-NestedModuleType | Get-MemberProperty 'Ensure' | Assert-PropertyCustomAttribute DscProperty }
    }
    T011 = [StructuredResourceTestBase]@{
        Message = 'Public resource class''s Ensure property is of type [Ensure].'
        Prerequisites = 'T001'
        Scriptblock = { $_ | Get-NestedModuleType | Get-MemberProperty 'Ensure' | Get-PropertyType | Assert-Type ([Ensure]) }
    }
    T012 = [StructuredResourceTestBase]@{
        Message = 'Public resource class''s Ensure property has default value "Present"'
        Prerequisites = 'T001'
        Scriptblock = { 
            $_ | 
                Get-NestedModuleType | 
                ? { $_ | Test-MemberProperty 'Ensure' } |
                Assert-PropertyDefault 'Ensure' 'Present' }
    }
    T034 = [StructuredResourceTestBase]@{
        Message = 'Public resource function has parameters'
        Prerequisites = 'T006'
        Scriptblock = {
            $r = $_ | 
                Get-PublicResourceFunction | 
                Get-ParameterMetaData |
                measure |
                % Count
            if ( $r -lt 1 )
            {
                throw 'no parameters found'
            }
        }
    }
    'PR.4' = [StructuredResourceTestBase]@{
        Message = 'Mode public resource parameter.'
        Prerequisites = 'T014','T015','T016','T017','T018','T019','T020','T034'
        Explanation = @'
Each public resource function has a mandatory `Mode` parameter.  The `Mode` parameter is of type `[Mode]`.  `Mode` is the first positional argument and does not have a default value.

**Reason**

The mode parameter is required to select between `Test` and `Set`.  It is of type `[Mode]` to restrict its values to `Set` and `Test`. Because it is mandatory, a default value has no use.  `Mode` is the first positional argument to support readability at call sites (e.g. `Invoke-Resource Test`).
'@
    }
    T014 = [StructuredResourceTestBase]@{
        Message = 'Public resource function has Mode parameter.'
        Prerequisites = 'T006'
        Scriptblock = { $_ | Get-PublicResourceFunction | Assert-Parameter 'Mode' }
    }
    T015 = [StructuredResourceTestBase]@{
        Message = 'Public resource function Mode parameter is mandatory.'
        Prerequisites = 'T014'
        Scriptblock = { $_ | Get-PublicResourceFunction | Get-ParameterMetaData 'Mode' | Assert-ParameterMandatory }
    }
    T016 = [StructuredResourceTestBase]@{
        Message = 'Public resource function Mode parameter is of type [Mode].'
        Prerequisites = 'T014'
        Scriptblock = { $_ | Get-PublicResourceFunction | Get-ParameterMetaData 'Mode' | Get-ParameterType | Assert-Type ([Mode]) }
    }
    T017 = [StructuredResourceTestBase]@{
        Message = 'Public resource function Mode parameter is a positional argument.'
        Prerequisites = 'T014'
        Scriptblock = { $_ | Get-PublicResourceFunction | Get-ParameterMetaData 'Mode' | Assert-ParameterPositional }
    }
    T018 = [StructuredResourceTestBase]@{
        Message = 'Public resource function Mode parameter is in position 1.'
        Prerequisites = 'T017'
        Scriptblock = { $_ | Get-PublicResourceFunction | Get-ParameterMetaData 'Mode' | Assert-ParameterPosition 1 }
    }
    T019 = [StructuredResourceTestBase]@{
        Message = 'Public resource function Mode parameter is the first positional argument.'
        Prerequisites = 'T017'
        Scriptblock = { 
            $_ | Get-PublicResourceFunction | 
                Get-ParameterMetaData | 
                Select-OrderedParameters | 
                Assert-ParameterOrdinality 'Mode' 0 
        }
    }
    T020 = [StructuredResourceTestBase]@{
        Message = 'Public resource function Mode parameter has no default value.'
        Prerequisites = 'T014'
        Scriptblock = { $_ | Get-PublicResourceFunction | Get-ParameterAst 'Mode' | Assert-ParameterDefault -NoDefault }
    }
    'PR.5' = [StructuredResourceTestBase]@{
        Message = 'Ensure public resource parameter.'
        Prerequisites = 'T021','T022','T023','T024','T025','T026','T027','T034'
        Explanation = @'
Each public resource function has an optional `Ensure` parameter.  The `Ensure` parameter is of type `[Ensure]`.  `Ensure` is the second positional argument and has default value `Present`.

**Reason**

The name `Ensure` should only be used to specify whether a resource is present or absent because that is its customary meaning in PowerShell DSC.  `Ensure` is of type `[Ensure]` so that it can only take the values `Present` and `Absent`.  `Ensure` is the second positional argument to support readability at call sites (e.g. `Invoke-Resource Test Absent`).  `Ensure` has default value `Present` because omitting `Ensure` should cause the resource to ensure presence.
'@
    }
    T021 = [StructuredResourceTestBase]@{
        Message = 'Public resource function has Ensure parameter.'
        Prerequisites = 'T006'
        Scriptblock = { $_ | Get-PublicResourceFunction | Assert-Parameter 'Ensure' }
    }
    T022 = [StructuredResourceTestBase]@{
        Message = 'Public resource function Ensure Parameter is optional.'
        Prerequisites = 'T021'
        Scriptblock = { $_ | Get-PublicResourceFunction | Get-ParameterMetaData 'Ensure' | Assert-ParameterOptional}
    }
    T023 = [StructuredResourceTestBase]@{
        Message = 'Public resource function Ensure parameter is of type [Ensure]'
        Prerequisites = 'T021'
        Scriptblock = { $_ | Get-PublicResourceFunction | Get-ParameterMetaData 'Ensure' | Get-ParameterType | Assert-Type ([Ensure]) }
    }
    T024 = [StructuredResourceTestBase]@{
        Message = 'Public resource function Ensure parameter is a positional argument.'
        Prerequisites = 'T021'
        Scriptblock = { $_ | Get-PublicResourceFunction | Get-ParameterMetaData 'Ensure' | Assert-ParameterPositional }
    }
    T025 = [StructuredResourceTestBase]@{
        Message = 'Public resource function Ensure parameter is in position 2.'
        Prerequisites = 'T024'
        Scriptblock = { $_ | Get-PublicResourceFunction | Get-ParameterMetaData 'Ensure' | Assert-ParameterPosition 2 }
    }
    T026 = [StructuredResourceTestBase]@{
        Message = 'Public resource function Ensure parameter is the second positional argument.'
        Prerequisites = 'T024'
        Scriptblock = {
            $_ | Get-PublicResourceFunction |
                Get-ParameterMetaData |
                Select-OrderedParameters |
                Assert-ParameterOrdinality 'Ensure' 1
        }
    }
    T027 = [StructuredResourceTestBase]@{
        Message = 'Public resource function Ensure parameter has default value "Present".'
        Prerequisites = 'T021'
        Scriptblock = { $_ | Get-PublicResourceFunction | Get-ParameterAst 'Ensure' | Assert-ParameterDefault 'Present' }
    }
    'PR.6' = [StructuredResourceTestBase]@{
        Message = 'No public resource parameters bind to pipeline value.'
        Prerequisites = 'T006','T034'
        Explanation = @'
No public resource parameter should have the `ValueFromPipeline` attribute set.

**Reason**

This is to improve parameter binding predictability.  With `ValueFromPipeline` set it is difficult to predict which, if any, parameter a pipeline value will bind to. 
'@
        Scriptblock =  { 
            $_ |
                Get-PublicResourceFunction |
                Get-ParameterMetaData |
                Assert-ParameterAttribute ValueFromPipeline $false
        }
    }
    'PR.7' = [StructuredResourceTestBase]@{
        Message = 'Public resource parameters bind to pipeline object property values.'
        Prerequisites = 'T006','T034'
        Explanation = @'
Each public resource parameter should have the `ValueFromPipelineByPropertyName` attribute set.

**Reason**

This is to support binding of bulk parameters using objects.  In particular, it supports passing the values of member variables of a `[DscResource()]` object as arguments to the function (e.g. `$this | Invoke-Resource Set`).
'@
        Scriptblock = { 
            $_ | 
                Get-PublicResourceFunction | 
                Get-ParameterMetaData | 
                Select-Parameter -Not Common | 
                Assert-ParameterAttribute ValueFromPipelineByPropertyName $true
        }
    }
    'PR.8' = [StructuredResourceTestBase]@{
        Message = 'No Mode public resource property.'
        Prerequisites = 'T002'
        Explanation = @'
**Reason**

This is to avert confusion that might result when bulk-binding the values of a public resource properties to public resource parameters using the pipeline (e.g. `$this | Invoke-Resource`).  The correct value for `Mode` must be explicitly passed to the public resource function (e.g. "`Test`" in `Invoke-Resource Test`) on each invocation of the `Set()` and `Test()` methods.  The existence of a `Mode` property probably indicates an error.  That is, a resource author is probably incorrectly expecting `Mode` to be passed from a public resource property by the pipeline.
'@
        Scriptblock = { $_ | Get-NestedModuleType | Assert-MemberProperty -Not 'Mode' }
    }
    'PR.9' = [StructuredResourceTestBase]@{
        Message = 'Each public resource parameter is statically-typed.'
        Prerequisites = 'T006','T034'
        Explanation = @'
**Reason**

This is to help users understand what kind of object is expected for each parameter.
'@
        Scriptblock = { 
            $_ | 
                Get-PublicResourceFunction | 
                Get-ParameterMetaData |
                Select-Parameter -Not Common |
                Get-ParameterType |
                Assert-Type -Not ([System.Object])
        }
    }
    'PR.10' = [StructuredResourceTestBase]@{
        Message = 'Optional public resource parameters cannot be [string]'
        Prerequisites = 'T006','T034'
        Explanation = @'
**Reason**

This is to support compliance with PR.12 when a user omits a `[string]`.  Per PowerShell/PowerShell#4616, passing `$null` to a `[string]` parameter unconditionally causes conversion to `[string]::empty`.  This silently converts the meaning from "don't change" to "clear value" which is incorrect.  PowerShell only performs such a silent conversion from `$null` for `[string]`s.  To avoid this problem and still use static-typing you can use `[NullsafeString]` instead. 

Because PR.12 does not apply to mandatory parameters, this rule also does not apply to mandatory parameters.
'@
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
    'PR.11' = [StructuredResourceTestBase]@{
        Message = 'Optional value-type public resource parameters must be `[Nullable[T]]`.'
        Prerequisites = 'T028','T034'
        Explanation = @'
**Reason**

This is to support compliance with PR.12 when a user omits a value-type parameter.  Normal value-type parameters in .Net cannot be `$null`.

**Exceptions**

This rules does not apply to the `Ensure` public resource parameter because it cannot be null.
'@
    }
    'PR.12' = [StructuredResourceTestBase]@{
        Message = 'The meaning of null for an optional default-less public resource property or parameter is the same as omitting it.'
        Explanation = @'
**Reason**

Omission of an optional default-less parameter P means "don't change" P.  Such an omitted parameter takes the value `$null` while it is embodied as the value of a public resource property.  This is because there is no other built-in mechanism that means unbound, unspecified, or omitted for public resource properties.  Accordingly, all callees interpreting such a parameter must consider `$null` to mean "don't change".

This rule does not apply to mandatory parameters because they can neither be null (by PR.14) nor omitted (because they are mandatory).
'@
    }
    T028 = [StructuredResourceTestBase]@{
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
    'PR.13' = [StructuredResourceTestBase]@{
        Message = 'Optional value-type public resource properties must be `[Nullable[T]]`.'
        Prerequisites = 'T029'
        Explanation = @'
**Reason**

This is to support compliance with PR.11 when a user omits a value-type parameter.  Value-type parameters in .Net cannot be `$null`.

**Exception**

This rule does not apply to the `Ensure` public resource property.
'@
    }
    T029 = [StructuredResourceTestBase]@{
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
    'PR.14' = [StructuredResourceTestBase]@{
        Message = 'Public resource function parameters do not have the `[AllowNull()]` attribute.'
        Prerequisites = 'T006','T034'
        Explanation = @'
**Reason**

This is to support compliance with PR.11.  Mandatory public resource parameters are not permitted to be `$null` because the meaning of `$null` is the same as omission per PR.11.  `[AllowNull()]` does not affect non-mandatory parameters.  Therefore, `[AllowNull()]` on public resource parameters either indicates an error or is unnecessary.  Always omitting `[AllowNull()]` avoids errors with no downside.  
'@
        Scriptblock = { 
            $_ |
                Get-PublicResourceFunction |
                Get-ParameterMetaData |
                Assert-ParameterAttribute 'AllowNull' $null    
        }
    }
    'PR.15' = [StructuredResourceTestBase]@{
        Message = 'Each public resource property has a corresponding public resource parameter.'
        Prerequisites = 'T002','T006'
        Explanation = @'
**Reason**

This is to support parity between the interfaces published by the public resource class and public resource function.
'@
        Scriptblock = {
            $function = $_ | Get-PublicResourceFunction
            $_ | Get-NestedModuleType | Get-MemberProperty |
                % { $function | Assert-Parameter $_.Name }
        }
    }
    'PR.16' = [StructuredResourceTestBase]@{
        Message =  'Each public resource parameter has a corresponding public resource property.'
        Prerequisites = 'T002','T006','T034'
        Explanation = @'
**Reason**

This is to support parity between the interfaces published by the public resource class and public resource function.
'@
        Scriptblock = { 
            $type = $_ | Get-NestedModuleType
            $_ | Get-PublicResourceFunction | 
                Get-ParameterMetaData |
                Select-Parameter -Not Common |
                ? { $_.Name -ne 'Mode' } |
                % { $type | Assert-MemberProperty $_.Name }        
        }
    }
    'PR.17' = [StructuredResourceTestBase]@{
        Message = 'Defaults values match for corresponding public resource properties and parameters.'
        Prerequisites = 'T002','T006'
        Explanation = @'
**Reason**

This is to ensure the same behavior whether the resource is invoked using the public resource class or function.
'@
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
    'PR.18' = [StructuredResourceTestBase]@{
        Message = 'Types match for corresponding public resource properties and parameters.'
        Prerequisites = 'T002','T006'
        Explanation = @'
**Reason**

This is to ensure the same behavior whether the resource is invoked using the public resource class or function.
'@
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
    'PR.19' = [StructuredResourceTestBase]@{
        Message = 'Mandatoriness matches for corresponding public resource properties and parameters.'
        Prerequisites = 'T002','T006'
        Explanation = @'
**Reason**

This is to ensure the same behavior whether the resource is invoked using the public resource class or function.
'@
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
    'PR.20' = [StructuredResourceTestBase]@{
        Message = 'Public resource parameters that correspond to constructor properties are marked with an attribute.'
        Explanation = @'
**Reason**

This is so that libraries interpreting public resource parameters are able to correctly pass required properties to a resource's constructor.
'@
    }
    'PR.21' = [StructuredResourceTestBase]@{
        Message = 'Each public resource parameter whose corresponding public resource property bears `[DscProperty(Key)]` bears `[StructuredResource(''Key'')]`'
        Prerequisites = 'PR.15','PR.16'
        Explanation = @'
**Reason**

This is to ensure that libraries interpreting public resource parameters are able to correctly identify Key parameters.
'@
        Scriptblock = {
            $function = $_ | Get-PublicResourceFunction
            $_ | 
                Get-NestedModuleType | 
                Get-MemberProperty |
                ? {
                    $_ | 
                        Get-PropertyCustomAttribute DscProperty |
                        Test-CustomAttributeArgument Key $true
                } |
                % {
                    $r = $function |
                        Get-ParameterMetaData $_.Name |
                        Get-ParameterAttribute StructuredResource |
                        ? {$null -ne $_} |
                        Get-AttributeArgument ParameterType
                    if ( $r -ne 'Key' )
                    {
                        throw [System.Exception]::new(
                            "Parameter $($_.Name) does not bear the [StructuredResource('Key')] attribute",
                            $_.Exception
                        )
                    }
                }            
        }
    }
    T035 = [StructuredResourceTestBase]@{
        Message = 'Testing returns something.'
        Prerequisites = 'PR.21'
        Scriptblock = {
            $_ | Invoke-IntegrationTest {
                param($CommandName,$Keys,$Hints,$Properties)
                $r = & $CommandName Test Absent @Keys |
                    measure |
                    % Count
                if ( $r -lt 1 )
                {
                    throw 'test returned nothing'
                }
            }
        }
    }
    'I.1' = [StructuredResourceTestBase]@{
        Message = 'The module can be imported.'
        Explanation = @'
**Reason**

A module can be available using `Get-Module -ListAvailable` but fails on import.
'@
    }
    'I.2' = [StructuredResourceTestBase]@{
        Message = 'The module imported is the one under test.'
        Explanation = @'
**Reason**

Confusion can result during testing if PowerShell unexpectedly loads another available module (perhaps with a different version) with the same name.
'@
    }
    'I.3' = [StructuredResourceTestBase]@{
        Message = 'Each nested module containing a resource class can be imported.'
        Explanation = @'
**Reason**

The nested module must be imported to test the class inside it.
'@
    }
    'I.4' = [StructuredResourceTestBase]@{
        Message = 'Each imported nested module can be accessed using `Get-Module`.'
        Explanation = @'
**Reason**

This simplifies testing because the nested module can be accessed by name alone.
'@
    }
    'C.1' = [StructuredResourceTestBase]@{
        Message = 'A resource can be set absent.'
        Prerequisites = 'T035','T036'
        Explanation = @'
**Reason**

This simplifies testing because the removed state provides a consistent baseline from which to test configurations.

**Enforcement**

Invoke the public resource function as follows:

 * `Set Absent`
 * `Test Absent` and confirm the return value is `$true`.
'@
        Scriptblock = {
            $_ | Invoke-IntegrationTest {
                param($CommandName,$Keys,$Hints,$Properties)
                & $CommandName Set Absent @Keys
                & $CommandName Test Absent @Keys | Assert-Value $true
            }
        }
    }
    T036 = [StructuredResourceTestBase]@{
        Message = 'All arguments for key and property parameters are provided.'
        Prerequisites = 'T034'
        Scriptblock = {
            # IntegrationTest
            $_ | 
                Get-PublicResourceFunction |
                Get-ParameterMetaData |
                ? { 
                    -not ($_ | Test-StructuredKnownParameter) -and
                    ($_ | Test-ParameterKind -Not Common)
                } |
                Assert-NamedArgument $_.Arguments
        }
    }
    'C.2' = [StructuredResourceTestBase]@{
        Message = 'An absent resource can be added.'
        Prerequisites = 'C.1'
        Explanation = @'
**Reason**

To be usable, a resource instance must be present.  A resource instance can be removed per C.1.  Accordingly, for a resource instance to be usable, it must be possible to add it.

**Enforcement**

Invoke the public resource function as follows:

 * `Set Absent` to reset
 * `Set Present` to add it
 * `Test Present` and confirm the return value is `$true`
'@
        Scriptblock = {
            $_ | Invoke-IntegrationTest {
                param($CommandName,$Keys,$Hints,$Properties)
                & $CommandName Set Absent @Keys
                & $CommandName Set Present @Keys @Hints
                & $CommandName Test Present @Keys | Assert-Value $true
            }
        }
    }
    'C.3' = [StructuredResourceTestBase]@{
        Message = 'A present resource can be removed.'
        Prerequisites = 'C.2'
        Explanation = @'
**Reason**

This is required to support C.1.

**Enforcement**

Invoke the public resource function as follows:

 * `Set Absent` to reset
 * `Set Present`
 * `Set Absent`
 * `Test Absent` and confirm the return value is `$true`
'@
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
    'C.4' = [StructuredResourceTestBase]@{
        Message = 'A present resource tests false for absence.'
        Prerequisites = 'C.2'
        Explanation = @'
**Reason**

A resource cannot be both present and absent.

**Enforcement**

Invoke the public resource function as follows:

 * `Set Absent` to reset
 * `Set Present` to add it
 * `Test Absent` and confirm the return value is `$false`
'@
        Scriptblock = {
            $_ | Invoke-IntegrationTest {
                param($CommandName,$Keys,$Hints,$Properties)
                & $CommandName Set Absent @Keys
                & $CommandName Set Present @Keys @Hints
                & $CommandName Test Absent @Keys | Assert-Value $false
            }
        }
    }
    'C.5' = [StructuredResourceTestBase]@{
        Message = 'An absent resource tests false for presence.'
        Prerequisites = 'T030','T031'
        Explanation = @'
**Reason**

A resource cannot be both absent and present.

**Enforcement**

Invoke the public resource function as follows:

 * `Set Absent` to reset
 * `Test Present` and confirm the return value is `$false`

The following should probably also be tested:

 * `Set Absent` to reset
 * `Set Present`
 * `Set Absent`
 * `Test Present` and confirm the return value is `$false` 
'@
    }
    T030 = [StructuredResourceTestBase]@{
        Message = 'An absent resource tests false for presence.'
        Prerequisites = 'C.2'
        Scriptblock = {
                $_ | Invoke-IntegrationTest {
                param($CommandName,$Keys,$Hints,$Properties)
                & $CommandName Set Absent @Keys
                & $CommandName Test Present @Keys | Assert-Value $false
            }
        }
    }
    T031 = [StructuredResourceTestBase]@{
        Message = 'An absent resource tests false for presence after adding and removing it.'
        Prerequisites = 'C.2'
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
    'C.6' = [StructuredResourceTestBase]@{
        Message = 'Properties can be set after construction.'
        Prerequisites = 'T032'
        Explanation = @'
**Reason**

If a property cannot be set after construction and a resource instance exists with a different property value, the DSC algorithm will never converge. 
'@
    }
    T032 = [StructuredResourceTestBase]@{
        Message = 'Each property can be set after construction.'
        Prerequisites = 'C.5'
        Scriptblock = {
            $_ | Invoke-IntegrationTest {
                param($CommandName,$Keys,$Hints,$Properties)

                $pk = $Properties | ? { $null -ne $_ } | % {$_.get_Keys()}
                $hk = $Hints      | ? { $null -ne $_ } | % {$_.get_Keys()}

                foreach ( $propertyName in ($pk | ? {$_ -notin $hk}) )
                {
                    & $CommandName Set Absent @Keys
                    & $CommandName Set Present @Keys @Hints

                    $property = @{ $propertyName = $Properties.$propertyName }
                    try
                    {
                        & $CommandName Set Present @Keys @Hints @property
                        & $CommandName Test Present @Keys @property | Assert-Value $true
                    }
                    catch
                    {
                        throw [System.Exception]::new(@"
CommandName: $CommandName
Property: $($property | ConvertTo-PsLiteralString)
"@,
                            $_.Exception
                        )
                    }
                }
            }
        }
    }
    'C.7' = [StructuredResourceTestBase]@{
        Message = 'A property can be set on construction.'
        Prerequisites = 'T033'
        Explanation = @'
**Reason**

This is to avoid requiring multiple passes of the DSC algorithm to achieve convergence.  A property that cannot be set on construction will cause the test following the set to fail.  Such a failure will cause the DSC engine to halt further configuration.
'@
    }
    T033 = [StructuredResourceTestBase]@{
        Message = 'Each property can be set on construction.'
        Prerequisites = 'C.5'
        Scriptblock = {
            $_ | Invoke-IntegrationTest {
                param($CommandName,$Keys,$Hints,$Properties)

                $pk = $Properties | ? { $null -ne $_ } | % {$_.get_Keys()}
                $hk = $Hints      | ? { $null -ne $_ } | % {$_.get_Keys()}

                foreach ( $propertyName in ($pk | ? {$_ -notin $hk}) )
                {
                    & $CommandName Set Absent @Keys

                    $property = @{ $propertyName = $Properties.$propertyName }
                    try
                    {
                        & $CommandName Set Present @Keys @Hints @property
                        & $CommandName Test Present @Keys @property | Assert-Value $true
                    }
                    catch
                    {
                        throw [System.Exception]::new(@"
CommandName: $CommandName
Property: $($property | ConvertTo-PsLiteralString)
"@,
                            $_.Exception
                        )
                    }
                }
            }            
        }
    }
    'L.3' = [StructuredResourceTestBase]@{
        Message = 'The Set and Test methods of the public resource class simply invoke the corresponding public function.'
        Prerequisites = 'PB.3','PB.2'
        Explanation = @'
**Reason**

Complexity is easier to test in functions than classes.  The least amount of complexity that can be in the `Set()` and `Test()` methods of a public resource class is to simply invoke their corresponding public resource function. 
'@
        Scriptblock = {
            $a = $_ | Get-NestedModule |
                    Get-ModuleAst |
                    % { $_.EndBlock } |
                    Get-StatementAst TestStub2
            'Set','Test' |
                % { $a | Assert-ResourceClassMethodBody $_ }
        }
    }
    'A.1' = [StructuredResourceTestBase]@{
        Message = 'All constructor properties are provided when invoking `Set Present`.'
        Explanation = @'
**Reason**

Invoking `Set Present` may lead to invoking the constructor for resource.  If the resource has constructor properties those must also be provided
otherwise construction will fail.

**Enforcement**

This can be enforced by checking for missing constructor properties whenever `Set Present` is invoked. 
'@
    }
}
}