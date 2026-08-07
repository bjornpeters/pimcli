function Show-PimMainMenuScreen {
    <#
    .SYNOPSIS
        The main menu.

    .DESCRIPTION
        Navigation is action-first: the top level is what the user wants to do,
        not which surface they want to do it on. Whether a role lives in Azure
        or Entra ID is an attribute of the role, shown as a column and narrowed
        with the scope filter, so nobody has to know where a role lives before
        they can look for it.

        This screen sits at the bottom of the stack, so it offers no 'back'.

    .PARAMETER Session
        The shared session state.

    .PARAMETER Context
        Unused; present because every screen takes the same parameters.

    .EXAMPLE
        Show-PimMainMenuScreen -Session $session -Context @{}
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory)]
        [hashtable]$Session,

        [Parameter()]
        [hashtable]$Context = @{}
    )

    Show-PimHeader -Title 'Main menu' -Session $Session

    Write-PimMessage '  1  Activate a role'
    Write-PimMessage '  2  My active roles'
    Write-PimMessage '  3  Approvals'

    Show-PimFooter -Key @{ s = 'change scope' } -NoBack -NoRefresh

    $choice = Read-PimChoice -Prompt 'Select' -MaxIndex 3 -Key @{ s = 'Scope' } -NoBack

    switch ($choice.Type) {
        'Index' {
            $screen = @('Activate', 'ActiveRoles', 'Approvals')[$choice.Index]
            return New-PimNavigation -Action Push -Screen $screen
        }
        'Action' {
            if ($choice.Action -eq 'Scope') {
                return New-PimNavigation -Action Push -Screen 'Scope'
            }
        }
        'Quit' {
            return New-PimNavigation -Action Exit
        }
    }

    New-PimNavigation -Action Stay
}
