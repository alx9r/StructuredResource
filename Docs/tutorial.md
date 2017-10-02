# StructuredResource Tutorial

In this tutorial we will use the StructuredResource module to implement a DSC resource that sets the content and attributes of text files.  The tutorial makes extensive use of the commands and automated tests included with StructuredResource to streamline implementation.

You can follow along with this tutorial by first installing StructuredResource on your computer.  You can find [installation instructions here][].  The development of the DSC resource produced when this tutorial was written was captured in the [SrTutorial repository](https://github.com/alx9r/StTutorial).

[installation instructions here]: readme.md

The goal of this tutorial is to produce a DSC resource that can also be invoked from a PowerShell command.  The interfaces will look like the following:

```
PS C:\> Get-DscResource MyFile SrTutorial | % { $_; $_ | % Properties | Format-Table}

ImplementedAs   Name                      ModuleName                     Version    Properties           
-------------   ----                      ----------                     -------    ----------           
PowerShell      MyFile                    SrTutorial                     0.1.0      {Path, Archive, Co...

Name                 PropertyType     IsMandatory Values           
----                 ------------     ----------- ------           
Path                 [string]                True {}               
Archive              [bool]                 False {}               
Content              [NullsafeString]       False {}               
DependsOn            [string[]]             False {}               
Ensure               [string]               False {Absent, Present}
Hidden               [bool]                 False {}               
NoScrubData          [bool]                 False {}               
NotContentIndexed    [bool]                 False {}               
PsDscRunAsCredential [PSCredential]         False {}               
ReadOnly             [bool]                 False {}               
System               [bool]                 False {}               
Temporary            [bool]                 False {}         

PS C:\> Get-Help Invoke-MyFile

NAME
    Invoke-MyFile
    
SYNTAX
    Invoke-MyFile [-Mode] {Set | Test} [[-Ensure] {Present | Absent}] -Path <string> [-Content 
    <NullsafeString>] [-Archive <bool>] [-Hidden <bool>] [-NoScrubData <bool>] [-NotContentIndexed 
    <bool>] [-ReadOnly <bool>] [-System <bool>] [-Temporary <bool>]  [<CommonParameters>]
      
```


## Part A: Setup
### A1. Create the Module

Our DSC resource will be in its own module called "SrTutorial".  Create the module by creating the following folder and file in your [`$Env:PSModulePath`](https://msdn.microsoft.com/en-us/library/dd878326(v=vs.85).aspx):

* `SrTutorial`
	* `SrTutorial.psm1`

### A2. Create the Tests

We will be using the automated tests included  StructuredResource to drive implementation of our resource.  Create the script file `structuredResource.Tests.ps1` in the `SrTutorial` folder.  Your folder structured should now look like this:

* `SrTutorial`
	* `SrTutorial.psm1`
	* `structuredResource.Tests.ps1`

Edit `structucturedResource.Tests.ps1` so that it contains the following:

```PowerShell
Import-Module SrTutorial -Force

Describe 'MyFile' {
    foreach ( $test in (New-StructuredResourceTest MyFile SrTutorial -Kind Unit ) )
    {
        It $test.FullMessage {
            $test | Invoke-StructuredResourceTest
        }
    }
}
```

When this script file is invoked it creates tests using `New-StructuredResourceTest` and uses [Pester](https://github.com/pester/Pester) to run them.  Invoking `help New-StructuredResourceTest` and `help Invoke-StructuredResourceTest` at your PowerShell prompt outputs usage information about those commands.  Note the arguments `MyFile` and `SrTutorial` are the names of our DSC resource and module, respectively.  The DSC resource we will be creating is called `MyFile`.

## Part B: Unit Tests
### B1. Run the Tests

We will be using Pester to run the automated tests throughout this tutorial.  To run the tests we set up in the previous step, open a PowerShell prompt in the `SrTutorial` folder and run `powershell.exe Invoke-Pester`.

As of PowerShell 5.1 it is important that you run each test run in a new instance of powershell.exe to avoid [the stale class problem](https://stackoverflow.com/a/42878789/1404637).  Later versions of PowerShell might fix this problem.  In the meantime make sure you invoke the tests for this tutorial using `powershell.exe Invoke-Pester` not merely `Invoke-Pester`.

The output from `Invoke-Pester` should start out something like this:

```
Executing all tests in '.'

Executing script C:\Users\un1\Documents\WindowsPowerShell\Modules\SrTutorial\structuredResource.Tests.ps1

  Describing MyFile
    [-] T037 - There is a module manifest. 3.61s
      RuntimeException: Item described at path C:\...\SrTutorial\SrTutorial.psd1 does not exist.
      Exception: T037 - There is a module manifest.
...
```

The `[-]` is Pester's way of indicating the test has failed.  Failed tests usually appear in red text.  `T037` is the ID of the StructuredResource test that failed.  The next line contains error information about the failure.  The test are designed so that the first failing test provides you with information to make an edit that takes you one step closer to passing all tests.  In this case, `T037` failed because `SrTutorial.psd1` does not exist.

### B2. Edit, Test, and Repeat

To get `T037` passing, create the module manifest file `SrTutorial.psd1`.  There is [help for writing module manifest files](https://msdn.microsoft.com/en-us/library/dd878337(v=vs.85).aspx) if you are unfamiliar with them.

Your folder structure should now look like this:

* `SrTutorial`
	* `SrTutorial.psm1`
	* `SrTutorial.psd1`
	* `structuredResource.Tests.ps1`

Invoke `powershell.exe Invoke-Pester` again and see what fails next.  Then edit to try to fix the error.  Repeat the test-edit-test cycle until all of the unit tests are passing.  If you are wondering about the terminology used by the tests, the definitions section of [the guidelines][] might help you.

[the guidelines]: guidelines.md

Each DSC resource requires at least one key parameter.  In order to get unit tests passing for `MyFile` you'll need to implement the `$Path` key parameter for the resource.

Note that you might see errors in your editor or output by PowerShell from time to time as you converge on a module that passes all the tests.  Heed those errors the same as those output by StructuredResource to keep you on the right track.

You will likely see multiple errors at any one time.  Pay most attention to the top-most errors as those are most likely to give you guidance about your next edit.

If you get stuck, look for hints in the `SrTutorial` repository's commit history up to the tag `unit-tests-complete`. 

Once you have all the unit tests passing, you will have a well-formed public resource class `[MyFile]` and a well-formed public resource function `Invoke-MyFile`.  These are the public interfaces for the `MyFile` DSC resource.

## Part C: More Parameters

### C1: Mention Remaining Parameters

The `MyFile` DSC resource we are implementing has a number of parameters in addition to `$Path` as follows:

```
    $Content
    $Archive
    $Hidden
    $NoScrubData
    $NotContentIndexed
    $ReadOnly
    $System
    $Temporary
```

Add each of these as properties to the `MyFile` class.

### C2: Test, Edit, and Repeat

Invoke `powershell.exe Invoke-Pester` again, edit the files, and repeat until all the corresponding public resource parameters are implemented and the unit tests are passing again.

## Part D: Integration Test

### D1: Add Integration Tests

Now that the public interfaces of our `MyFile` resource are correctly implemented, we can turn on the integration tests by passing test arguments to `New-StructuredResourceTest`.  Edit `structuredResource.Tests.ps1` to have the following content:

```PowerShell
Import-Module SrTutorial -Force

Describe 'MyFile' {
    foreach ( $test in (New-StructuredResourceTest MyFile SrTutorial  @{
        Path = [System.IO.Path]::GetTempFileName()
        Content = @"
            some
            multiline
            content
"@
        Archive = $true
        Hidden = $true
        NoScrubData = $true
        NotContentIndexed = $true
        ReadOnly = $true
        System = $true
        Temporary = $true
    }))
    {
        It $test.FullMessage {
            $test | Invoke-StructuredResourceTest
        }
    }
}
```

Note the hashtable containing sample arguments that will be used for exercising our `MyFile` resource.  Those arguments will be passed to `Invoke-MyFile` in a variety of ways to test that command's behavior.

Note also that we are no longer limiting `-Kind` to unit tests.

### D2: Implement Public Resource Function

Running `powershell.exe Invoke-Pester` likely returns an error that indicates `Invoke-MyFile` doesn't return anything during testing.  This should come as no surprise since `Invoke-MyFile`'s body is still blank.  To fix this add a process block to `Invoke-MyFile` as follows:

```PowerShell
    process
    {
        $MyInvocation |
            New-StructuredResourceArgs @{
                Tester = 'Test-Path'
                Curer = 'New-Item'
                Remover = 'Remove-Item'
            } |
            Assert-StructuredResourceArgs |
            Invoke-StructuredResource
    }
```

When `MyFile` is invoked, `Invoke-StructuredResource` will invoke `Test-Path`, `New-Item`, and `Remove-File` in order to make the file at `$Path` match the desired state.  `New-StructuredResourceArgs` produces an arguments object suitable for `Invoke-StructuredResource` based on the arguments passed to `Invoke-MyFile` and the attributes of the various parameters.  Many different factors are taken into account by `New-StructuredResourceArgs` and `Invoke-StructuredResource` in order for `Invoke-MyFile` to behave correctly.

`Assert-StructuredResourceArgs` checks for certain invalid ways that `Invoke-MyFile` could be invoked and throws an exception to prevent invalid arguments from getting too far.

### D3: Implement the Property Setter and Tester

Now when we run `powershell.exe Invoke-Pester` `Invoke-MyFile` is being exercised.  The temporary file we provided as an argument is being created, tested for, and removed.  The later tests that exercise setting properties like its content and the archive flag, for example, are still failing.

To get the tests involving properties passing, we need to implement `PropertyTester` and `PropertyCurer` functions.

For the `PropertyTester` we're going to implement `Test-MyFileProperty` as follows:

```PowerShell
function Test-MyFileProperty
{
    param
    (
        $Path,
        $PropertyName,
        $Value                
    )
    if ( $PropertyName -eq 'Content' )
    {
        return $Value -eq (Get-Content $Path -Raw)
    }
    Test-FileAttribute @PSBoundParameters
}
``` 

This function tests whether a file's content or attribute matches the desired value.  There are no surprises in `Set-MyFileProperty`.  `Test-FileAttribute` and `Set-FileAttribute` are just PowerShell implementations of the generally-accepted method of setting and clear windows file attributes from .Net.  Copy and paste the final implementations of each of those four functions into `SrTutorial.psm1` from the tutorial repository.

To wire those functions up to `Invoke-MyFile` we need to mention them in the process block:

```PowerShell
    process
    {
        $MyInvocation |
            New-StructuredResourceArgs @{
                Tester = 'Test-Path'
                Curer = 'New-Item'
                Remover = 'Remove-Item'
                PropertyTester = 'Test-MyFileProperty'
                PropertyCurer = 'Set-MyFileProperty'
            } |
            Assert-StructuredResourceArgs |
            Invoke-StructuredResource
    }
```

`MyFile` is now ready for tests involving properties.

### D4: Test, Edit, Repeat

Running `powershell.exe Invoke-Pester` reveals another problem: One of the flags we set during testing causes `Remove-Item` to fail with `PermissionDenied`.  To fix this, we implement our own `Remover` as follows:

```PowerShell
function Remove-File
{
    param($Path)
    Remove-Item $Path -Force
}
```

The permission denied error has cured but the tests reveal the last remaining problem: The file content is not being set successfully.  Setting a breakpoint and fiddling on the `Get-Content` line in `Test-MyFileProperty` reveals that the `Out-File`/`Get-Content` cycle adds newlines so the equality check fails.  To compensate for this quirk we introduce `Remove-TrailingNewlines` and use it to strip the extraneous characters before comparison.

Now when we run `powershell.exe Invoke-Pester` all the tests pass and we can be reasonably sure that our `MyFile` DSC resource behaves as it should.

Congratulations, you have just implemented a DSC resource that passes the whole StructuredResource test suite.

## E: Try it Out

The tests you ran in the previous module already put `Invoke-MyFile` through its paces.  You can try it out at the PowerShell command line:

```PowerShell
PS C:\> Invoke-MyFile Test Present -Path c:\temp\somefile.txt -Content 'content' -NotContentIndexed $true
False

PS C:\> Invoke-MyFile Set Present -Path c:\temp\somefile.txt -Content 'content' -NotContentIndexed $true

PS C:\> Invoke-MyFile Test Present -Path c:\temp\somefile.txt -Content 'content' -NotContentIndexed $true
True

PS C:\> Get-Item c:\temp\somefile.txt | Select Name,Attributes

Name                Attributes
----                ----------
somefile.txt NotContentIndexed
```

The class-based DSC resource is also available:

```
PS C:\> Get-DscResource MyFile SrTutorial

ImplementedAs   Name                      ModuleName                     Version    Properties           
-------------   ----                      ----------                     -------    ----------           
PowerShell      MyFile                    SrTutorial                     0.1.0      {Path, Archive, Co...
```

DSC resource engines can use the `MyFile` resource.  `Invoke-MyFile` will be invoked by the resource's `Set()` and `Test()` methods. 