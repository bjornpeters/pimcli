function Get-EntraPimApprovalRequest {
    <#
    .SYNOPSIS
        Returns Entra ID PIM requests awaiting the signed-in user's decision.

    .DESCRIPTION
        Not implemented yet.

        When implemented:
            GET {graph}/roleManagement/directory/roleAssignmentApprovals
                ?$filter=steps/any(s: s/reviewedBy/id eq '{principalId}'
                                      and s/status eq 'InProgress')

        Graph models this as approvals with steps, where ARM uses approvals with
        stages. Same concept, different noun; both collapse to the neutral
        Pim.ApprovalRequest shape, so this is a projection difference rather
        than a second flow.

    .EXAMPLE
        Get-EntraPimApprovalRequest
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param()

    throw [System.NotImplementedException]::new('Entra ID support is not wired up yet')
}
