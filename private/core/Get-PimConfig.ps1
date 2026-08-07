function Get-PimConfig {
    <#
    .SYNOPSIS
        Returns the shared endpoint and API-version configuration for pimcli.

    .DESCRIPTION
        Every REST call in this module resolves its base URI, token audience and
        api-version through this function instead of hard-coding them inline.

        The API versions below are the ones the module already calls in
        production and are deliberately kept as-is; consolidating them here is a
        move, not an upgrade. Changing any of these values changes the wire
        format of a live call, so treat a bump as its own reviewed change.

    .EXAMPLE
        (Get-PimConfig).Arm.BaseUri
    #>
    [CmdletBinding()]
    param()

    if (-not $script:PimConfig) {
        $script:PimConfig = @{
            Arm = @{
                DisplayName = 'Azure resources'
                BaseUri     = 'https://management.azure.com'
                Audience    = 'https://management.azure.com'
                ApiVersion  = @{
                    RoleEligibilitySchedule       = '2020-10-01'
                    RoleAssignmentSchedule        = '2020-10-01'
                    RoleAssignmentScheduleRequest = '2022-04-01-preview'
                    RoleManagementPolicy          = '2020-10-01'
                    RoleAssignmentApproval        = '2021-01-01-preview'
                }
            }
            Graph = @{
                DisplayName = 'Entra ID'
                BaseUri     = 'https://graph.microsoft.com/v1.0'
                BetaUri     = 'https://graph.microsoft.com/beta'
                Audience    = 'https://graph.microsoft.com'
                # Graph versions its PIM surface through the URI, not a query
                # string, so there is no per-endpoint api-version to pin here.
                ApiVersion  = @{}
            }
        }
    }

    $script:PimConfig
}
