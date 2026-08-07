function Read-PimChoice {
    <#
    .SYNOPSIS
        Reads and classifies a menu choice.

    .DESCRIPTION
        Every screen reads input through here, so the standard keys work the
        same way everywhere without each screen re-implementing them:

            b   back        q   quit        r   refresh

        A screen adds its own keys with -Key. Numeric input is validated
        against -MaxIndex and returned as a zero-based index, so screens index
        their collections directly instead of repeating the off-by-one
        arithmetic.

    .PARAMETER Prompt
        Prompt text shown to the user.

    .PARAMETER MaxIndex
        Highest selectable item number, 1-based as displayed. Zero means the
        screen takes no numeric input.

    .PARAMETER Key
        Extra single-letter keys this screen accepts, as key to action name,
        e.g. @{ a = 'Approve'; d = 'Deny' }.

    .PARAMETER NoBack
        Do not accept 'b'. Used by the main menu, which has nothing to go back to.

    .OUTPUTS
        A hashtable with Type and, depending on Type, Index or Action.
        Type is one of Index, Action, Back, Quit, Refresh, Empty, Invalid.

    .EXAMPLE
        $choice = Read-PimChoice -MaxIndex $roles.Count -Key @{ s = 'Scope' }
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter()]
        [string]$Prompt = 'Select',

        [Parameter()]
        [int]$MaxIndex = 0,

        [Parameter()]
        [hashtable]$Key = @{},

        [Parameter()]
        [switch]$NoBack
    )

    $answer = (Read-Host -Prompt $Prompt).Trim()

    if ([string]::IsNullOrWhiteSpace($answer)) {
        return @{ Type = 'Empty' }
    }

    $normalised = $answer.ToLowerInvariant()

    # Screen-specific keys win over the standard ones, so a screen can
    # deliberately repurpose a letter if it has to.
    foreach ($candidate in $Key.Keys) {
        if ($normalised -eq $candidate.ToLowerInvariant()) {
            return @{ Type = 'Action'; Action = $Key[$candidate] }
        }
    }

    switch ($normalised) {
        'q' { return @{ Type = 'Quit' } }
        'r' { return @{ Type = 'Refresh' } }
        'b' {
            if (-not $NoBack) {
                return @{ Type = 'Back' }
            }
        }
    }

    $parsed = 0
    if ([int]::TryParse($answer, [ref]$parsed)) {
        if ($MaxIndex -gt 0 -and $parsed -ge 1 -and $parsed -le $MaxIndex) {
            return @{ Type = 'Index'; Index = $parsed - 1 }
        }
    }

    @{ Type = 'Invalid'; Value = $answer }
}
