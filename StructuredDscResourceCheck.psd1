@{

# Script module or binary module file associated with this manifest.
RootModule = 'StructuredDscResourceCheck.psm1'
NestedModules = 'TestResource1.psm1'
ScriptsToProcess = @(
    '.\dotNetTypes\ensure.ps1'
    '.\dotNetTypes\mode.ps1'
)

DscResourcesToExport = '*'

# Version number of this module.
ModuleVersion = '0.1.0'

# ID used to uniquely identify this module
GUID = 'ec7c68ce-a7f9-4bb4-b240-c3015356aa61'

# Author of this module
Author = 'alx9r'

# Copyright statement for this module
Copyright = '(c) 2017 Microsoft. All rights reserved.'

# Description of the functionality provided by this module
# Description = ''

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '5.0'

# Name of the Windows PowerShell host required by this module
# PowerShellHostName = ''
}