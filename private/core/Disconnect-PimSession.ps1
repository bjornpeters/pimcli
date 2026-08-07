function Disconnect-PimSession {
    <#
    .SYNOPSIS
        Ends the pimcli session.

    .DESCRIPTION
        Clears this module's cached tokens and session state. It deliberately
        leaves the Az sign-in alone: the old Disconnect-AzPim called
        Disconnect-AzAccount, which tore down the user's entire Az session,
        including work that had nothing to do with this module.

        Pass -SignOutAzAccount when signing out of Azure altogether really is
        what is wanted.

    .PARAMETER Session
        The session state to clear.

    .PARAMETER SignOutAzAccount
        Also run Disconnect-AzAccount, ending the shared Az sign-in for the
        whole PowerShell session.

    .EXAMPLE
        Disconnect-PimSession -Session $session

    .EXAMPLE
        Disconnect-PimSession -Session $session -SignOutAzAccount
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter()]
        [hashtable]$Session,

        [Parameter()]
        [switch]$SignOutAzAccount
    )

    if ($PSCmdlet.ShouldProcess('pimcli session', 'End')) {
        Clear-PimAccessToken -Confirm:$false

        if ($Session) {
            $Session.Clear()
        }
    }

    if (-not $SignOutAzAccount) {
        return
    }

    if ($PSCmdlet.ShouldProcess('Azure account', 'Sign out')) {
        try {
            Disconnect-AzAccount -ErrorAction Stop | Out-Null
            Write-PimMessage -Type Success -Message 'Signed out of Azure.'
        }
        catch {
            Write-PimMessage -Type Error -Message "Could not sign out of Azure: $($_.Exception.Message)"
        }
    }
}
