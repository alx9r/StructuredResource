function Get-MemberProperty
{
    param
    (
        [Parameter(Position = 1)]
        [string]
        $Filter = '*',

        [Parameter(ValueFromPipeline = $true,
                   Mandatory = $true)]
        [System.Reflection.TypeInfo]
        $TypeInfo
    )
    process
    {
        foreach ( $property in (
            $TypeInfo.GetMembers() |
                ? { $_.MemberType -eq 'Property' } |
                ? { $_.Name -like $Filter }
        ))
        {
            try
            {
                $property
            }
            catch
            {
                throw [System.Exception]::new(
                    "Property $($property.Name) of type $($TypeInfo.Name)",
                    $_.Exception
                )
            }
        }
    }
}

function Test-MemberProperty
{
    param
    (
        [Parameter(Position = 1,
                   Mandatory = $true)]
        [string]
        $PropertyName,

        [Parameter(ValueFromPipeline = $true,
                   Mandatory = $true)]
        [System.Reflection.TypeInfo]
        $TypeInfo
    )
    process
    {
        [bool]($TypeInfo | Get-MemberProperty $PropertyName)
    }
}

function Assert-MemberProperty
{
    param
    (
        [Parameter(ParameterSetName = 'affirmative',
                   Position = 1,
                   Mandatory = $true)]
        [string]
        $PropertyName,

        [Parameter(ParameterSetName = 'negative')]
        [string]
        $Not,

        [Parameter(ValueFromPipeline = $true,
                   Mandatory = $true)]
        [System.Reflection.TypeInfo]
        $TypeInfo
    )
    process
    {
        $_propertyName = $PropertyName,$Not | ? {$_}
        if
        (
            ( $TypeInfo | Test-MemberProperty $_propertyName ) -xor
            ( $PSCmdlet.ParameterSetName -eq 'negative' )
        )
        {
            return
        }

        if ( $PSCmdlet.ParameterSetName -eq 'affirmative' )
        {
            throw "Property $_propertyName not found on type $($TypeInfo.Name)."
        }
        throw "Property $_propertyName found on type $($TypeInfo.Name)."
    }
}

function Get-PropertyCustomAttribute
{
    param
    (
        [Parameter(Mandatory = $true,
                   Position = 1)]
        [string]
        $AttributeName,

        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true)]
        [System.Reflection.PropertyInfo]
        $PropertyInfo
    )
    process
    {
        $PropertyInfo.CustomAttributes |
            ? {$_.AttributeType.Name -eq "$AttributeName`Attribute" }
    }
}

# function Test-PropertyCustomAttribute
Get-Command Get-PropertyCustomAttribute |
    New-Tester |
    Invoke-Expression

function Assert-PropertyCustomAttribute
{
    param
    (
        [Parameter(ParameterSetName = 'affirmative',
                   Mandatory = $true,
                   Position = 1)]
        [string]
        $AttributeName,

        [Parameter(ParameterSetName = 'negative')]
        [string]
        $Not,

        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true)]
        [System.Reflection.PropertyInfo]
        $PropertyInfo
    )
    process
    {
        $_attributeName = $AttributeName,$Not | ? {$_}
        if
        (
            ( $PropertyInfo | Test-PropertyCustomAttribute $_attributeName ) -xor
            ( $PSCmdlet.ParameterSetName -eq 'negative' )
        )
        {
            return
        }

        if ( $PSCmdlet.ParameterSetName -eq 'negative' )
        {
            throw "Custom attribute $AttributeName exists on $($PropertyInfo.Name)."
        }

        throw "Custom attribute $AttributeName does not exist on $($PropertyInfo.Name)."
    }
}


function Test-DscPropertyRequired
{
    param
    (
        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true)]
        [System.Reflection.PropertyInfo]
        $PropertyInfo
    )
    process
    {
        $attribute = $PropertyInfo | Get-PropertyCustomAttribute 'DscProperty'
        return ($attribute | Test-CustomAttributeArgument Key $true) -or
               ($attribute | Test-CustomAttributeArgument Mandatory $true)
    }
}

# function Assert-DscPropertyRequired
Get-Command Test-DscPropertyRequired |
    New-Asserter "Property $($PropertyInfo.Name) is not a required DSC property." |
    Invoke-Expression

function Get-PropertyType
{
    param
    (
        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true,
                   Position = 1)]
        [System.Reflection.PropertyInfo]
        $PropertyInfo
    )
    process
    {
        $PropertyInfo.PropertyType
    }
}

# function Test-PropertyType
Get-Command Get-PropertyType |
    New-Tester |
    Invoke-Expression

# function Assert-PropertyType
Get-Command Test-PropertyType |
    New-Asserter {"Property $($PropertyInfo.Name) is of type $Value not $($PropertyInfo | Get-PropertyType)"} |
    Invoke-Expression

function Get-PropertyDefault
{
    param
    (
        [Parameter(Position = 1,
                   Mandatory = $true)]
        [string]
        $PropertyName,

        [Parameter(ValueFromPipeline = $true,
                   Mandatory = $true)]
        [System.Reflection.TypeInfo]
        $TypeInfo
    )
    process
    {
        Write-Host "TypeInfo"
        Write-Host $TypeInfo

        Write-Host "DeclaredConstructors"
        Write-Host $TypeInfo.DeclaredConstructors

        $TypeInfo.GetConstructors()[0].Invoke($null).$PropertyName
    }
}

# function Test-PropertyDefault
Get-Command Get-PropertyDefault |
    New-Tester |
    Invoke-Expression

# function Assert-PropertyDefault
Get-Command Test-PropertyDefault |
    New-Asserter {
        function toString {
            param([Parameter(ValueFromPipeline)]$x)
            process {
                @{
                    $true = '$null'
                    $false = $x
                }.([bool]($null -eq $x))
            }
        }
        "Default value $($TypeInfo | Get-PropertyDefault $PropertyName | toString ) does not match expected value $($Value | toString) for property $PropertyName of [$TypeInfo]."
    } |
    Invoke-Expression

