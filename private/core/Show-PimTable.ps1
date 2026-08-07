function Show-PimTable {
    <#
    .SYNOPSIS
        Renders a numbered, selectable table of items.

    .DESCRIPTION
        One renderer for every list in the CLI. Items are numbered in the order
        they are passed, and that number is what Read-PimChoice hands back as an
        index, so the display and the selection can never drift apart.

        Columns are declared as hashtables of Header and Expression, where the
        expression is evaluated with the item as $_.

    .PARAMETER Item
        The items to render.

    .PARAMETER Column
        Column definitions, e.g. @{ Header = 'Role'; Expression = { $_.RoleName } }.

    .PARAMETER NoIndex
        Render without the leading number column, for read-only tables.

    .EXAMPLE
        Show-PimTable -Item $roles -Column @(
            @{ Header = 'Role';   Expression = { $_.RoleName } }
            @{ Header = 'Source'; Expression = { $_.Provider } }
        )
    #>
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSAvoidUsingWriteHost', '',
        Justification = 'Interactive CLI chrome; output is presentation, not data.'
    )]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [object[]]$Item,

        [Parameter(Mandatory)]
        [hashtable[]]$Column,

        [Parameter()]
        [switch]$NoIndex
    )

    if ($Item.Count -eq 0) {
        return
    }

    $rows = for ($i = 0; $i -lt $Item.Count; $i++) {
        $row = [ordered]@{}

        if (-not $NoIndex) {
            $row['#'] = $i + 1
        }

        foreach ($definition in $Column) {
            $value = $Item[$i] | ForEach-Object $definition.Expression
            $row[$definition.Header] = if ($null -eq $value) { '' } else { $value }
        }

        [PSCustomObject]$row
    }

    # Out-Host because this is chrome: it must print even though the calling
    # screen returns a navigation directive rather than this output.
    $rows | Format-Table -AutoSize | Out-Host
}
