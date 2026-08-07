function New-PimActiveRole {
    <#
    .SYNOPSIS
        Builds a provider-neutral active-role object.

    .DESCRIPTION
        The counterpart to New-PimEligibleRole for assignments that are live
        right now. TimeRemaining is derived here rather than in each provider so
        the value is computed one way everywhere.

    .PARAMETER Provider
        Name of the provider that produced this assignment.

    .PARAMETER RoleName
        Display name of the active role.

    .PARAMETER RoleDefinitionId
        Provider-native identifier of the role definition.

    .PARAMETER ScopeName
        Display name of the scope the assignment applies to.

    .PARAMETER ScopeId
        Provider-native identifier of the scope.

    .PARAMETER ScopeType
        Kind of scope, e.g. 'subscription', 'resourcegroup', 'Directory'.

    .PARAMETER AssignmentId
        Provider-native identifier of the assignment itself, needed to end it
        early.

    .PARAMETER PrincipalId
        Object ID of the principal holding the assignment.

    .PARAMETER AssignmentType
        'Activated' for a time-bound PIM activation, 'Assigned' for a standing
        assignment that was never activated through PIM.

    .PARAMETER StartTime
        When the assignment became active.

    .PARAMETER EndTime
        When the assignment expires. Null for a permanent assignment.

    .PARAMETER Raw
        The untouched provider payload this object was projected from.

    .EXAMPLE
        New-PimActiveRole -Provider Entra -RoleName 'Global Reader' -EndTime $end
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
        [string]$AssignmentId,

        [Parameter()]
        [string]$PrincipalId,

        [Parameter()]
        [ValidateSet('Activated', 'Assigned', 'Unknown')]
        [string]$AssignmentType = 'Unknown',

        [Parameter()]
        [nullable[datetime]]$StartTime,

        [Parameter()]
        [nullable[datetime]]$EndTime,

        [Parameter()]
        [object]$Raw
    )

    # A permanent assignment has no end date, so it has no remaining time to
    # report rather than a remaining time of zero.
    # PowerShell unwraps a [nullable[T]] parameter to a plain T, so the value is
    # used directly here. Reaching for .Value silently yields $null.
    $remaining = $null
    if ($EndTime) {
        $span = ([datetime]$EndTime) - (Get-Date)
        $remaining = if ($span -gt [timespan]::Zero) { $span } else { [timespan]::Zero }
    }

    [PSCustomObject]@{
        PSTypeName       = 'Pim.ActiveRole'
        Provider         = $Provider
        RoleName         = $RoleName
        RoleDefinitionId = $RoleDefinitionId
        ScopeName        = $ScopeName
        ScopeId          = $ScopeId
        ScopeType        = $ScopeType
        AssignmentId     = $AssignmentId
        PrincipalId      = $PrincipalId
        AssignmentType   = $AssignmentType
        StartTime        = $StartTime
        EndTime          = $EndTime
        TimeRemaining    = $remaining
        Raw              = $Raw
    }
}
