function Remove-AzPimActiveRole {
    <#
    .SYNOPSIS
        Ends an active Azure resource role assignment early.

    .DESCRIPTION
        Not implemented yet.

        When implemented: POST to roleAssignmentScheduleRequests with
        requestType 'SelfDeactivate', targeting the same role definition and
        scope as the active assignment.

    .PARAMETER RoleDefinitionId
        Resource ID of the role definition to deactivate.

    .PARAMETER ScopeId
        ARM resource ID the assignment applies at.

    .PARAMETER PrincipalId
        Object ID of the principal holding the assignment.

    .EXAMPLE
        Remove-AzPimActiveRole -RoleDefinitionId $id -ScopeId $scope -PrincipalId $me
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
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
        [string]$PrincipalId
    )

    throw [System.NotImplementedException]::new('deactivating Azure roles is not wired up yet')
}
