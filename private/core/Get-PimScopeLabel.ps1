function Get-PimScopeLabel {
    <#
    .SYNOPSIS
        Turns a scope filter value into the label shown in the UI.

    .PARAMETER Scope
        The session scope filter: 'All', 'Azure' or 'Entra'.

    .EXAMPLE
        Get-PimScopeLabel -Scope Entra
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [ValidateSet('All', 'Azure', 'Entra')]
        [string]$Scope
    )

    switch ($Scope) {
        'Azure' { 'Azure resources' }
        'Entra' { 'Entra ID' }
        default { 'All surfaces' }
    }
}
