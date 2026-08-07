function Get-PimProvider {
    <#
    .SYNOPSIS
        Returns registered PIM providers, optionally narrowed by the session scope.

    .DESCRIPTION
        With no parameters this returns every registered provider. Pass -Scope
        to honour the user's current scope filter, which is what the screens do
        so that a filter of 'Azure' never costs a Graph call.

    .PARAMETER Name
        Return only the named provider.

    .PARAMETER Scope
        Session scope filter: 'All', 'Azure' or 'Entra'.

    .EXAMPLE
        Get-PimProvider -Scope $Session.Scope
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter()]
        [string]$Name,

        [Parameter()]
        [ValidateSet('All', 'Azure', 'Entra')]
        [string]$Scope = 'All'
    )

    Initialize-PimProvider

    if ($Name) {
        if (-not $script:PimProviders.Contains($Name)) {
            throw "Unknown PIM provider '$Name'. Registered providers: $($script:PimProviders.Keys -join ', ')."
        }
        return $script:PimProviders[$Name]
    }

    foreach ($key in $script:PimProviders.Keys) {
        if ($Scope -eq 'All' -or $Scope -eq $key) {
            $script:PimProviders[$key]
        }
    }
}
