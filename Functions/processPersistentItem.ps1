function Invoke-ProcessPersistentItem
{
    [CmdletBinding(DefaultParameterSetName = '__AllParameterSets')]
    param
    (
        [Parameter(Mandatory,
                   Position = 1,
                   ValueFromPipelineByPropertyName)]
        [ValidateSet('Set','Test')]
        $Mode,

        [Parameter(Position = 2,
                   ValueFromPipelineByPropertyName)]
        [ValidateSet('Present','Absent')]
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
        $PropertyCurer,


        [Parameter(ParameterSetName = 'with_properties',
                   Mandatory,
                   ValueFromPipelineByPropertyName)]
        [string]
        $PropertyTester,

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

        # retrieve the item
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
        Invoke-ProcessPersistentItemProperty @splat
    }
}

function Invoke-ProcessPersistentItemProperty
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
