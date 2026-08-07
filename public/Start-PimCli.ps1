function Start-PimCli {
    <#
    .SYNOPSIS
        Starts the interactive Privileged Identity Management CLI.

    .DESCRIPTION
        Signs in through Az.Accounts, builds the session state, and hands
        control to the screen loop.

        The tool covers both PIM surfaces. Navigation is action-first: the menu
        asks what you want to do, and Azure resource roles and Entra ID
        directory roles appear together in the resulting list with a Source
        column. Use the scope filter to narrow to one surface.

        Keys are the same on every screen: numbers select, 'b' goes back, 'r'
        refreshes, 'q' quits.

    .PARAMETER Scope
        Surface filter to start with. Defaults to 'All', which merges both.

    .EXAMPLE
        Start-PimCli

    .EXAMPLE
        Start-PimCli -Scope Azure

        Starts with the lists narrowed to Azure resource PIM, so no Graph calls
        are made until the scope is widened.
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [ValidateSet('All', 'Azure', 'Entra')]
        [string]$Scope = 'All'
    )

    if (-not (Get-Module -ListAvailable -Name Az.Accounts)) {
        throw "pimcli requires the Az.Accounts module. Install it with: Install-Module -Name Az.Accounts -Scope CurrentUser"
    }

    $session = $null

    try {
        Clear-Host
        Show-PimBanner

        $session = Connect-PimSession
        $session.Scope = $Scope

        if (-not $session.PrincipalId) {
            # Reads mostly work without it, but every activation needs the
            # object ID, so say so now rather than at the point of failure.
            Write-PimMessage -Type Warning -Message 'Could not resolve your directory object ID. Activation may not work in this session.'
        }

        Start-Sleep -Seconds 1

        Invoke-PimNavigation -Session $session
    }
    finally {
        # Ends this module's session only. The Az sign-in is left alone, since
        # it is shared with everything else in the PowerShell session.
        Disconnect-PimSession -Session $session -Confirm:$false
        Clear-Host
        Write-PimMessage -Type Muted -Message 'pimcli session ended.'
    }
}
