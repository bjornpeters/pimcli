function Initialize-PimProvider {
    <#
    .SYNOPSIS
        Populates the provider registry.

    .DESCRIPTION
        A provider is one PIM surface. Each one declares the same set of
        operations, mapped to the function that implements it. The screens never
        name a provider function directly; they ask for an operation and the
        dispatcher resolves it.

        Adding a third surface is a block in this table plus the functions it
        points at. No screen changes.

        An operation mapped to $null is one this provider does not implement
        yet. The dispatcher reports those separately from real failures so a
        half-built surface reads as 'not available yet' rather than as an error,
        and never as 'you have nothing here'.

    .PARAMETER Force
        Rebuild the registry even if it is already populated.

    .EXAMPLE
        Initialize-PimProvider -Force
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [switch]$Force
    )

    if ($script:PimProviders -and -not $Force) {
        return
    }

    $script:PimProviders = [ordered]@{
        Azure = @{
            Name        = 'Azure'
            DisplayName = 'Azure resources'
            Audience    = 'Arm'
            Operations  = @{
                GetEligibleRole    = 'Get-AzPimEligibleRole'
                GetActiveRole      = 'Get-AzPimActiveRole'
                GetApprovalRequest = 'Get-AzPimApprovalRequest'
                NewActivation      = 'New-AzPimActivationRequest'
                NewDecision        = 'New-AzPimDecisionRequest'
                RemoveActiveRole   = 'Remove-AzPimActiveRole'
            }
        }
        Entra = @{
            Name        = 'Entra'
            DisplayName = 'Entra ID'
            Audience    = 'Graph'
            Operations  = @{
                GetEligibleRole    = 'Get-EntraPimEligibleRole'
                GetActiveRole      = 'Get-EntraPimActiveRole'
                GetApprovalRequest = 'Get-EntraPimApprovalRequest'
                NewActivation      = 'New-EntraPimActivationRequest'
                NewDecision        = 'New-EntraPimDecisionRequest'
                RemoveActiveRole   = 'Remove-EntraPimActiveRole'
            }
        }
    }

    Write-Verbose "Registered $($script:PimProviders.Count) PIM providers."
}
