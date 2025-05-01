function Get-AzPimRequest {
    [CmdletBinding()]
    param()
    try {        
        [string]$pendingRequestsUri = 'https://management.azure.com/providers/Microsoft.Authorization/roleAssignmentScheduleRequests?api-version=2022-04-01-preview&$filter=asApprover()'

        # Set parameters for the PIM API request.
        [hashtable]$pendingRequestParams = @{
            Method = 'GET'
            Uri =  $pendingRequestsUri
            Authentication = 'Bearer'
            Token = (Get-AzAccessToken -AsSecureString).Token
        }
        [object]$pendingRequests = (Invoke-RestMethod @pendingRequestParams).value
        
        if ($pendingRequests -and $pendingRequests.Count -gt 0) {
            return [array]$pendingRequests
        }
        else {
            return [array]@()
        }
    }
    catch {
        Write-Error "Failed to retrieve PIM requests: $_"
        return [array]@()
    }
}
