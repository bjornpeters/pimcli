function Show-PimProviderNote {
    <#
    .SYNOPSIS
        Reports which providers could not contribute to a merged result.

    .DESCRIPTION
        A merged list is only trustworthy if the user can see what is missing
        from it. This prints one line per provider that failed or is not
        implemented yet, so an empty list is never silently mistaken for 'you
        have no access'.

    .PARAMETER Result
        The result hashtable returned by Invoke-PimProviderOperation.

    .EXAMPLE
        Show-PimProviderNote -Result $result
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [hashtable]$Result
    )

    foreach ($entry in $Result.Unavailable) {
        Write-PimMessage -Type Muted -Message "  $($entry.Provider): $($entry.Message)"
    }

    foreach ($entry in $Result.Errors) {
        Write-PimMessage -Type Error -Message "  $($entry.Provider): $($entry.Message)"
    }

    if ($Result.Unavailable.Count -gt 0 -or $Result.Errors.Count -gt 0) {
        Write-PimMessage ''
    }
}
