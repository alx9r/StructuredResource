# Structured DSC Resource Guidelines


<!--

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

!!!!! This document is script-generated.  !!!!!

!!!!! Do not directly edit this document. !!!!!

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

-->



- [Interpretation](#interpretation)

- [Definitions](#definitions)

- [Guidelines](#guidelines)

   - [A: Arguments](#a-arguments)

   - [C: Contract](#c-contract)

   - [I: Integration](#i-integration)

   - [L: Layout](#l-layout)

   - [PB: Publishing](#pb-publishing)

   - [PR: Parameters](#pr-parameters)



## Interpretation



These guidelines shall be interpreted according to the doctrine of [_lex specialis_](https://en.wikipedia.org/wiki/Lex_specialis).  In other words, where two guidelines apply to the same situation, the more specific guideline prevails.



## Definitions



**constructor property** - a public resource parameter or property that is a required parameter of the resource's constructor.  Every constructor property is a hint but not every hint is a constructor property.



**DSC algorithm** - the process that successively invokes DSC resources to converge on a configuration.



**hint** - a public resource parameter or property that is passed to the resource's constructor.



**key** - a mandatory public resource parameter or property that uniquely identifies a resource instance.



**property** - a property of a resource instance.  A property can be set and tested by passing a value to its corresponding public resource parameter.  A property cannot be created or removed from its resource instance. 



**resource instance** - an instance of a resource that can be created and removed using `Set Present` and `Set Absent`, respectively.



**public resource class** - the class with the `[DscResource()]` object that is used to publish a resource.



**public resource function** - a function that is invoked by `Set()` and `Test()` of a corresponding public resource class and is also exported as a public interface to the module.



**public resource parameter** - a parameter of a public resource function.



**public resource property** - a property of a public resource class bearing the `[DscProperty()]` attribute.
## A: Arguments
### A.1 All constructor properties are provided when invoking `Set Present`.
**Reason**



Invoking `Set Present` may lead to invoking the constructor for resource.  If the resource has constructor properties those must also be provided

otherwise construction will fail.



**Enforcement**



This can be enforced by checking for missing constructor properties whenever `Set Present` is invoked. 
## C: Contract
### C.1 A resource can be set absent.
**Reason**



This simplifies testing because the removed state provides a consistent baseline from which to test configurations.



**Enforcement**



Invoke the public resource function as follows:



 * `Set Absent`

 * `Test Absent` and confirm the return value is `$true`.
### C.2 An absent resource can be added.
**Reason**



To be usable, a resource instance must be present.  A resource instance can be removed per C.1.  Accordingly, for a resource instance to be usable, it must be possible to add it.



**Enforcement**



Invoke the public resource function as follows:



 * `Set Absent` to reset

 * `Set Present` to add it

 * `Test Present` and confirm the return value is `$true`
### C.3 A present resource can be removed.
**Reason**



This is required to support C.1.



**Enforcement**



Invoke the public resource function as follows:



 * `Set Absent` to reset

 * `Set Present`

 * `Set Absent`

 * `Test Absent` and confirm the return value is `$true`
### C.4 A present resource tests false for absence.
**Reason**



A resource cannot be both present and absent.



**Enforcement**



Invoke the public resource function as follows:



 * `Set Absent` to reset

 * `Set Present` to add it

 * `Test Absent` and confirm the return value is `$false`
### C.5 An absent resource tests false for presence.
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
### C.6 Properties can be set after construction.
**Reason**



If a property cannot be set after construction and a resource instance exists with a different property value, the DSC algorithm will never converge. 
### C.7 A property can be set on construction.
**Reason**



This is to avoid requiring multiple passes of the DSC algorithm to achieve convergence.  A property that cannot be set on construction will cause the test following the set to fail.  Such a failure will cause the DSC engine to halt further configuration.
## I: Integration
### I.1 The module can be imported.
**Reason**



A module can be available using `Get-Module -ListAvailable` but fails on import.
### I.2 The module imported is the one under test.
**Reason**



Confusion can result during testing if PowerShell unexpectedly loads another available module (perhaps with a different version) with the same name.
### I.3 Each nested module containing a resource class can be imported.
**Reason**



The nested module must be imported to test the class inside it.
### I.4 Each imported nested module can be accessed using `Get-Module`.
**Reason**



This simplifies testing because the nested module can be accessed by name alone.
## L: Layout
### L.1 Each public resource class is accessible in a nested module of its parent.
**Reason**



This is to simplify discovery of public resource classes by automated tests. Discovery of nested modules is trivial.
### L.2 Related public resources are published in a single parent module
**Reason**



Related resources usually share an amount of utility code.  Publishing related resources in a single parent module facilitates sharing a single copy of such utility code.



**Enforcement**



Invoke `Get-DscResource` for each of the related public resources and confirm that the module name is the parent module. 
### L.3 The Set and Test methods of the public resource class simply invoke the corresponding public function.
**Reason**



Complexity is easier to test in functions than classes.  The least amount of complexity that can be in the `Set()` and `Test()` methods of a public resource class is to simply invoke their corresponding public resource function. 
## PB: Publishing
### PB.1 Each resource is published using a class with a `[DscResource()]` attribute.
This is as opposed to using MOF files to publish resources.



**Reason**



The particulars of the class can easily be tested using PowerShell.  Testing the same information in a MOF-based resource would require a parser for MOF files.
### PB.2 Each public resource is accessible using Get-DscResource.
**Reason**



There might be subtle differences between the public resource class and the resultant object produced by PowerShell/WMF. Accessing the resultant object from `Get-DscResource` enables testing public resource properties as interpreted by PowerShell/WMF.
### PB.3 Each public resource has a corresponding public function.
**Reason**



Functions are more easily tested than classes.  Exposing a public function that is also invoked by the resource facilitates isolated testing.
### PB.4 The function corresponding to public resource ResourceName is named Invoke-ResourceName.
**Reason**



This is to simplify discovery of the public function from the public resource class and vice versa.
### PB.5 The module is output by `Get-Module -ListAvailable`
**Reason**



This simplifies testing because the module and its DSC resources are accessed by name alone.
## PR: Parameters
### PR.1 Each public resource class has properties with the `[DscProperty()]` attibute.
**Reason**



Parameters are passed to class-based resources via public resource class properties with the `[DscProperty()]` attribute.  A resource must have at least one such property.
### PR.2 Ensure public resource property.
A public resource class has an optional `Ensure` property.  It is of type `[Ensure]` and has default value `Present`.



**Reason**



The name `Ensure` should only be used to specify whether a resource is present or absent because that is its customary meaning in PowerShell DSC. `Ensure` is of type `[Ensure]` so that it can only take the values `Present` and `Absent`.  `Ensure` has default value `Present` because omitting `Ensure` should cause the resource to ensure presence.
### PR.3 <del>PR.3: Other public resource properties have no default value</del>
**Reason**



<del>Omitting optional parameters means the configuration affected by the parameter should remain unchanged.  A default value for a public resource property defeats that behavior because the configuration gets set to the default value when the parameter is omitted.</del>



This rule was removed because a resource author could reasonably opt that an omitted value should change the affected configuration to a default value.  A user can still override such behavior by specifying `$null` for such a parameter thereby preventing any change to the affected configuration.
### PR.4 Mode public resource parameter.
Each public resource function has a mandatory `Mode` parameter.  The `Mode` parameter is of type `[Mode]`.  `Mode` is the first positional argument and does not have a default value.



**Reason**



The mode parameter is required to select between `Test` and `Set`.  It is of type `[Mode]` to restrict its values to `Set` and `Test`. Because it is mandatory, a default value has no use.  `Mode` is the first positional argument to support readability at call sites (e.g. `Invoke-Resource Test`).
### PR.5 Ensure public resource parameter.
Each public resource function has an optional `Ensure` parameter.  The `Ensure` parameter is of type `[Ensure]`.  `Ensure` is the second positional argument and has default value `Present`.



**Reason**



The name `Ensure` should only be used to specify whether a resource is present or absent because that is its customary meaning in PowerShell DSC.  `Ensure` is of type `[Ensure]` so that it can only take the values `Present` and `Absent`.  `Ensure` is the second positional argument to support readability at call sites (e.g. `Invoke-Resource Test Absent`).  `Ensure` has default value `Present` because omitting `Ensure` should cause the resource to ensure presence.
### PR.6 No public resource parameters bind to pipeline value.
No public resource parameter should have the `ValueFromPipeline` attribute set.



**Reason**



This is to improve parameter binding predictability.  With `ValueFromPipeline` set it is difficult to predict which, if any, parameter a pipeline value will bind to. 
### PR.7 Public resource parameters bind to pipeline object property values.
Each public resource parameter should have the `ValueFromPipelineByPropertyName` attribute set.



**Reason**



This is to support binding of bulk parameters using objects.  In particular, it supports passing the values of member variables of a `[DscResource()]` object as arguments to the function (e.g. `$this | Invoke-Resource Set`).
### PR.8 No Mode public resource property.
**Reason**



This is to avert confusion that might result when bulk-binding the values of a public resource properties to public resource parameters using the pipeline (e.g. `$this | Invoke-Resource`).  The correct value for `Mode` must be explicitly passed to the public resource function (e.g. "`Test`" in `Invoke-Resource Test`) on each invocation of the `Set()` and `Test()` methods.  The existence of a `Mode` property probably indicates an error.  That is, a resource author is probably incorrectly expecting `Mode` to be passed from a public resource property by the pipeline.
### PR.9 Each public resource parameter is statically-typed.
**Reason**



This is to help users understand what kind of object is expected for each parameter.
### PR.10 Optional public resource parameters cannot be `[string]` (use `[NullsafeString]` instead)
**Reason**



This is to support compliance with PR.12 when a user omits a `[string]`.  Per PowerShell/PowerShell#4616, passing `$null` to a `[string]` parameter unconditionally causes conversion to `[string]::empty`.  This silently converts the meaning from "don't change" to "clear value" which is incorrect.  PowerShell only performs such a silent conversion from `$null` for `[string]`s.  To avoid this problem and still use static-typing you can use `[NullsafeString]` instead. 



Because PR.12 does not apply to mandatory parameters, this rule also does not apply to mandatory parameters.
### PR.11 Optional value-type public resource parameters must be `[Nullable[T]]`.
**Reason**



This is to support compliance with PR.12 when a user omits a value-type parameter.  Normal value-type parameters in .Net cannot be `$null`.



**Exceptions**



This rules does not apply to the `Ensure` public resource parameter because it cannot be null.
### PR.12 The meaning of null for an optional default-less public resource property or parameter is the same as omitting it.
**Reason**



Omission of an optional default-less parameter P means "don't change" P.  Such an omitted parameter takes the value `$null` while it is embodied as the value of a public resource property.  This is because there is no other built-in mechanism that means unbound, unspecified, or omitted for public resource properties.  Accordingly, all callees interpreting such a parameter must consider `$null` to mean "don't change".



This rule does not apply to mandatory parameters because they can neither be null (by PR.14) nor omitted (because they are mandatory).
### PR.13 Optional value-type public resource properties must be `[Nullable[T]]`.
**Reason**



This is to support compliance with PR.11 when a user omits a value-type parameter.  Value-type parameters in .Net cannot be `$null`.



**Exception**



This rule does not apply to the `Ensure` public resource property.
### PR.14 Public resource function parameters do not have the `[AllowNull()]` attribute.
**Reason**



This is to support compliance with PR.11.  Mandatory public resource parameters are not permitted to be `$null` because the meaning of `$null` is the same as omission per PR.11.  `[AllowNull()]` does not affect non-mandatory parameters.  Therefore, `[AllowNull()]` on public resource parameters either indicates an error or is unnecessary.  Always omitting `[AllowNull()]` avoids errors with no downside.  
### PR.15 Each public resource property has a corresponding public resource parameter.
**Reason**



This is to support parity between the interfaces published by the public resource class and public resource function.
### PR.16 Each public resource parameter has a corresponding public resource property.
**Reason**



This is to support parity between the interfaces published by the public resource class and public resource function.
### PR.17 Defaults values match for corresponding public resource properties and parameters.
**Reason**



This is to ensure the same behavior whether the resource is invoked using the public resource class or function.
### PR.18 Types match for corresponding public resource properties and parameters.
**Reason**



This is to ensure the same behavior whether the resource is invoked using the public resource class or function.
### PR.19 Mandatoriness matches for corresponding public resource properties and parameters.
**Reason**



This is to ensure the same behavior whether the resource is invoked using the public resource class or function.
### PR.20 Public resource parameters that correspond to constructor properties are marked with an attribute.
**Reason**



This is so that libraries interpreting public resource parameters are able to correctly pass required properties to a resource's constructor.
### PR.21 Each public resource parameter whose corresponding public resource property bears `[DscProperty(Key)]` bears `[StructuredResource('Key')]`
**Reason**



This is to ensure that libraries interpreting public resource parameters are able to correctly identify Key parameters.
