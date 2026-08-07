function ConvertTo-PimDateTime {
    <#
    .SYNOPSIS
        Parses an API timestamp into a DateTime, or $null when absent.

    .DESCRIPTION
        Both PIM surfaces return timestamps as ISO 8601 strings, and both leave
        them out when the value does not apply, e.g. an immediate start or a
        permanent assignment. Parsing in one place keeps 'missing' distinct from
        'epoch' instead of every caller inventing its own fallback.

        Parses as round-trip UTC and returns local time, so a duration shown to
        the user is measured against their own clock.

    .PARAMETER Value
        The raw timestamp from the API.

    .EXAMPLE
        ConvertTo-PimDateTime -Value $properties.createdOn
    #>
    [CmdletBinding()]
    [OutputType([nullable[datetime]])]
    param(
        [Parameter(Position = 0)]
        [AllowNull()]
        [AllowEmptyString()]
        [object]$Value
    )

    if ($null -eq $Value -or [string]::IsNullOrWhiteSpace([string]$Value)) {
        return $null
    }

    if ($Value -is [datetime]) {
        return $Value
    }

    $parsed = [datetime]::MinValue
    $styles = [System.Globalization.DateTimeStyles]::RoundtripKind

    if ([datetime]::TryParse([string]$Value, [cultureinfo]::InvariantCulture, $styles, [ref]$parsed)) {
        return $parsed.ToLocalTime()
    }

    Write-Verbose "Could not parse '$Value' as a timestamp."
    return $null
}
