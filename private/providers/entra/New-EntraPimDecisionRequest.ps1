function New-EntraPimDecisionRequest {
    <#
    .SYNOPSIS
        Records an approve or deny decision on an Entra ID PIM request.

    .DESCRIPTION
        Not implemented yet.

        When implemented:
            PATCH {graph}/roleManagement/directory/roleAssignmentApprovals/
                  {approvalId}/steps/{stepId}

        with reviewResult 'Approve' or 'Deny' and a justification.

        ARM PUTs a whole stage; Graph PATCHes a step. The neutral parameters
        below are the same either way.

    .PARAMETER ApprovalId
        Graph identifier of the approval.

    .PARAMETER Reason
        Justification recorded with the decision.

    .PARAMETER ReviewResult
        The decision to record.

    .EXAMPLE
        New-EntraPimDecisionRequest -ApprovalId $id -Reason 'Approved for incident 1234' -ReviewResult Approve
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    [OutputType([pscustomobject])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSShouldProcess', '',
        Justification = 'Declared now so both providers present the same parameters to the dispatcher; ShouldProcess is called once the request is implemented.'
    )]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$ApprovalId,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Reason,

        [Parameter(Mandatory)]
        [ValidateSet('Approve', 'Deny', 'NotReviewed')]
        [string]$ReviewResult
    )

    throw [System.NotImplementedException]::new('Entra ID support is not wired up yet')
}
