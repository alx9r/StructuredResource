# Getting Started with StructuredResource

## New to PowerShell or DSC?
All of the StructuredResource documentation assumes that you have a working familiarity with PowerShell and DSC.  If you are new to PowerShell or DSC I recommend reviewing the getting started documentation at the [PowerShell](https://github.com/PowerShell/PowerShell) project.

## Installing StructuredResource

StructuredResource is a PowerShell module.  To install simply put the root folder (the one named "StructuredResource") in one of the `$PSModulePath` folders on your system.  For testing and development I recommend installing StructuredResource to the user modules folder (usually `$Env:UserProfile\Documents\WindowsPowerShell\Modules`). 

### Prerequisites

StructuredResource requires WMF 5.0 or later.  

### Obtaining StructuredResource

To obtain StructuredResource I recommend cloning [the repository](https://github.com/alx9r/StructuredResource.git) to your computer and checking out the [latest release](https://github.com/alx9r/StructuredResource/releases/latest) using `git clone` and `git checkout`.

Alternatively you can download then extract an archive of the module from [this page](https://github.com/alx9r/StructuredResource/releases/latest).

### Confirming Installation

To confirm that StructuredResource is installed on your computer, invoke the following commands:

```
C:\> Import-Module StructuredResource
C:\> Get-Module StructuredResource

ModuleType Version    Name                                ExportedCommands
---------- -------    ----                                ----------------
Script     0.1.0      StructuredResource                  {Invoke-Structured...
```

You should see some details about the StructuredResource module output by the `Get-Module` command as shown above.

## Introductory Topics

For an introduction to using StructuredResource to develop your own DSC resources, I recommend reading the following topics:

* [Tutorial]()
* [Guidelines]()