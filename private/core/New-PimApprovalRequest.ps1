function New-PimApprovalRequest {
    <#
    .SYNOPSIS
        Builds a provider-neutral pending-approval object.

    .DESCRIPTION
        Represents somebody else's activation request that the signed-in user is
        an approver for. Both PIM surfaces model approvals as a request with one
        or more approval stages, so the shape below holds for either.

    .PARAMETER Provider
        Name of the provider that produced this request.

    .PARAMETER RequestId
        Provider-native identifier of the activation request.

    .PARAMETER ApprovalId
        Provider-native identifier of the approval attached to the request. This
        is what a decision is recorded against.

    .PARAMETER RoleName
        Display name of the role being requested.

    .PARAMETER ScopeName
        Display name of the scope the request targets.

    .PARAMETER ScopeType
        Kind of scope, e.g. 'subscription', 'resourcegroup', 'Directory'.

    .PARAMETER RequestorName
        Display name of the principal who raised the request.

    .PARAMETER Justification
        Business justification the requestor supplied.

    .PARAMETER Status
        Current status of the request, e.g. 'PendingApproval'.

    .PARAMETER RequestedOn
        When the request was raised.

    .PARAMETER StartTime
        Requested start of the access. Null means immediate.

    .PARAMETER Duration
        Requested duration, as reported by the provider (an ISO 8601 duration
        for both surfaces today).

    .PARAMETER TicketNumber
        Reference ticket number, when the policy requires one.

    .PARAMETER TicketSystem
        Reference ticket system, when the policy requires one.

    .PARAMETER Raw
        The untouched provider payload this object was projected from.

    .EXAMPLE
        New-PimApprovalRequest -Provider Azure -RequestId $id -RoleName Owner
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)]
        [string]$Provider,

        [Parameter()]
        [string]$RequestId,

        [Parameter()]
        [string]$ApprovalId,

        [Parameter(Mandatory)]
        [string]$RoleName,

        [Parameter()]
        [string]$ScopeName,

        [Parameter()]
        [string]$ScopeType,

        [Parameter()]
        [string]$RequestorName,

        [Parameter()]
        [string]$Justification,

        [Parameter()]
        [string]$Status,

        [Parameter()]
        [nullable[datetime]]$RequestedOn,

        [Parameter()]
        [nullable[datetime]]$StartTime,

        [Parameter()]
        [string]$Duration,

        [Parameter()]
        [string]$TicketNumber,

        [Parameter()]
        [string]$TicketSystem,

        [Parameter()]
        [object]$Raw
    )

    [PSCustomObject]@{
        PSTypeName    = 'Pim.ApprovalRequest'
        Provider      = $Provider
        RequestId     = $RequestId
        ApprovalId    = $ApprovalId
        RoleName      = $RoleName
        ScopeName     = $ScopeName
        ScopeType     = $ScopeType
        RequestorName = $RequestorName
        Justification = $Justification
        Status        = $Status
        RequestedOn   = $RequestedOn
        StartTime     = $StartTime
        Duration      = $Duration
        TicketNumber  = $TicketNumber
        TicketSystem  = $TicketSystem
        Raw           = $Raw
    }
}
