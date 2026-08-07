function Show-PimScopeScreen {
    <#
    .SYNOPSIS
        Changes which PIM surfaces the lists cover.

    .DESCRIPTION
        The scope filter is the release valve for action-first navigation. It
        defaults to All, which merges both surfaces, and narrowing it means the
        other provider is never queried, so a user who only works with Azure
        pays no Graph round trip.

    .PARAMETER Session
        The shared session state. Scope is written back to it here.

    .PARAMETER Context
        Unused; present because every screen takes the same parameters.

    .EXAMPLE
        Show-PimScopeScreen -Session $session -Context @{}
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory)]
        [hashtable]$Session,

        [Parameter()]
        [hashtable]$Context = @{}
    )

    Show-PimHeader -Title 'Scope' -Session $Session

    $options = @('All', 'Azure', 'Entra')

    Write-PimMessage 'Which surfaces should the lists cover?'
    Write-PimMessage ''

    for ($i = 0; $i -lt $options.Count; $i++) {
        $marker = if ($Session.Scope -eq $options[$i]) { '*' } else { ' ' }
        Write-PimMessage "$marker $($i + 1)  $(Get-PimScopeLabel -Scope $options[$i])"
    }

    Show-PimFooter -NoRefresh

    $choice = Read-PimChoice -Prompt 'Select' -MaxIndex $options.Count

    switch ($choice.Type) {
        'Index' {
            $Session.Scope = $options[$choice.Index]
            return New-PimNavigation -Action Pop
        }
        'Back' { return New-PimNavigation -Action Pop }
        'Quit' { return New-PimNavigation -Action Exit }
    }

    New-PimNavigation -Action Stay
}
