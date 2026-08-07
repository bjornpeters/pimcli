function Get-AzPimActiveRole {
    <#
    .SYNOPSIS
        Returns the Azure resource roles that are currently active for the user.

    .DESCRIPTION
        Not implemented yet.

        This replaces a version that returned a hard-coded Contributor
        assignment on a fake subscription, presented as if it had come from the
        API. Throwing NotImplementedException means the dispatcher reports the
        surface as unavailable and the screen says so, instead of showing
        fabricated access.

        When implemented: GET roleAssignmentSchedules filtered with asTarget(),
        project through New-PimActiveRole, and set AssignmentType from
        properties.assignmentType so a standing assignment is distinguishable
        from a PIM activation.

    .EXAMPLE
        Get-AzPimActiveRole
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param()

    throw [System.NotImplementedException]::new('reading active Azure roles is not wired up yet')
}
