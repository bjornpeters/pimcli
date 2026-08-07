function Get-EntraPimActiveRole {
    <#
    .SYNOPSIS
        Returns the Entra ID directory roles that are currently active for the user.

    .DESCRIPTION
        Not implemented yet.

        When implemented:
            GET {graph}/roleManagement/directory/roleAssignmentScheduleInstances
                ?$filter=principalId eq '{principalId}'
                &$expand=roleDefinition,directoryScope

        Instances, not schedules: the instances collection is what is live right
        now, which is the question this screen asks.

        Project through New-PimActiveRole with Provider 'Entra'. Set
        AssignmentType from assignmentType, where 'Activated' is a PIM
        activation and 'Assigned' is a standing assignment.

    .EXAMPLE
        Get-EntraPimActiveRole
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param()

    throw [System.NotImplementedException]::new('Entra ID support is not wired up yet')
}
