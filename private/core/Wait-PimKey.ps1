function Wait-PimKey {
    <#
    .SYNOPSIS
        Pauses until the user presses Enter.

    .DESCRIPTION
        A bare 'Read-Host' call writes whatever was typed to the output stream.
        In a screen that is a real hazard: the screen's output is its navigation
        directive, so a stray pause would emit a string alongside the directive
        and hand the navigator an array instead of a directive.

        This discards the input, which is the whole point of a pause.

    .PARAMETER Message
        Prompt shown while waiting.

    .EXAMPLE
        Wait-PimKey 'Press Enter to continue'
    #>
    [CmdletBinding()]
    [OutputType([void])]
    param(
        [Parameter(Position = 0)]
        [string]$Message = 'Press Enter to continue'
    )

    $null = Read-Host -Prompt $Message
}
