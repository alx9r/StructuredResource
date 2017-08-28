# Structured DSC Resource Guidelines

## Definitions

**public resource class** - the class with the `[DscResource()] object that is used to publish a resource

**public resource function** - a function that is invoked by `Set()` and `Test()` of a corresponding public resource class and is also exported as a public interface to the module

## PB: Publishing

### [x] PB.1: Each resource is published using a class with a `[DscResource()]` attribute

This is as opposed to using MOF files to publish resources.

**Reason**

The particulars of the class can easily be tested using PowerShell.  Testing the same information in a MOF-based resource would require a parser for MOF files.

### [x] PB.2: Each public resource is accessible using `Get-DscResource`

**Reason**

There might be subtle differences between the public resource class and the resultant object produced by PowerShell/WMF. Accessing the resultant object from `Get-DscResource` enables testing properties of the resource as interpreted by PowerShell/WMF.

### [x] PB.3: Each public resource has a corresponding public function

**Reason**

Functions are more easily tested than classes.  Exposing a public function that is also invoked by the resource facilitates isolated testing.

### [x] PB.4: The function corresponding to public resource ResourceName is named Invoke-ProcessResourceName

**Reason**

This is to simplify discovery of the public function from the public resource class and vice versa.

### [x] PB.5: The module is output by `Get-Module -ListAvailable`

**Reason**

This simplifies testing because the module and its DSC resources are accessed by name alone.

## L: Layout

### [x] L.1: Each public resource class is accessible in a nested module of its parent.

**Reason**

This is to simplify discovery of public resource classes by automated tests.  Discovery of nested modules is trivial.

### [ ] L.2: Related public resources are published in a single parent module

**Reason**

Related resources usually share an amount of utility code.  Publishing related resources in a single parent module facilitates sharing a single copy of such utility code.

**Enforcement**

Invoke `Get-DscResource` for each of the related public resources and confirm that the module name is the parent module. 

### [ ] L.3: The Set and Test methods of the public resource class simply invoke the public function

**Reason**

Complexity is easier to test in functions than classes.  The least amount of complexity that can be in the `Set()` and `Test()` methods of a public resource class is to simply invoke their corresponding public resource function. 


## PR: Parameters

### [x] PR.1: Each public resource class has member variables with the [DscProperty()] attibute.

**Reason**

Parameters are passed to class-based resources via member variables with the `[DscProperty()]` attribute.  A resource must have at least one parameter.

### [x] PR.2: Public resource class's `Ensure` member variable.

A public resource class has an optional `Ensure` member.  It is of type `[Ensure]` and has default value `Present`. 

**Reason**

The name `Ensure` should only be used to specify whether a resource is present or absent because that is its customary meaning in PowerShell DSC. `Ensure` is of type `[Ensure]` so that it can only take the values `Present` and `Absent`.  `Ensure` has default value `Present` because omitting `Ensure` should cause the resource to ensure presence.

### [x] PR.3: Other member variables of public resource classes have no default value.

**Reason**

Omitting optional parameters means the configuration affected by the parameter should remain unchanged.  Omitting the default value ensures this.

### [x] PR.4: Public resource function `Mode` parameter.

Each public resource function has a mandatory `Mode` parameter.  The `Mode` parameter is of type `[Mode]`.  `Mode` is the first positional argument and does not have a default value.

**Reason**

The mode parameter is required to select between `Test` and `Set`.  It is of type `[Mode]` to restrict its values to `Set` and `Test`. Because it is mandatory, a default value has no use.  `Mode` is the first positional argument to support readability at call sites (e.g. `Invoke-ProcessResource Test`).

### [x] PR.5: Public resource function `Ensure` parameter.

Each public resource function has an optional `Ensure` parameter.  The `Ensure` parameter is of type `[Ensure]`.  `Ensure` is the second positional argument and has default value `Present`.

**Reason**

The name `Ensure` should only be used to specify whether a resource is present or absent because that is its customary meaning in PowerShell DSC.  `Ensure` is of type `[Ensure]` so that it can only take the values `Present` and `Absent`.  `Ensure` is the second positional argument to support readability at call sites (e.g. `Invoke-ProcessResource Test Absent`).  `Ensure` has default value `Present` because omitting `Ensure` should cause the resource to ensure presence.

### [x] PR.6: No public resource function parameters bind to pipeline value.

**Reason**

This is to improve parameter binding predictability.  It is difficult to predict which, if any, parameter a pipeline value will bind to. 

### [ ] PR.7: Public resource parameters bind to pipeline object property values.

**Reason**

This is to support binding of bulk parameters using objects.  In particular, it supports passing the values of member variables of a `[DscResource()]` object as arguments to the function (e.g. `$this | Invoke-ProcessResource Set`).

### [ ] PR.8: A public resource class does not have member variable `Mode`

**Reason**

This is to avert confusion that might result when bulk-binding the values of a public resource object's member variables to a public resource function's parameters using the pipeline (e.g. `$this | Invoke-ProcessResource`).  The correct value for `Mode` must be explicitly passed to the public resource function (e.g. "`Test`" in `Invoke-ProcessResource Test`) on each invocation of the `Set()` and `Test()` methods.  The existence of a `Mode` member variable probably indicates an error (i.e. a resource author is probably incorrectly expecting `Mode` to be passed by the pipeline).

### [ ] PR.8: Each public resource function parameter is statically-typed.

**Reason**

This is to help users understand what kind of object is expected for each parameter.

### [ ] PR.9: Public resource function parameters cannot be `[string]`.

**Reason**

This is to support compliance with PR.11 when a user omits a `[string]`.  Per PowerShell/PowerShell#4616, passing `$null` to a `[string]` parameter unconditionally causes conversion to `[string]::empty`.  This silently converts the meaning from "don't change" to "clear value" which is incorrect.  PowerShell only performs such a silent conversion from `$null` for `[string]`s.  To avoid this problem and still use static-typing you can use `[NullsafeString]` instead.


### [ ] PR.10: Public resource function value-type parameters must be `[Nullable[]]`.

**Reason**

This is to support compliance with PR.11 when a user omits a value-type parameter.  Value-type parameters in .Net cannot be `$null`.

### [ ] PR.11: The meaning of null for an optional default-less parameter is the same as omitting it.

**Reason**

Omission of an optional default-less argument A means "don't change" A.  Such an argument takes the value `$null` while it is embodied as the value of a `[DscProperty()]` member variable.  Accordingly, all callees interpreting such a parameter must consider `$null` to mean "don't change".

### [ ] PR.12: Public resource class value-type member variables must be `[Nullable[]]`.

**Reason**

This is to support compliance with PR.11 when a user omits a value-type parameter.  Value-type parameters in .Net cannot be `$null`.

### [ ] PR.13: Public resource function parameters do not have the `[AllowNull()]` attribute.

**Reason**

This is to support compliance with PR.11.  Mandatory parameters of public resource functions cannot be `$null` because the meaning of `$null` is that same as omission per PR.11.  `[AllowNull()]` does not affect non-mandatory parameters.  Therefore, `[AllowNull()]` on public resource parameters either indicates either or is unnecessary.  Always omitting `[AllowNull()]` avoids errors with no downside.  

### [ ] PR.14: Defaults values are the same for corresponding public resource class member variables and public resource function parameters.

**Reason**

This is to ensure the same behavior whether the resource is invoked using the public resource class or function.


## I: Integration

### [ ] I.1: The module can be imported.

**Reason**

A module can be available using `Get-Module` but fails on import.

### [ ] I.2: The module imported is the one under test.

**Reason**

Confusion can result during testing if PowerShell unexpectedly loads another available module (perhaps with a different version) with the same name.

### [ ] I.3: Each nested module containing a resource class can be imported.

**Reason**

The nested module must be imported to test the class inside it.

### [ ] I.4: Each imported nested module can be accessed using `Get-Module`.

**Reason**

This simplifies testing because the nested module can be accessed by name alone.

### [ ] I.5: Passing `$null` to a public resource function parameter means "don't change".