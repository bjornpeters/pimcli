function Get-PimIdLeaf {
    <#
    .SYNOPSIS
        Returns the last segment of a slash-delimited resource ID.

    .DESCRIPTION
        Used to shorten an ARM resource ID down to the GUID for display.

        The previous code did this with
        String.Trim('providers/Microsoft.Authorization/roleAssignmentApprovals/'),
        which does not remove that substring at all: Trim takes a set of
        characters, so it stripped any leading or trailing character that
        appeared anywhere in the string, quietly eating hex digits off both ends
        of the GUID. Splitting on the separator is the correct operation.

    .PARAMETER Id
        The resource ID.

    .EXAMPLE
        Get-PimIdLeaf -Id $request.ApprovalId
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Position = 0)]
        [AllowNull()]
        [AllowEmptyString()]
        [string]$Id
    )

    if ([string]::IsNullOrWhiteSpace($Id)) {
        return ''
    }

    ($Id.TrimEnd('/') -split '/')[-1]
}
