function Show-PimActivateDetailScreen {
    <#
    .SYNOPSIS
        Collects activation details for a role and submits the request.

    .DESCRIPTION
        The same form for both surfaces, because the inputs PIM needs are the
        same either way: how long, and why. The provider behind it is taken from
        the selected role rather than asked for again.

        Duration and justification are prompted for here and validated before
        anything is submitted. Once the role management policy is wired up, the
        maximum duration and whether justification or a ticket is mandatory
        should come from the policy rather than from the defaults below.

    .PARAMETER Session
        The shared session state.

    .PARAMETER Context
        Screen state. Requires a Role key holding a Pim.EligibleRole.

    .EXAMPLE
        Show-PimActivateDetailScreen -Session $session -Context @{ Role = $role }
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory)]
        [hashtable]$Session,

        [Parameter()]
        [hashtable]$Context = @{}
    )

    $role = $Context['Role']

    if (-not $role) {
        Write-PimMessage -Type Error -Message 'No role was passed to the activation screen.'
        Wait-PimKey 'Press Enter to go back'
        return New-PimNavigation -Action Pop
    }

    Show-PimHeader -Title 'Activate a role' -Session $Session

    Write-PimMessage "  Role:    $($role.RoleName)"
    Write-PimMessage "  Scope:   $($role.ScopeName)"
    Write-PimMessage "  Type:    $($role.ScopeType)"
    Write-PimMessage "  Source:  $($role.Provider)"
    Write-PimMessage ''

    $defaultDuration = 8
    $durationInput = (Read-Host -Prompt "Duration in hours (default $defaultDuration, 'b' to go back)").Trim()

    if ($durationInput -eq 'b') {
        return New-PimNavigation -Action Pop
    }

    $duration = $defaultDuration
    if (-not [string]::IsNullOrWhiteSpace($durationInput)) {
        $parsed = 0
        if (-not [int]::TryParse($durationInput, [ref]$parsed) -or $parsed -lt 1 -or $parsed -gt 24) {
            Write-PimMessage -Type Error -Message 'Duration must be a whole number of hours between 1 and 24.'
            Wait-PimKey 'Press Enter to try again'
            return New-PimNavigation -Action Stay
        }
        $duration = $parsed
    }

    $justification = (Read-Host -Prompt 'Justification').Trim()

    if ([string]::IsNullOrWhiteSpace($justification)) {
        # No silent default here. A justification is written to the audit record
        # and read by an approver, so a placeholder the user did not write is
        # worse than asking again.
        Write-PimMessage -Type Error -Message 'A justification is required.'
        Wait-PimKey 'Press Enter to try again'
        return New-PimNavigation -Action Stay
    }

    Write-PimMessage ''
    Write-PimMessage -Type Info -Message "Submitting activation request for '$($role.RoleName)'..."

    $result = Invoke-PimProviderOperation -Operation NewActivation -Provider $role.Provider -Arguments @{
        RoleDefinitionId = $role.RoleDefinitionId
        ScopeId          = $role.ScopeId
        PrincipalId      = if ($role.PrincipalId) { $role.PrincipalId } else { $Session.PrincipalId }
        Justification    = $justification
        DurationInHours  = $duration
    }

    Write-PimMessage ''

    if ($result.Errors.Count -gt 0 -or $result.Unavailable.Count -gt 0) {
        Show-PimProviderNote -Result $result
    }
    else {
        Write-PimMessage -Type Success -Message 'Activation request submitted.'
    }

    Wait-PimKey 'Press Enter to continue'

    # Back to the eligible list, which refreshes itself on the way in only if
    # its cache was dropped; the state of the activation is shown by 'My active
    # roles' rather than here.
    New-PimNavigation -Action Pop
}
