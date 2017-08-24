function Invoke-SortGraph
{
    param
    (
        [Parameter(Position = 1,
                   ValueFromPipeline = $true,
                   Mandatory = $true)]
        [hashtable]
        $Edges
    )
    # per https://en.wikipedia.org/wiki/Topological_sorting#Kahn.27s_algorithm

    $mEdges = ConvertTo-MutableEdges $Edges
    $S = New-Object System.Collections.Stack
    Get-StartIds $Edges | % { $S.Push($_) }
    $L = New-Object System.Collections.Queue

    while ( $S.Count )
    {
        $n = $S.Pop()
        $L.Enqueue($n)

        foreach ( $head in $Edges.Keys )
        {
            foreach ( $tail in $Edges.$head )
            {
                if ( $tail -eq $n )
                {
                    $m = $head

                    # edge points from n to m
                    # remove it
                    $mEdges.$m = $mEdges.$m | ? {$_ -ne $n }

                    if ( -not $mEdges.$head )
                    {
                        # m has no other incoming edges
                        # insert m into S
                        $S.Push($m)
                    }
                }
            }
        }
    }

    if ( $mEdges.Values -ne $null )
    {
        throw 'Graph has at least one cycle.'
    }

    return $L
}

function Get-StartIds
{
    param
    (
        [Parameter(Position = 1)]
        [hashtable]
        $Edges
    )
    # Heads and tails refers to those parts of the arrows used to illustrate
    # edges on the graph.

    $S = New-Object System.Collections.Queue

    $heads = $Edges.Keys

    foreach ( $head in $heads )
    {
        foreach ( $tail in $Edges.$head )
        {
            if ( -not $Edges.$tail )
            {
                $S.Enqueue($tail)
            }
        }
    }
    return $S | Select -Unique
}

function ConvertTo-MutableEdges
{
    param
    (
        [Parameter(Position = 1)]
        [hashtable]
        $Edges
    )
    $outputEdges = @{}
    foreach ( $head in $Edges.Keys )
    {
        $stack = New-Object System.Collections.Stack
        $Edges.$head | ? {$_} | % { $stack.Push($_) }
        if ( $stack.Count )
        {
            $outputEdges.$head = $stack
        }
    }
    return $outputEdges
}
