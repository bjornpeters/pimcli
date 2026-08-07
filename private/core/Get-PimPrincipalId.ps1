function Get-PimPrincipalId {
    <#
    .SYNOPSIS
        Resolves the signed-in identity to its directory object ID.

    .DESCRIPTION
        Both PIM surfaces key activations off the principal's object ID, a GUID.
        Get-AzContext only offers Account.Id, which for a user is a UPN, so it
        cannot be handed to the API directly. This resolves the real object ID
        once per session instead of at every call site.

        Returns $null when the identity cannot be resolved rather than throwing,
        so a read-only session still works; the write paths are the ones that
        need the ID and can fail loudly on their own.

    .PARAMETER Context
        The Azure context to resolve, from Get-AzContext.

    .EXAMPLE
        $principalId = Get-PimPrincipalId -Context (Get-AzContext)
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [object]$Context
    )

    $account = $Context.Account

    if (-not $account) {
        Write-Verbose 'No account on the Azure context; cannot resolve a principal ID.'
        return $null
    }

    # An account ID that is already a GUID is a managed identity or a
    # service principal object ID, so there is nothing to look up.
    $parsed = [guid]::Empty
    if ([guid]::TryParse($account.Id, [ref]$parsed) -and $account.Type -ne 'ServicePrincipal') {
        return $account.Id
    }

    try {
        switch ($account.Type) {
            'ServicePrincipal' {
                $principal = Get-AzADServicePrincipal -ApplicationId $account.Id -ErrorAction Stop
                return $principal.Id
            }
            default {
                $principal = Get-AzADUser -SignInName $account.Id -ErrorAction Stop
                return $principal.Id
            }
        }
    }
    catch {
        Write-Verbose "Could not resolve a principal ID for '$($account.Id)': $($_.Exception.Message)"
        return $null
    }
}
