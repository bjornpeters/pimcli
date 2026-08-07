function New-AzPimDecisionRequest {
    <#
    .SYNOPSIS
        Records an approve or deny decision on an Azure resource PIM request.

    .DESCRIPTION
        Reads the approval stages for the request, then PUTs the decision to the
        first stage.

        Cleaned up while being moved into the provider layer. The previous
        version wrote the raw API response to the host and returned $true from
        its end block whichever way the call went, including after a caught
        failure, which made the caller's success check meaningless. It now
        throws on failure and returns the API response, so the caller can tell
        the difference.

    .PARAMETER ApprovalId
        Resource ID of the approval, as returned on the request.

    .PARAMETER Reason
        Justification recorded with the decision.

    .PARAMETER ReviewResult
        The decision to record.

    .EXAMPLE
        New-AzPimDecisionRequest -ApprovalId $id -Reason 'Approved for incident 1234' -ReviewResult Approve
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$ApprovalId,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Reason,

        [Parameter(Mandatory)]
        [ValidateSet('Approve', 'Deny', 'NotReviewed')]
        [string]$ReviewResult
    )

    $config = (Get-PimConfig).Arm
    $apiVersion = $config.ApiVersion.RoleAssignmentApproval
    $token = Get-PimAccessToken -Audience Arm

    $stagesUri = '{0}{1}/stages?api-version={2}' -f $config.BaseUri, $ApprovalId, $apiVersion
    Write-Verbose "GET $stagesUri"

    $stages = Invoke-RestMethod -Method 'GET' -Uri $stagesUri -Authentication 'Bearer' -Token $token -ErrorAction Stop

    if (-not $stages.value -or $stages.value.Count -eq 0) {
        throw "Approval '$ApprovalId' has no approval stages to record a decision against."
    }

    $stage = $stages.value[0]
    $decisionUri = '{0}{1}?api-version={2}' -f $config.BaseUri, $stage.id, $apiVersion

    if (-not $PSCmdlet.ShouldProcess((Get-PimIdLeaf -Id $ApprovalId), "Record decision '$ReviewResult'")) {
        return
    }

    $body = @{
        properties = @{
            justification = $Reason
            reviewResult  = $ReviewResult
        }
    } | ConvertTo-Json

    Write-Verbose "PUT $decisionUri"

    Invoke-RestMethod -Method 'PUT' `
        -Uri $decisionUri `
        -Body $body `
        -Authentication 'Bearer' `
        -Token $token `
        -ContentType 'application/json' `
        -ErrorAction Stop
}
