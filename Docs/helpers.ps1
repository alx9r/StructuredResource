function New-GuidelinesMd
{
    $splat = @{
        Title = 'Structured DSC Resource Guidelines'
        Text = @'

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
'@
        SectionTitleLookup = @{
            PB = 'Publishing'
            PR = 'Parameters'
            I = 'Integration'
            C = 'Contract'
            A = 'Arguments'
            L = 'Layout'
        }
    }
    Get-Tests |
        %{
            $_.GetEnumerator() |
                % { [StructuredResourceTest]::new($_.Value,$_.Key) }
        } |
        ConvertTo-GuidelinesDocument @splat |
        ConvertTo-MdSection |
        ConvertTo-MdText |
        % {$_.Split([System.Environment]::NewLine)}#,[System.StringSplitOptions]::RemoveEmptyEntries)}
}
