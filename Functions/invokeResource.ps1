function Invoke-StructuredResource
{
    <#
	.SYNOPSIS
	Invokes underlying structured DSC resource primitive functions.

	.DESCRIPTION
	The Invoke-StructuredResource function invokes the commands named by Tester, Curer, Remover, PropertyCurer, and PropertyTester.  Invoke-StructuredResource invokes the commands with the arguments provided in _Keys, Hints, and Properties.  The function has two Modes: Set and Test.

	In Test Mode, Invoke-StructuredResource returns true when the Tester and, optionally, PropertyTester return true for all invocations.   The function returns false in Test Mode when any such invocation returns false.

	In Set Mode, Invoke-StructuredResource invokes Curer and, optionally, PropertyCurer to Ensure "Present" and Remover to Ensure "Absent".  The function returns nothing in 'Set' Mode.

	+------|---------+---------------------------------------------------------------------+
	|      |         |          Arguments with which a Command is Invoked                  |
	| Mode | Ensure  +--------+--------------+---------+-----------------+-----------------+
	|      |         | Tester | Curer        | Remover | PropertyTester  | PropertyCurer   |
	+------|---------+--------+--------------+---------+-----------------+-----------------+
	| Test | Absent  | Keys   |              |         |                 |                 |
	| Test | Present | Keys   |              |         | Keys,property   |                 |
	| Set  | Absent  | Keys   |              | Keys    |                 |                 |
	| Set  | Present | Keys   | Keys,Hints   |         | Keys,property   | Keys,property   |
	+------|---------+--------+--------------+---------+-----------------+-----------------+

	 - blank in in a column indicates the command is not invoked
	 - property indicates the command is invoked once for each item in Properties
	 
	No exceptions are handled by Invoke-StructuredResource.
	
	If a null value is provided for an item in Properties that property is treated the same as if it were omitted.
	
	.PARAMETER Mode
	Whether to run in Set or Test Mode.
	
	.PARAMETER Ensure
	Whether to ensure a resource instance is present or absent.  "Present" is the default.
	
	.PARAMETER _Keys
	A hashtable containing named arguments that uniquely identify the resource instance.  _Keys are passed as named arguments to Tester, Curer, Remover, and, optionally, PropertyTester and PropertyCurer.  _Keys has alias Keys.
	
	.PARAMETER Tester
	The name of the command that tests whether the resource instance exists.  Tester must accept as named parameters the arguments provided in _Keys.  Tester must return true if the instance exists and false otherwise.
	
	.PARAMETER Curer
	The name of the command that cures the existence of a resource instance for which Tester returns false.  After invoking Curer, Tester must return true for the same arguments.  Curer must accept as named parameters the arguments provided in _Keys and Hints.  The return value of Curer is ignored.
	
	.PARAMETER Hints
	A hashtable containing named arguments to be passed to Curer along with _Keys.
	
	.PARAMETER Remover
	The name of the command that cures the existence of a resource instance for which Tester returns true.  After invoking Remover, Tester must return false for the same arguments.  Remover must accept as named parameters the arguments provided in _Keys.  The return value of Remover is ignored.
	
	.PARAMETER Properties
	A hashtable containing the names of resource properties and their values as keys and values, respectively.
	
	.PARAMETER PropertyTester
	The name of the command that tests whether the property of a resource instance has the desired value.  PropertyTester must accept as named parameters the arguments provided in _Keys.  It must also have parameters PropertyName and Value which accept the property name and desired value, respectively.  PropertyTester must return true if the value of the property is correct and false otherwise.
	
	.PARAMETER PropertyCurer
	The name of the command that cures properties for which PropertyTester returns false.  After invoking PropertyCurer, PropertyTester must return true for the same arguments.  PropertyCurer must accept as named parameters the arguments provided in _Keys.  It must also have parameters PropertyName and Value which accept the property name and desired value, respectively.  The return value of PropertyCurer is ignored.
	
	.PARAMETER Module
	The context in which to invoke the Tester, Curer, Remover, PropertyTester, and PropertyCurer commands.
    #>
    [CmdletBinding(DefaultParameterSetName = '__AllParameterSets')]
    param
    (
        [Parameter(Mandatory,
                   Position = 1,
                   ValueFromPipelineByPropertyName)]
        [ValidateSet('Set','Test')]
        [Mode]
        $Mode,

        [Parameter(Position = 2,
                   ValueFromPipelineByPropertyName)]
        [ValidateSet('Present','Absent')]
        [Ensure]
        $Ensure = 'Present',

        [Parameter(Mandatory,
                   Position = 3,
                   ValueFromPipelineByPropertyName)]
        [Alias('Keys')]
        [hashtable]
        $_Keys,  # https://github.com/pester/Pester/issues/776

        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [string]
        $Tester,

        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [string]
        $Curer,

        [Parameter(ValueFromPipelineByPropertyName)]
        [hashtable]
        $Hints = @{},


        [Parameter(ValueFromPipelineByPropertyName)]
        [string]
        $Remover,

        [Parameter(ParameterSetName = 'with_properties',
                   ValueFromPipelineByPropertyName)]
        [hashtable]
        $Properties,


        [Parameter(ParameterSetName = 'with_properties',
                   Mandatory,
                   ValueFromPipelineByPropertyName)]
        [string]
        $PropertyTester,

        [Parameter(ParameterSetName = 'with_properties',
                   Mandatory,
                   ValueFromPipelineByPropertyName)]
        [string]
        $PropertyCurer,

        [Parameter(ValueFromPipelineByPropertyName)]
        [psmoduleinfo]
        $Module
    )
    process
    {
        # confirm remover is present when necessary
        if ( $Mode -eq 'Set' -and $Ensure -eq 'Absent' -and -not $Remover )
        {
            throw 'Invoked "Set Absent" but no remover was provided.'
        }

        # test the item
        $correct = & @{
            $true =  { & $Module $Tester @_Keys }
            $false = { &         $Tester @_Keys }
        }.([bool]$Module)

        # process item existence
        switch ( $Ensure )
        {
            'Present' {
                if ( -not $correct )
                {
                    # add the item
                    switch ( $Mode )
                    {
                        # cure the item
                        'Set'  { 
                            $item = & @{
                                $true =  { & $Module $Curer @_Keys @Hints }
                                $false = { &         $Curer @_Keys @Hints }
                            }.([bool]$Module)
                        }

                        # the item doesn't exist
                        'Test' { return $false }
                    }
                }
            }
            'Absent' {
                switch ( $Mode )
                {
                    'Set'  {
                        if ( $correct )
                        {
                            & @{ 
                                $true =  { & $Module $Remover @_Keys | Out-Null }
                                $false = { &         $Remover @_Keys | Out-Null }
                            }.([bool]$Module)
                        }
                        return
                    }
                    'Test' { return -not $correct }
                }
            }
        }

        if ( $PSCmdlet.ParameterSetName -ne 'with_properties' )
        {
            # we are not processing properties
            if ( $Mode -eq 'Test' )
            {
                return $true
            }
            return
        }

        # process the item's properties
        $splat = @{
            Mode = $Mode
            Keys = $_Keys
            Properties = $Properties
            PropertyCurer = $PropertyCurer
            PropertyTester = $PropertyTester
            Module = $Module
        }
        Invoke-StructuredResourceProperty @splat
    }
}

function Invoke-StructuredResourceProperty
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true,
                   Position = 1)]
        [ValidateSet('Set','Test')]
        $Mode,

        [Parameter(Mandatory = $true)]
        [Alias('Keys')]
        [hashtable]
        $_Keys, # https://github.com/pester/Pester/issues/776

        [hashtable]
        $Properties,

        [Parameter(Mandatory = $true)]
        [string]
        $PropertyCurer,

        [Parameter(Mandatory = $true)]
        [string]
        $PropertyTester,

        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [psmoduleinfo]
        $Module
    )
    process
    {
        # process each property
        foreach ( $propertyName in $Properties.Keys )
        {
            # this is the desired value provided by the user
            $desired = $Properties.$propertyName

            # test for the desired value
            $alreadyCorrect = & @{
                $true =  { & $Module $PropertyTester @_Keys -PropertyName $propertyName -Value $desired }
                $false = { &         $PropertyTester @_Keys -PropertyName $propertyName -Value $desired }
            }.([bool]$Module)

            if ( -not $alreadyCorrect )
            {
                if ( $Mode -eq 'Test' )
                {
                    # we're testing and we've found a property mismatch
                    return $false
                }

                # the existing property does not match the desired property
                # so fix it
                & @{
                    $true =  { & $Module $PropertyCurer @_Keys -PropertyName $propertyName -Value $desired | Out-Null }
                    $false = { &         $PropertyCurer @_Keys -PropertyName $propertyName -Value $desired | Out-Null }
                }.([bool]$Module)
            }
        }

        if ( $Mode -eq 'Test' )
        {
            return $true
        }
    }
}
