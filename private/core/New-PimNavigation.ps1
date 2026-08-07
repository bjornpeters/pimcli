function New-PimNavigation {
    <#
    .SYNOPSIS
        Builds the navigation directive a screen returns to the navigator.

    .DESCRIPTION
        Screens do not call each other. A screen renders, reads input, and
        returns one of these directives; the navigator in Invoke-PimNavigation
        decides what happens next.

        That is what keeps 'back' consistent and the call stack flat. The old
        flow called itself to go back, so every 'back' grew the stack and every
        screen had to know its own caller.

        Push  - open Screen on top of the current one, carrying Context.
        Pop   - close this screen and return to the one underneath.
        Home  - unwind everything back to the main menu.
        Stay  - re-render the current screen, e.g. after a refresh.
        Exit  - leave the CLI.

    .PARAMETER Action
        Which directive to issue.

    .PARAMETER Screen
        Registered screen name to open. Required for Push.

    .PARAMETER Context
        State handed to the screen being opened, e.g. the selected role.

    .EXAMPLE
        New-PimNavigation -Action Push -Screen ActivateDetail -Context @{ Role = $role }

    .EXAMPLE
        New-PimNavigation -Action Pop
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory)]
        [ValidateSet('Push', 'Pop', 'Home', 'Stay', 'Exit')]
        [string]$Action,

        [Parameter()]
        [string]$Screen,

        [Parameter()]
        [hashtable]$Context = @{}
    )

    if ($Action -eq 'Push' -and -not $Screen) {
        throw "A 'Push' navigation directive requires a screen name."
    }

    @{
        Action  = $Action
        Screen  = $Screen
        Context = $Context
    }
}
