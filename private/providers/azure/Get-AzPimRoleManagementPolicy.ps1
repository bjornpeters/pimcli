<#
    .SYNOPSIS
        Gets the role management policy for a specific role in Azure AD Privileged Identity Management (PIM).

    .DESCRIPTION
        This function retrieves the role management policy settings for a role assignment in Azure AD PIM.
        It uses native PowerShell REST API calls with Azure authentication.

    .PARAMETER SubscriptionId
        The ID of the Azure subscription.

    .PARAMETER ResourceGroupName
        The name of the resource group containing the resource.

    .PARAMETER ResourceName
        The name of the resource.

    .PARAMETER RoleDefinitionId
        The ID of the role definition.

    .PARAMETER Scope
        The scope of the role assignment (default is 'resource').
        Valid values: 'subscription', 'resourceGroup', 'resource'

    .EXAMPLE
        Get-AzPimRoleManagementPolicy -SubscriptionId "12345678-1234-1234-1234-123456789012" -ResourceGroupName "MyResourceGroup" -ResourceName "MyResource" -RoleDefinitionId "8e3af657-a8ff-443c-a75c-2fe8c4bcb635"

    .NOTES
        Requires Az PowerShell module to be installed and authenticated with sufficient permissions.
#>
function Get-AzPimRoleManagementPolicy {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false,
            HelpMessage = "The name of the resource")]
        [string]$ResourceName,

        [Parameter(Mandatory = $false,
            HelpMessage = "The name of the resource group containing the resource")]
        [string]$ResourceGroupName,

        [Parameter(Mandatory = $true,
            HelpMessage = "The ID of the role definition")]
        [string]$RoleDefinitionId,

        [Parameter(Mandatory = $false,
            HelpMessage = "The scope of the role assignment (subscription, resourceGroup, or resource)")]
        [ValidateSet('subscription', 'resourceGroup', 'resource')]
        [string]$Scope = 'resource',

        [Parameter(Mandatory = $true,
            HelpMessage = "The ID of the Azure subscription")]
        [guid]$SubscriptionId
    )

    begin {
        # Verify Az PowerShell module is available
        if (-not (Get-Command Get-AzAccessToken -ErrorAction SilentlyContinue)) {
            throw "Az PowerShell module is required. Please install it using: Install-Module -Name Az -Force -AllowClobber"
        }

        # Get authentication token
        try {
            $token = (Get-AzAccessToken -AsSecureString).Token
            Write-Verbose "Successfully obtained authentication token"
        }
        catch {
            throw "Failed to obtain authentication token: $_"
        }
    }

    process {
        # Build the scope ID based on the provided parameters
        $scopeId = ""

        switch ($Scope) {
            'subscription' {
                $scopeId = "/providers/Microsoft.Subscription/subscriptions/$SubscriptionId"
            }
            'resourceGroup' {
                if (-not $ResourceGroupName) {
                    throw "ResourceGroupName is required when Scope is set to 'resourceGroup'"
                }
                $scopeId = "/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName"
            }
            'resource' {
                if (-not $ResourceGroupName -or -not $ResourceName) {
                    throw "ResourceGroupName and ResourceName are required when Scope is set to 'resource'"
                }
                # Get the resource ID using REST API
                $resourceUrl = "https://management.azure.com/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/resources?`$filter=name eq '$ResourceName'&api-version=2021-04-01"
                $resource = Invoke-RestMethod -Uri $resourceUrl -Headers $authHeader -Method Get

                if ($resource.value.Count -eq 0) {
                    throw "Resource '$ResourceName' not found in resource group '$ResourceGroupName'"
                }
                $scopeId = $resource.value[0].id
            }
        }

        Write-Verbose "Using scope ID: $scopeId"

        # Get the role management policy using the Azure REST API.
        try {
            [string]$baseUrl = 'https://management.azure.com'
            [string]$endpoint = '/providers/Microsoft.Authorization/roleManagementPolicyAssignments'
            [string]$apiVersion = "2020-10-01"
            [string]$url = "{0}{1}{2}?api-version={3}&`$filter=roleDefinitionId eq '{4}'" -f $baseUrl, $scopeId, $endpoint, $apiVersion, $RoleDefinitionId
            Write-Verbose -Message "Uri: $url"

            $invokeParams = @{
                Method = 'GET'
                Uri = $url
                Authentication = 'Bearer'
                Token = $token
            }
            $response = Invoke-RestMethod @invokeParams

            if (-not $response -or $response.value.Count -eq 0) {
                Write-Warning "No role management policy found for the specified role and scope."
                return $null
            }

            return $response.value
        }
        catch {
            Write-Error "Error retrieving role management policy: $_"
            throw
        }
    }

    end {
        # Nothing special to clean up
    }
}