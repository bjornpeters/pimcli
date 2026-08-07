function New-AzPimActivationRequest {
    <#
    .SYNOPSIS
        Submits a self-activation request for an eligible Azure resource role.

    .DESCRIPTION
        Not implemented yet.

        This replaces New-AzPimRoleActivationRequest, which reported success
        without submitting anything: it built a request body, left the
        Invoke-RestMethod commented out, and returned a fabricated response with
        Success = $true. Menu option 2 told users their role was activated while
        nothing had been sent. Throwing is the honest behaviour until the call
        is real.

        Three further defects in that version to avoid when implementing:

        - It POSTed to roleEligibilityScheduleRequests, which grants
          eligibility. Self-activation belongs on
          roleAssignmentScheduleRequests with requestType 'SelfActivate'.
        - It called (Get-Date).AddHours($n).Hour(), but Hour is a property on
          DateTime, not a method, so the function threw before reaching the
          request at all.
        - It used (Get-AzContext).Account.Id as principalId, which is a UPN.
          Use the object ID resolved by Get-PimPrincipalId.

    .PARAMETER RoleDefinitionId
        Resource ID of the role definition to activate.

    .PARAMETER ScopeId
        ARM resource ID the activation applies at.

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
        New-AzPimActivationRequest -RoleDefinitionId $id -ScopeId $scope -PrincipalId $me -Justification 'Incident 1234'
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

    throw [System.NotImplementedException]::new('activating Azure roles is not wired up yet')
}
