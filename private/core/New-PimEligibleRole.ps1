function New-PimEligibleRole {
    <#
    .SYNOPSIS
        Builds a provider-neutral eligible-role object.

    .DESCRIPTION
        Azure resource PIM and Entra ID role PIM return structurally different
        payloads for the same concept. Every provider projects its payload
        through this factory so the screens only ever see one shape, and a new
        provider costs a projection rather than a new set of screens.

        The original payload is kept on the Raw property so provider-specific
        code further down the flow does not have to re-fetch it.

    .PARAMETER Provider
        Name of the provider that produced this role, e.g. 'Azure' or 'Entra'.

    .PARAMETER RoleName
        Display name of the role, e.g. 'Contributor' or 'Global Reader'.

    .PARAMETER RoleDefinitionId
        Provider-native identifier of the role definition.

    .PARAMETER ScopeName
        Display name of the scope the eligibility applies to.

    .PARAMETER ScopeId
        Provider-native identifier of the scope: an ARM resource ID for Azure,
        a directory scope ID for Entra ID.

    .PARAMETER ScopeType
        Kind of scope, e.g. 'subscription', 'resourcegroup', 'Directory'.

    .PARAMETER PrincipalId
        Object ID of the principal the eligibility belongs to.

    .PARAMETER MemberType
        How the eligibility was granted, e.g. 'Direct' or 'Group'.

    .PARAMETER Raw
        The untouched provider payload this object was projected from.

    .EXAMPLE
        New-PimEligibleRole -Provider Azure -RoleName Owner -ScopeName sub-prod
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)]
        [string]$Provider,

        [Parameter(Mandatory)]
        [string]$RoleName,

        [Parameter()]
        [string]$RoleDefinitionId,

        [Parameter()]
        [string]$ScopeName,

        [Parameter()]
        [string]$ScopeId,

        [Parameter()]
        [string]$ScopeType,

        [Parameter()]
        [string]$PrincipalId,

        [Parameter()]
        [string]$MemberType,

        [Parameter()]
        [object]$Raw
    )

    [PSCustomObject]@{
        PSTypeName       = 'Pim.EligibleRole'
        Provider         = $Provider
        RoleName         = $RoleName
        RoleDefinitionId = $RoleDefinitionId
        ScopeName        = $ScopeName
        ScopeId          = $ScopeId
        ScopeType        = $ScopeType
        PrincipalId      = $PrincipalId
        MemberType       = $MemberType
        Raw              = $Raw
    }
}
