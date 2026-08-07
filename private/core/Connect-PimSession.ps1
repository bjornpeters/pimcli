function Connect-PimSession {
    <#
    .SYNOPSIS
        Ensures an Azure sign-in and builds the shared session state.

    .DESCRIPTION
        Authentication is Az.Accounts for both surfaces: the ARM token and the
        Graph token are both minted from the same Az context, so there is one
        sign-in regardless of which PIM surface the user works with.

        This replaces the old Connect-AzPim, which followed sign-in with a
        wildcard match over Get-AzRoleAssignment names to guess whether the user
        "has PIM access". That guess was never an authorisation check and only
        ever produced a warning. Whether a user can do anything in PIM is
        answered by the PIM API itself, on the screen that asks it.

    .OUTPUTS
        The session hashtable passed to every screen.

    .EXAMPLE
        $session = Connect-PimSession
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param()

    $context = Get-AzContext -ErrorAction SilentlyContinue

    if (-not $context) {
        Write-PimMessage -Type Warning -Message 'Not signed in to Azure. Starting sign-in...'
        Connect-AzAccount -ErrorAction Stop | Out-Null
        $context = Get-AzContext -ErrorAction Stop
    }

    if (-not $context) {
        throw 'Azure sign-in did not produce a usable context.'
    }

    $accountName = if ($context.Account.Id) {
        $context.Account.Id
    }
    elseif ($context.Account) {
        $context.Account.ToString()
    }
    else {
        'Unknown account'
    }

    Write-PimMessage -Type Success -Message "Signed in as $accountName"

    @{
        Account     = $accountName
        Context     = $context
        TenantId    = $context.Tenant.Id
        PrincipalId = Get-PimPrincipalId -Context $context
        # Action-first navigation means provider is a filter rather than a menu
        # level. 'All' merges both surfaces into every list.
        Scope       = 'All'
    }
}
