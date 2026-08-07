function Show-PimApprovalScreen {
    <#
    .SYNOPSIS
        Lists PIM requests waiting on the signed-in user's decision.

    .DESCRIPTION
        Merged across both surfaces, so an approver has one queue to work rather
        than two places to remember to check.

        Sorted oldest first, because the request that has been waiting longest
        is the one holding somebody up.

    .PARAMETER Session
        The shared session state.

    .PARAMETER Context
        Screen state. Caches the fetched requests between renders.

    .EXAMPLE
        Show-PimApprovalScreen -Session $session -Context @{}
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory)]
        [hashtable]$Session,

        [Parameter()]
        [hashtable]$Context = @{}
    )

    Show-PimHeader -Title 'Approvals' -Session $Session

    if (-not $Context.ContainsKey('Result')) {
        Write-PimMessage -Type Info -Message 'Retrieving pending requests...'
        $Context['Result'] = Invoke-PimProviderOperation -Operation GetApprovalRequest -Scope $Session.Scope
        Show-PimHeader -Title 'Approvals' -Session $Session
    }

    $result = $Context['Result']

    # Requests with no timestamp sort last rather than first, so a missing date
    # cannot push an unknown to the top of the queue.
    $requests = @($result.Items | Sort-Object -Property @{
        Expression = { if ($_.RequestedOn) { $_.RequestedOn } else { [datetime]::MaxValue } }
    })

    Show-PimProviderNote -Result $result

    if ($requests.Count -eq 0) {
        Write-PimMessage -Type Warning -Message 'No pending requests for the current scope.'
    }
    else {
        Show-PimTable -Item $requests -Column @(
            @{ Header = 'Requestor'; Expression = { $_.RequestorName } }
            @{ Header = 'Role';      Expression = { $_.RoleName } }
            @{ Header = 'Scope';     Expression = { $_.ScopeName } }
            @{ Header = 'Requested'; Expression = {
                if ($_.RequestedOn) { $_.RequestedOn.ToString('yyyy-MM-dd HH:mm') } else { 'unknown' }
            } }
            @{ Header = 'Source';    Expression = { $_.Provider } }
        )
    }

    Show-PimFooter -Key @{ s = 'change scope' }

    $choice = Read-PimChoice -Prompt 'Select a request to review' -MaxIndex $requests.Count -Key @{ s = 'Scope' }

    switch ($choice.Type) {
        'Index' {
            return New-PimNavigation -Action Push -Screen 'ApprovalDetail' -Context @{
                Request = $requests[$choice.Index]
                # Handed down so the detail screen can invalidate this list
                # after a decision lands.
                Parent  = $Context
            }
        }
        'Action' {
            if ($choice.Action -eq 'Scope') {
                $Context.Remove('Result')
                return New-PimNavigation -Action Push -Screen 'Scope'
            }
        }
        'Refresh' {
            $Context.Remove('Result')
            return New-PimNavigation -Action Stay
        }
        'Back' { return New-PimNavigation -Action Pop }
        'Quit' { return New-PimNavigation -Action Exit }
    }

    New-PimNavigation -Action Stay
}
