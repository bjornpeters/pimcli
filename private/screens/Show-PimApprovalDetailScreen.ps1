function Show-PimApprovalDetailScreen {
    <#
    .SYNOPSIS
        Shows one pending request in full and records a decision on it.

    .DESCRIPTION
        The detail view an approver needs before deciding: who asked, for what,
        where, why, for how long, and against which ticket.

        A decision grants or withholds privileged access, so it is confirmed
        before it is sent and the justification is never defaulted on the user's
        behalf.

    .PARAMETER Session
        The shared session state.

    .PARAMETER Context
        Screen state. Requires a Request key holding a Pim.ApprovalRequest, and
        optionally a Parent key holding the list screen's context so the list
        can be invalidated after a decision.

    .EXAMPLE
        Show-PimApprovalDetailScreen -Session $session -Context @{ Request = $request }
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory)]
        [hashtable]$Session,

        [Parameter()]
        [hashtable]$Context = @{}
    )

    $request = $Context['Request']

    if (-not $request) {
        Write-PimMessage -Type Error -Message 'No request was passed to the approval screen.'
        Wait-PimKey 'Press Enter to go back'
        return New-PimNavigation -Action Pop
    }

    Show-PimHeader -Title 'Review request' -Session $Session

    $unset = { param($value) if ([string]::IsNullOrWhiteSpace($value)) { 'n/a' } else { $value } }

    Write-PimMessage -Type Heading -Message 'Request'
    Write-PimMessage "  Requestor:     $(& $unset $request.RequestorName)"
    Write-PimMessage "  Role:          $($request.RoleName)"
    Write-PimMessage "  Scope:         $(& $unset $request.ScopeName)"
    Write-PimMessage "  Scope type:    $(& $unset $request.ScopeType)"
    Write-PimMessage "  Source:        $($request.Provider)"
    Write-PimMessage "  Status:        $(& $unset $request.Status)"
    Write-PimMessage ''

    Write-PimMessage -Type Heading -Message 'Justification'
    Write-PimMessage "  $(& $unset $request.Justification)"
    Write-PimMessage ''

    Write-PimMessage -Type Heading -Message 'Schedule'
    Write-PimMessage "  Requested on:  $(if ($request.RequestedOn) { $request.RequestedOn.ToString('yyyy-MM-dd HH:mm') } else { 'unknown' })"
    Write-PimMessage "  Starts:        $(if ($request.StartTime) { $request.StartTime.ToString('yyyy-MM-dd HH:mm') } else { 'immediately' })"
    Write-PimMessage "  Duration:      $(& $unset $request.Duration)"
    Write-PimMessage ''

    Write-PimMessage -Type Heading -Message 'Ticket'
    Write-PimMessage "  Number:        $(& $unset $request.TicketNumber)"
    Write-PimMessage "  System:        $(& $unset $request.TicketSystem)"
    Write-PimMessage ''

    Write-PimMessage -Type Muted -Message "  Approval ID:   $(Get-PimIdLeaf -Id $request.ApprovalId)"

    Show-PimFooter -Key ([ordered]@{ a = 'approve'; d = 'deny' }) -NoRefresh

    $choice = Read-PimChoice -Prompt 'Decision' -Key @{ a = 'Approve'; d = 'Deny' }

    $decision = switch ($choice.Type) {
        'Action' { $choice.Action }
        'Back'   { return New-PimNavigation -Action Pop }
        'Quit'   { return New-PimNavigation -Action Exit }
        default  { $null }
    }

    if (-not $decision) {
        return New-PimNavigation -Action Stay
    }

    $reason = (Read-Host -Prompt "Justification for this $($decision.ToLowerInvariant())").Trim()

    if ([string]::IsNullOrWhiteSpace($reason)) {
        # This is written to the audit record and read by whoever reviews the
        # decision later, so it is not something to fill in automatically.
        Write-PimMessage -Type Error -Message 'A justification is required to record a decision.'
        Wait-PimKey 'Press Enter to try again'
        return New-PimNavigation -Action Stay
    }

    Write-PimMessage ''
    $confirm = (Read-Host -Prompt "$decision '$($request.RoleName)' for $($request.RequestorName)? (y/N)").Trim()

    if ($confirm -notin @('y', 'Y')) {
        Write-PimMessage -Type Muted -Message 'No decision recorded.'
        Wait-PimKey 'Press Enter to continue'
        return New-PimNavigation -Action Stay
    }

    $result = Invoke-PimProviderOperation -Operation NewDecision -Provider $request.Provider -Arguments @{
        ApprovalId   = $request.ApprovalId
        Reason       = $reason
        ReviewResult = $decision
        Confirm      = $false
    }

    Write-PimMessage ''

    if ($result.Errors.Count -gt 0 -or $result.Unavailable.Count -gt 0) {
        Show-PimProviderNote -Result $result
        Wait-PimKey 'Press Enter to continue'
        return New-PimNavigation -Action Stay
    }

    Write-PimMessage -Type Success -Message "Decision '$decision' recorded."

    # The request is no longer pending, so the list behind this screen is stale.
    if ($Context['Parent']) {
        $Context['Parent'].Remove('Result')
    }

    Wait-PimKey 'Press Enter to continue'
    New-PimNavigation -Action Pop
}
