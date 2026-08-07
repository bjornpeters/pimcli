function Get-AzPimEligibleRoles {
    [CmdletBinding()]
    param ()
    
    begin {
        # Set the basic url for the Privileged Identity Management API and the API version.
        [string]$baseUri = 'https://management.azure.com'
        [string]$apiVersion = '2020-10-01'

        # Retrieve the Azure access token to support the requests.
        [securestring]$token = (Get-AzAccessToken -AsSecureString).Token
    }
    
    process {
        try {
            Write-Host "Retrieving eligible roles..." -ForegroundColor 'Cyan'
            
            # Get current user ID
            # $currentUserId = (Get-AzContext).Account.Id
            
            # This URI would be used to list role eligibilities in production
            [string]$eligibilityRequestUri = "$baseUri/providers/Microsoft.Authorization/roleEligibilitySchedules?api-version=$apiVersion&`$filter=asTarget()"
            
            # Set parameters for the PIM API request.
            [hashtable]$pendingRequestParams = @{
                Method = 'GET'
                Uri =  $eligibilityRequestUri
                Authentication = 'Bearer'
                Token = $token
            }
            [object]$eligibilityAssignments = (Invoke-RestMethod @pendingRequestParams).value

            # TODO: Implement validation of the amount of returned assignments. Might be null...

            # Format the output with useful information
            $eligibleRoles = $eligibilityAssignments | ForEach-Object {
                [PSCustomObject]@{
                    Role = $_.properties.expandedProperties.roleDefinition.displayName
                    Resource = $_.properties.expandedProperties.scope.displayName
                    ResourceType = $_.properties.expandedProperties.scope.type
                    Membership = $_.properties.memberType
                }
            }
            
            return @{
                Success = $true
                EligibleRoles = $eligibleRoles
            }
        }
        catch {
            Write-Error "Failed to retrieve eligible roles: $_"
            return @{
                Success = $false
                ErrorMessage = $_.Exception.Message
                EligibleRoles = @()
            }
        }
    }
}