function Get-PimScreen {
    <#
    .SYNOPSIS
        Resolves a screen name to the function that renders it.

    .DESCRIPTION
        The screen registry is the only place a screen name is tied to a
        function. Screens reference each other by name through navigation
        directives, so nothing has to be edited when a screen is added beyond
        this table and the file itself.

        Every screen function takes -Session and -Context and returns a
        navigation directive built by New-PimNavigation.

    .PARAMETER Name
        The registered screen name.

    .EXAMPLE
        Get-PimScreen -Name MainMenu
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [string]$Name
    )

    if (-not $script:PimScreens) {
        $script:PimScreens = @{
            MainMenu       = 'Show-PimMainMenuScreen'
            Activate       = 'Show-PimActivateScreen'
            ActivateDetail = 'Show-PimActivateDetailScreen'
            ActiveRoles    = 'Show-PimActiveRoleScreen'
            Approvals      = 'Show-PimApprovalScreen'
            ApprovalDetail = 'Show-PimApprovalDetailScreen'
            Scope          = 'Show-PimScopeScreen'
        }
    }

    if (-not $script:PimScreens.ContainsKey($Name)) {
        throw "Unknown screen '$Name'. Registered screens: $($script:PimScreens.Keys -join ', ')."
    }

    $script:PimScreens[$Name]
}
