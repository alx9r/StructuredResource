# Structured DSC Resource Guidelines

## Definitions

**public resource class** - the class with the `[DscResource()] object that is used to publish a resource

**public resource function** - a function that is invoked by `Set()` and `Test()` of a corresponding public resource class and is also exported as a public interface to the module

## P: Publishing

### [x] PI.1: Each resource is published using a class with a `[DscResource()]` attribute

This is as opposed to using MOF files to publish resources.

**Reason**

The particulars of the class can easily be tested using PowerShell.  Testing the same information in a MOF-based resource would require a parser for MOF files.

### [x] PI.2: Each public resource is accessible using `Get-DscResource`

**Reason**

There might be subtle differences between the public resource class and the resultant object produced by PowerShell/WMF. Accessing the resultant object from `Get-DscResource` enables testing properties of the resource as interpreted by PowerShell/WMF.

### [x] PI.3: Each public resource has a corresponding public function

**Reason**

Functions are more easily tested than classes.  Exposing a public function that is also invoked by the resource facilitates isolated testing.

### [x] PI.4: The function corresponding to public resource ResourceName is named Invoke-ProcessResourceName

**Reason**

This is to simplify discovery of the public function from the public resource class and vice versa.

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


## P: Parameters
