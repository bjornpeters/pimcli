function New-AzPimDecisionRequest {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true,
            HelpMessage = 'Unique identifier for the approval.')]
        [string]$ApprovalId,
        
        [Parameter(Mandatory = $true,
            HelpMessage = 'Justification for the approval.')]
        [string]$Reason,

        [Parameter(Mandatory = $true,
            HelpMessage = 'Justification for the approval.')]
        [ValidateSet('Approve', 'Deny', 'NotReviewed')]
        [string]$ReviewResult
    )
    begin {
        # Set the basic url for the Privileged Identity Management API and the API version.
        [string]$baseUri = 'https://management.azure.com'
        [string]$apiVersion = '2021-01-01-preview'

        # Retrieve the Azure access token to support te requests.
        [securestring]$token = (Get-AzAccessToken -AsSecureString).Token
    }
    process {
        try {    
            # Get the approval steps first of a single PIM request.
            [string]$approvalStepsUri = $baseUri + "$($ApprovalId)/stages?api-version=$apiVersion"
            [object]$approvalSteps = Invoke-RestMethod -Method 'GET' -Uri $approvalStepsUri -Authentication 'Bearer' -Token $token
    
            Write-Host "Sending decision '$ReviewResult' for PIM request $($approvalSteps.value[0].id)..." -ForegroundColor Cyan

            # Construct the necessary API call for approving a PIM request
            [string]$approvalDecisionUri = $baseUri + ($approvalSteps.value[0].id) + "?api-version=$apiVersion"
    
            # Prepare the request body for the decision request.
            [object]$body = @{
                properties = @{
                    justification = $Reason
                    reviewResult  = $ReviewResult
                }
            } | ConvertTo-Json
            
            # Send the decision for the approval request to the PIM API.
            [hashtable]$approvalDecisionParams = @{
                Method = 'PUT'
                Uri = $approvalDecisionUri
                Body = $body
                Authentication = 'Bearer'
                Token = $token
                ContentType = 'application/json'
            }
            [object]$approvalDecision = Invoke-RestMethod @approvalDecisionParams

            # TODO: Remove return object after debugging.
            Write-Host $approvalDecision
        }
        catch {
            Write-Error "Failed to approve PIM request: $_"
            throw $_
            return $false
        }
    }
    end {
        Write-Host "Successfully approved PIM request." -ForegroundColor 'Green'
        return $true
    }
}