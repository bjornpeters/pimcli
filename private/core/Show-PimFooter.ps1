function Show-PimFooter {
    <#
    .SYNOPSIS
        Writes the key hints at the bottom of a screen.

    .DESCRIPTION
        Renders the standard keys plus whatever the screen adds, in a fixed
        order, so the hint line matches what Read-PimChoice will actually
        accept.

    .PARAMETER Key
        Extra keys for this screen, as key to label, e.g. @{ s = 'scope' }.
        Rendered before the standard keys.

    .PARAMETER NoBack
        Omit the 'back' hint, for screens with nothing to go back to.

    .PARAMETER NoRefresh
        Omit the 'refresh' hint, for screens that hold no fetched data.

    .EXAMPLE
        Show-PimFooter -Key @{ s = 'scope' }
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [hashtable]$Key = @{},

        [Parameter()]
        [switch]$NoBack,

        [Parameter()]
        [switch]$NoRefresh
    )

    # @() matters: a single screen key would otherwise collapse to a bare string
    # and the += below would concatenate onto it instead of appending to a list.
    $hints = @(
        foreach ($entry in $Key.GetEnumerator()) {
            "[$($entry.Key)] $($entry.Value)"
        }
    )

    if (-not $NoBack)    { $hints += '[b] back' }
    if (-not $NoRefresh) { $hints += '[r] refresh' }
    $hints += '[q] quit'

    Write-PimMessage ''
    Write-PimMessage -Type Muted -Message ($hints -join '   ')
}
