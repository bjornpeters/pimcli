function Invoke-PimNavigation {
    <#
    .SYNOPSIS
        Runs the screen loop until the user exits.

    .DESCRIPTION
        Holds a stack of screen frames and drives it from a single loop. The
        screen on top of the stack is rendered, and the directive it returns
        decides what happens to the stack.

        Because every transition happens here rather than inside the screens,
        the call stack stays flat no matter how deep the user navigates, and
        'back' behaves identically on every screen.

        Popping the last frame ends the loop, so 'back' on the main menu leaves
        the CLI just as 'quit' does.

    .PARAMETER Session
        Shared session state: account, principal ID, scope filter. Passed to
        every screen and mutated in place by screens that change it.

    .PARAMETER HomeScreen
        Name of the screen at the bottom of the stack.

    .EXAMPLE
        Invoke-PimNavigation -Session $session
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [hashtable]$Session,

        [Parameter()]
        [string]$HomeScreen = 'MainMenu'
    )

    $stack = [System.Collections.Generic.List[hashtable]]::new()
    $stack.Add(@{ Screen = $HomeScreen; Context = @{} })

    while ($stack.Count -gt 0) {
        $frame = $stack[$stack.Count - 1]

        try {
            $screenFunction = Get-PimScreen -Name $frame.Screen
            $directive = & $screenFunction -Session $Session -Context $frame.Context
        }
        catch {
            # A screen that blows up must not take the session down with it.
            # Report it and fall back to the screen underneath.
            Write-PimMessage -Type Error -Message "Screen '$($frame.Screen)' failed: $($_.Exception.Message)"
            Wait-PimKey 'Press Enter to go back'
            $stack.RemoveAt($stack.Count - 1)
            continue
        }

        if (-not $directive -or -not $directive.Action) {
            # A screen that returns nothing is treated as a plain 'back' rather
            # than being allowed to spin the loop forever.
            Write-Verbose "Screen '$($frame.Screen)' returned no directive; treating as Pop."
            $stack.RemoveAt($stack.Count - 1)
            continue
        }

        switch ($directive.Action) {
            'Push' {
                $stack.Add(@{ Screen = $directive.Screen; Context = $directive.Context })
            }
            'Pop' {
                $stack.RemoveAt($stack.Count - 1)
            }
            'Home' {
                while ($stack.Count -gt 1) {
                    $stack.RemoveAt($stack.Count - 1)
                }
            }
            'Stay' {
                # Re-render the same frame, but let the screen hand new context
                # back to itself so a refresh can clear a cached result.
                if ($directive.Context.Count -gt 0) {
                    $frame.Context = $directive.Context
                }
            }
            'Exit' {
                $stack.Clear()
            }
        }
    }
}
