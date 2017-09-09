Import-Module StructuredResource -Force

InModuleScope StructuredResource {


$edges1 = @{
# per https://en.wikipedia.org/wiki/Topological_sorting#Examples
    11 = 5,7
    2 = 11
    8 = 7,3
    9 = 11,8
    10 = 11,3
}

$edges2 = @{
    1 = $null
    2 = 1
    3 = 2
}

Describe Invoke-SortGraph {
    Context 'edges1' {
        It 'returns sorted list' {
            $r = Invoke-SortGraph $edges1
            $r | Should be 3,7,8,5,11,2,10,9
        }
    }
    Context 'edges2' {
        It 'returns sorted list' {
            $r = Invoke-SortGraph $edges2
            $r | Should be 1,2,3
        }
    }
    $cyclic = @{
        1 = 2
        2 = 3
        3 = 1
    }
    It 'throws error for cyclic list' {
        { Invoke-SortGraph $cyclic } |
            Should throw 'cycle'
    }
}

Describe Get-StartIds {
    It 'returns start IDs' {
        $r = Get-StartIds $edges1

        $r.Count | Should be 3
        5 -in $r | Should be $true
        7 -in $r | Should be $true
        3 -in $r | Should be $true
    }
}

Describe ConvertTo-MutableEdges {
    It 'returns a hashtable of queues' {
        $r = ConvertTo-MutableEdges $edges1
        
        $r.Keys.Count | Should be $edges1.Keys.Count
        $r.get_Item(11).GetType() | Should be 'System.Collections.Stack'
    }
}
}
