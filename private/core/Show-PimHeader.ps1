function Show-PimHeader {
    <#
    .SYNOPSIS
        Clears the screen and writes the standard screen header.

    .DESCRIPTION
        Gives every screen the same top: banner, the signed-in account, the
        screen title and the active scope filter. Showing the scope on every
        screen matters, because it is the difference between 'you have no
        eligible roles' and 'you have no eligible Azure roles'.

    .PARAMETER Title
        Title of the current screen.

    .PARAMETER Session
        The shared session state.

    .EXAMPLE
        Show-PimHeader -Title 'Activate a role' -Session $Session
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Title,

        [Parameter(Mandatory)]
        [hashtable]$Session
    )

    Clear-Host
    Show-PimBanner

    Write-PimMessage -Type Muted -Message "Account: $($Session.Account)"
    Write-PimMessage ''
    Write-PimMessage -Type Heading -Message $Title
    Write-PimMessage -Type Muted -Message "Scope: $(Get-PimScopeLabel -Scope $Session.Scope)"
    Write-PimMessage ''
}
