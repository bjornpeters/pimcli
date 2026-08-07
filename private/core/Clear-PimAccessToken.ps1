function Clear-PimAccessToken {
    <#
    .SYNOPSIS
        Drops every cached access token.

    .DESCRIPTION
        Called when the session ends or the signed-in account changes, so a
        token issued for one identity can never be reused for the next.

    .EXAMPLE
        Clear-PimAccessToken
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param()

    if ($PSCmdlet.ShouldProcess('pimcli token cache', 'Clear')) {
        $script:PimTokenCache = @{}
        Write-Verbose 'Cleared the pimcli token cache.'
    }
}
