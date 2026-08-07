function Show-PimBanner {
    <#
    .SYNOPSIS
        Writes the CLI banner.

    .DESCRIPTION
        The banner no longer says 'Azure' now that the tool covers both Azure
        resource PIM and Entra ID role PIM.

    .EXAMPLE
        Show-PimBanner
    #>
    [CmdletBinding()]
    param()

    Write-PimMessage -Type Heading -Message '====================================================='
    Write-PimMessage -Type Heading -Message '        Privileged Identity Management CLI           '
    Write-PimMessage -Type Heading -Message '        Azure resources  |  Entra ID                 '
    Write-PimMessage -Type Heading -Message '====================================================='
    Write-PimMessage ''
}
