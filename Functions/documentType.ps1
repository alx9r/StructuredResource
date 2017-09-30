enum TextFormat
{
    None = 0
    Title1 = 1
    Title2 = 2
    Title3 = 3
    Title4 = 4
    Bold
}

class Text
{
    [string]$Text
    [TextFormat]$Format

    Text ([string]$t)
    {
        $this.Text = $t
    }
    Text ([string]$t,[TextFormat]$f)
    {
        $this.Text = $t
        $this.Format = $f
    }
    [bool] Equals ($other)
    {
        return ($this.Text -eq $other.Text) -and
               ($this.Format -eq $other.Format)
    }
    [string] ToString ()
    {
        return "Format: $($this.Format)`r`n$($this.Text)"
    }
}

class Section
{
    [string]$Title
    [Text[]]$Text
    [Section[]]$Sections
}
