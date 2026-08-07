function New-EntraPimActivationRequest {
    <#
    .SYNOPSIS
        Submits a self-activation request for an eligible Entra ID directory role.

    .DESCRIPTION
        Not implemented yet.

        When implemented:
            POST {graph}/roleManagement/directory/roleAssignmentScheduleRequests

        with action 'selfActivate', principalId, roleDefinitionId,
        directoryScopeId ('/' for tenant-wide), justification and a
        scheduleInfo block carrying an ISO 8601 duration.

        Note the naming difference from ARM: Graph calls the field 'action' with
        value 'selfActivate', where ARM uses 'requestType' with value
        'SelfActivate'. Same operation, different casing and key.

    .PARAMETER RoleDefinitionId
        Graph identifier of the directory role definition.

    .PARAMETER ScopeId
        Directory scope ID. '/' for tenant-wide.

    .PARAMETER PrincipalId
        Object ID of the principal activating the role.

    .PARAMETER Justification
        Business justification for the activation.

    .PARAMETER DurationInHours
        How long the activation should last.

    .PARAMETER TicketNumber
        Reference ticket number, when the role policy requires one.

    .PARAMETER TicketSystem
        Reference ticket system, when the role policy requires one.

    .EXAMPLE
        New-EntraPimActivationRequest -RoleDefinitionId $id -ScopeId '/' -PrincipalId $me -Justification 'Incident 1234'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([pscustomobject])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSShouldProcess', '',
        Justification = 'Declared now so both providers present the same parameters to the dispatcher; ShouldProcess is called once the request is implemented.'
    )]
    param(
        [Parameter(Mandatory)]
        [string]$RoleDefinitionId,

        [Parameter(Mandatory)]
        [string]$ScopeId,

        [Parameter(Mandatory)]
        [string]$PrincipalId,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Justification,

        [Parameter()]
        [ValidateRange(1, 24)]
        [int]$DurationInHours = 8,

        [Parameter()]
        [string]$TicketNumber,

        [Parameter()]
        [string]$TicketSystem
    )

    throw [System.NotImplementedException]::new('Entra ID support is not wired up yet')
}
