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
    hidden [string]$_Title = (Accessor $this {
        get
        set {
            param($Title)
            if ( ($null -eq $Title) -or ('' -eq $Title))
            {
                throw 'Title must not be null or empty.'
            }
            $this._Title = $Title
        }
    })
    [Text[]]$Text
    [Section[]]$Sections

    Section([string]$title)
    {
        $this.Title = $title
    }

    Section([hashtable]$h)
    {
        $this.Title = $h.Title
        $this.Text = $h.Text
        $this.Sections = $h.Sections
    }
}
