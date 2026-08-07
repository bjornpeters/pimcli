function Format-PimTimeSpan {
    <#
    .SYNOPSIS
        Formats a duration for display in a list.

    .DESCRIPTION
        Renders as hours and minutes, e.g. '5h 42m'. A null span, which is what
        a permanent assignment has, renders as an em dash rather than as zero,
        so 'no expiry' never reads as 'expired'.

    .PARAMETER TimeSpan
        The duration to format.

    .EXAMPLE
        Format-PimTimeSpan -TimeSpan $role.TimeRemaining
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Position = 0)]
        [AllowNull()]
        [nullable[timespan]]$TimeSpan
    )

    if ($null -eq $TimeSpan) {
        return '-'
    }

    # PowerShell unwraps a [nullable[T]] parameter to a plain T, so the value is
    # used directly here. Reaching for .Value silently yields $null.
    $span = [timespan]$TimeSpan

    if ($span -le [timespan]::Zero) {
        return 'expired'
    }

    # Floor, not a cast: [int] rounds, so 5h42m would render as '6h 42m' and
    # overstate how long the access has left to run.
    '{0}h {1:00}m' -f [int][Math]::Floor($span.TotalHours), $span.Minutes
}
