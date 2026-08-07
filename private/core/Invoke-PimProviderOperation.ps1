function Invoke-PimProviderOperation {
    <#
    .SYNOPSIS
        Dispatches a PIM operation to one provider, or fans it out across several.

    .DESCRIPTION
        This is the seam between the screens and the two PIM surfaces. Read
        operations fan out across every provider allowed by the scope filter and
        return one merged collection, which is what lets a single list show
        Azure and Entra rows side by side.

        Providers are isolated from each other. A provider that fails is
        reported in Errors and the results from the others are still returned,
        so a Graph outage cannot hide the Azure roles a user does have. A
        provider that has not implemented the operation yet is reported in
        Unavailable instead, which the screens render as a note rather than an
        error.

        That distinction matters: an unimplemented backend must never
        contribute an empty result set that reads as 'you have no roles here'.

        Write operations must name a single provider, since fanning a decision
        or an activation out across surfaces is never what the caller means.

    .PARAMETER Operation
        The operation to invoke, as declared in the provider registry.

    .PARAMETER Provider
        Target a single provider by name. Required for write operations.

    .PARAMETER Scope
        Session scope filter applied when fanning out: 'All', 'Azure' or 'Entra'.

    .PARAMETER Arguments
        Splatted onto the provider function.

    .OUTPUTS
        A hashtable with Items, Unavailable and Errors.

    .EXAMPLE
        $result = Invoke-PimProviderOperation -Operation GetEligibleRole -Scope All
        $result.Items | Format-Table
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory)]
        [ValidateSet(
            'GetEligibleRole',
            'GetActiveRole',
            'GetApprovalRequest',
            'NewActivation',
            'NewDecision',
            'RemoveActiveRole'
        )]
        [string]$Operation,

        [Parameter()]
        [string]$Provider,

        [Parameter()]
        [ValidateSet('All', 'Azure', 'Entra')]
        [string]$Scope = 'All',

        [Parameter()]
        [hashtable]$Arguments = @{}
    )

    $writeOperations = @('NewActivation', 'NewDecision', 'RemoveActiveRole')

    if ($Operation -in $writeOperations -and -not $Provider) {
        throw "Operation '$Operation' changes state and must target a single provider. Pass -Provider."
    }

    $targets = if ($Provider) {
        @(Get-PimProvider -Name $Provider)
    }
    else {
        @(Get-PimProvider -Scope $Scope)
    }

    $result = @{
        Items       = [System.Collections.Generic.List[object]]::new()
        Unavailable = [System.Collections.Generic.List[hashtable]]::new()
        Errors      = [System.Collections.Generic.List[hashtable]]::new()
    }

    foreach ($target in $targets) {
        $functionName = $target.Operations[$Operation]

        if (-not $functionName -or -not (Get-Command -Name $functionName -ErrorAction SilentlyContinue)) {
            $result.Unavailable.Add(@{
                Provider = $target.DisplayName
                Message  = 'not implemented yet'
            })
            continue
        }

        try {
            Write-Verbose "Dispatching $Operation to $functionName."
            $output = & $functionName @Arguments

            foreach ($item in $output) {
                if ($null -ne $item) {
                    $result.Items.Add($item)
                }
            }
        }
        catch [System.NotImplementedException] {
            $result.Unavailable.Add(@{
                Provider = $target.DisplayName
                Message  = $_.Exception.Message
            })
        }
        catch {
            $result.Errors.Add(@{
                Provider = $target.DisplayName
                Message  = $_.Exception.Message
            })
        }
    }

    @{
        Items       = @($result.Items)
        Unavailable = @($result.Unavailable)
        Errors      = @($result.Errors)
    }
}
