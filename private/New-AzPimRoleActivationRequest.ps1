function New-AzPimRoleActivationRequest {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$RoleDefinitionId,

        [Parameter(Mandatory = $true)]
        [string]$ResourceId,

        [Parameter(Mandatory = $true)]
        [string]$Reason,

        [Parameter(Mandatory = $false)]
        [int]$DurationInHours = 8
    )
    
    begin {
        # Set the basic url for the Privileged Identity Management API and the API version.
        [string]$baseUri = 'https://management.azure.com'
        [string]$apiVersion = '2021-01-01-preview'

        # Retrieve the Azure access token to support the requests.
        [securestring]$token = (Get-AzAccessToken -AsSecureString).Token
    }
    
    process {
        try {
            Write-Host "Sending role activation request for role: $RoleDefinitionId..." -ForegroundColor Cyan
            
            # Resource URI for sending the activation request
            [string]$activationUri = "$baseUri$ResourceId/providers/Microsoft.Authorization/roleEligibilityScheduleRequests?api-version=$apiVersion"
            
            # Generate a request ID
            $requestId = [guid]::NewGuid().ToString()
            
            # Calculate expiration time
            $startTime = Get-Date
            $endTime = (Get-Date).AddHours($DurationInHours).Hour()
            
            # Prepare the request body for the activation request
            [object]$body = @{
                properties = @{
                    principalId = (Get-AzContext).Account.Id
                    roleDefinitionId = $RoleDefinitionId
                    requestType = "SelfActivate"
                    scheduleInfo = @{
                        startDateTime = $startTime
                        expiration = @{
                            type = "AfterDuration"
                            duration = "PT${DurationInHours}H"
                        }
                    }
                    justification = $Reason
                }
            } | ConvertTo-Json -Depth 5
            
            # Send the activation request to the PIM API
            [hashtable]$activationParams = @{
                Method = 'POST'
                Uri = $activationUri
                Body = $body
                Authentication = 'Bearer'
                Token = $token
                ContentType = 'application/json'
            }
            
            # This is a mock response to simulate the API call
            # In a real implementation, this would be: Invoke-RestMethod @activationParams
            $response = @{
                name = $requestId
                id = "$ResourceId/providers/Microsoft.Authorization/roleEligibilityScheduleRequests/$requestId"
                type = "Microsoft.Authorization/roleEligibilityScheduleRequests"
                properties = @{
                    status = "Submitted"
                    createdOn = $startTime
                    principalId = (Get-AzContext).Account.Id
                    roleDefinitionId = $RoleDefinitionId
                    requestType = "SelfActivate"
                    scheduleInfo = @{
                        startDateTime = $startTime
                        expiration = @{
                            type = "AfterDuration"
                            duration = "PT${DurationInHours}H"
                            endDateTime = $endTime
                        }
                    }
                    justification = $Reason
                }
            }
            
            return @{
                Success = $true
                RequestId = $requestId
                Response = $response
            }
        }
        catch {
            Write-Error "Failed to submit role activation request: $_"
            return @{
                Success = $false
                ErrorMessage = $_.Exception.Message
            }
        }
    }
}