function Show-PimActivateScreen {
    <#
    .SYNOPSIS
        Lists every role the user is eligible to activate, across both surfaces.

    .DESCRIPTION
        One merged list with a Source column rather than a menu level per
        provider. This is the view the portal cannot give you, since it splits
        Azure resource roles and directory roles across separate blades.

        Results are held on the screen's context so paging into a role and
        coming back does not re-query. 'r' drops the cache and re-fetches.

    .PARAMETER Session
        The shared session state.

    .PARAMETER Context
        Screen state. Caches the fetched roles between renders.

    .EXAMPLE
        Show-PimActivateScreen -Session $session -Context @{}
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory)]
        [hashtable]$Session,

        [Parameter()]
        [hashtable]$Context = @{}
    )

    Show-PimHeader -Title 'Activate a role' -Session $Session

    if (-not $Context.ContainsKey('Result')) {
        Write-PimMessage -Type Info -Message 'Retrieving your eligible roles...'
        $Context['Result'] = Invoke-PimProviderOperation -Operation GetEligibleRole -Scope $Session.Scope
        Show-PimHeader -Title 'Activate a role' -Session $Session
    }

    $result = $Context['Result']
    $roles = @($result.Items | Sort-Object Provider, RoleName, ScopeName)

    Show-PimProviderNote -Result $result

    if ($roles.Count -eq 0) {
        Write-PimMessage -Type Warning -Message 'No eligible roles found for the current scope.'
    }
    else {
        Show-PimTable -Item $roles -Column @(
            @{ Header = 'Role';   Expression = { $_.RoleName } }
            @{ Header = 'Scope';  Expression = { $_.ScopeName } }
            @{ Header = 'Type';   Expression = { $_.ScopeType } }
            @{ Header = 'Via';    Expression = { $_.MemberType } }
            @{ Header = 'Source'; Expression = { $_.Provider } }
        )
    }

    Show-PimFooter -Key @{ s = 'change scope' }

    $choice = Read-PimChoice -Prompt 'Select a role to activate' -MaxIndex $roles.Count -Key @{ s = 'Scope' }

    switch ($choice.Type) {
        'Index' {
            return New-PimNavigation -Action Push -Screen 'ActivateDetail' -Context @{ Role = $roles[$choice.Index] }
        }
        'Action' {
            if ($choice.Action -eq 'Scope') {
                # The scope filter decides which providers were queried, so a
                # change to it invalidates this list.
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
