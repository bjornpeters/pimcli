function Write-PimMessage {
    <#
    .SYNOPSIS
        Writes a console message in the module's standard colour for its type.

    .DESCRIPTION
        Keeps colour choices in one place instead of spread across every screen,
        so 'this failed' looks the same everywhere.

        This writes to the host on purpose: it is CLI chrome, not data. Anything
        a caller might want to capture should be returned as an object instead.

    .PARAMETER Message
        The text to write.

    .PARAMETER Type
        Which style to use.

    .PARAMETER NoNewLine
        Do not append a newline.

    .EXAMPLE
        Write-PimMessage -Type Success -Message 'Request approved.'
    #>
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSAvoidUsingWriteHost', '',
        Justification = 'Interactive CLI chrome; output is presentation, not data.'
    )]
    param(
        [Parameter(Mandatory, Position = 0)]
        [AllowEmptyString()]
        [string]$Message,

        [Parameter()]
        [ValidateSet('Info', 'Success', 'Warning', 'Error', 'Muted', 'Heading', 'Plain')]
        [string]$Type = 'Plain',

        [Parameter()]
        [switch]$NoNewLine
    )

    $colour = switch ($Type) {
        'Info'    { 'Cyan' }
        'Success' { 'Green' }
        'Warning' { 'Yellow' }
        'Error'   { 'Red' }
        'Muted'   { 'DarkGray' }
        'Heading' { 'Cyan' }
        default   { 'White' }
    }

    Write-Host $Message -ForegroundColor $colour -NoNewline:$NoNewLine
}
