function Show-PimActiveRoleScreen {
    <#
    .SYNOPSIS
        Lists the roles that are active right now, across both surfaces.

    .DESCRIPTION
        A single answer to 'what am I holding at the moment', merged across
        Azure resource roles and Entra ID directory roles, with the time left on
        each.

        Selecting a row starts an early deactivation, which is the other half of
        why this view is worth merging: standing down cleanly is easier when
        everything currently held is on one screen.

    .PARAMETER Session
        The shared session state.

    .PARAMETER Context
        Screen state. Caches the fetched assignments between renders.

    .EXAMPLE
        Show-PimActiveRoleScreen -Session $session -Context @{}
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory)]
        [hashtable]$Session,

        [Parameter()]
        [hashtable]$Context = @{}
    )

    Show-PimHeader -Title 'My active roles' -Session $Session

    if (-not $Context.ContainsKey('Result')) {
        Write-PimMessage -Type Info -Message 'Retrieving your active roles...'
        $Context['Result'] = Invoke-PimProviderOperation -Operation GetActiveRole -Scope $Session.Scope
        Show-PimHeader -Title 'My active roles' -Session $Session
    }

    $result = $Context['Result']
    $roles = @($result.Items | Sort-Object EndTime, Provider, RoleName)

    Show-PimProviderNote -Result $result

    if ($roles.Count -eq 0) {
        Write-PimMessage -Type Warning -Message 'No active roles found for the current scope.'
    }
    else {
        Show-PimTable -Item $roles -Column @(
            @{ Header = 'Role';   Expression = { $_.RoleName } }
            @{ Header = 'Scope';  Expression = { $_.ScopeName } }
            @{ Header = 'Kind';   Expression = { $_.AssignmentType } }
            @{ Header = 'Expires'; Expression = {
                if ($_.EndTime) { $_.EndTime.ToString('yyyy-MM-dd HH:mm') } else { 'permanent' }
            } }
            @{ Header = 'Left';   Expression = { Format-PimTimeSpan -TimeSpan $_.TimeRemaining } }
            @{ Header = 'Source'; Expression = { $_.Provider } }
        )
    }

    Show-PimFooter -Key @{ s = 'change scope' }

    $choice = Read-PimChoice -Prompt 'Select a role to deactivate' -MaxIndex $roles.Count -Key @{ s = 'Scope' }

    switch ($choice.Type) {
        'Index' {
            $selected = $roles[$choice.Index]

            if ($selected.AssignmentType -eq 'Assigned') {
                # A standing assignment was never activated through PIM, so
                # there is nothing to stand down.
                Write-PimMessage -Type Warning -Message 'That is a permanent assignment, not a PIM activation, so it cannot be deactivated here.'
                Wait-PimKey 'Press Enter to continue'
                return New-PimNavigation -Action Stay
            }

            Write-PimMessage ''
            $confirm = (Read-Host -Prompt "Deactivate '$($selected.RoleName)' on '$($selected.ScopeName)'? (y/N)").Trim()

            if ($confirm -notin @('y', 'Y')) {
                return New-PimNavigation -Action Stay
            }

            $removal = Invoke-PimProviderOperation -Operation RemoveActiveRole -Provider $selected.Provider -Arguments @{
                RoleDefinitionId = $selected.RoleDefinitionId
                ScopeId          = $selected.ScopeId
                PrincipalId      = if ($selected.PrincipalId) { $selected.PrincipalId } else { $Session.PrincipalId }
            }

            Write-PimMessage ''

            if ($removal.Errors.Count -gt 0 -or $removal.Unavailable.Count -gt 0) {
                Show-PimProviderNote -Result $removal
            }
            else {
                Write-PimMessage -Type Success -Message 'Deactivation submitted.'
                $Context.Remove('Result')
            }

            Wait-PimKey 'Press Enter to continue'
            return New-PimNavigation -Action Stay
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
