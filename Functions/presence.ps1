$presenceTests = [ordered]@{
    'reset' = {
        param($Keys,$CommandName)
        & $CommandName Set Absent @Keys
        & $CommandName Test Absent @Keys | Assert-Value $true
    }
    'begins absent' = {
        param($Keys,$CommandName)
        & $CommandName Test Absent @Keys | Assert-Value $true
    }
    'test for presence is false when absent at beginning' = {
        param($Keys,$CommandName)
        & $CommandName Test Present @Keys | Assert-Value $false
    }
    'gets set to present' = {
        param($Keys,$CommandName)
        & $CommandName Set Present @Keys
        & $CommandName Test Present @Keys | Assert-Value $true
    }
    'test for absence is false when present' = {
        param($Keys,$CommandName)
        & $CommandName Set Present @Keys
        & $CommandName Test Absent @keys | Assert-Value $false
    }
    'gets set back to absent' = {
        param($Keys,$CommandName)
        & $CommandName Set Present @Keys
        & $CommandName Set Absent @Keys
        & $CommandName Test Absent @Keys | Assert-Value $true
    }
    'test for presence is false after setting back to absent' = {
        param($Keys,$CommandName)
        & $CommandName Set Present @Keys
        & $CommandName Set Absent @Keys
        & $CommandName Test Present @Keys | Assert-Value $false        
    }
}

function New-PresenceTest
{
    param
    (
        [Parameter(Mandatory,
                   Position = 1)]
        [System.Management.Automation.FunctionInfo]
        $CommandInfo,

        [Parameter(Mandatory,
                   ValueFromPipeline)]
        [hashtable]
        $Keys
    )
    process
    {
        foreach ( $testName in $presenceTests.get_Keys() | ? {$_ -ne 'reset' } )
        {
            'reset',$testName | % {
                $message = $_
                try
                {
                    [pscustomobject]@{
                        NamedArgs = @{
                            Keys = $Keys
                            CommandName = $CommandInfo.Name
                        }
                        Scriptblock = $presenceTests.$_
                        Message = $message
                    }
                }
                catch
                {
                    throw [System.Exception]::new(
                        "CommandName,Keys,Message : $($CommandInfo.Name), $Keys, `"$message`"",
                        $_.Exception
                    )
                }
            }
        }
    }
}
