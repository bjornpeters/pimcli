function Show-AzPimRequestDetail {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true,
            HelpMessage = 'Creation date and time of the request.')]
        [string]$CreatedOn,
        
        [Parameter(Mandatory = $true,
            HelpMessage = 'Duration of the requested access.')]
        [string]$Duration,
        
        [Parameter(Mandatory = $true,
            HelpMessage = 'Justification provided for the request.')]
        [string]$Justification,
        
        [Parameter(Mandatory = $true,
            HelpMessage = 'Display name of the user requesting access.')]
        [string]$PrincipalName,
        
        [Parameter(Mandatory = $true,
            HelpMessage = 'Display name of the resource.')]
        [string]$ResourceName,
        
        [Parameter(Mandatory = $true,
            HelpMessage = 'Type of the resource being accessed.')]
        [string]$ResourceType,
        
        [Parameter(Mandatory = $true,
            HelpMessage = 'Name of the role being requested.')]
        [string]$RoleDefinitionName,
        
        [Parameter(Mandatory = $true,
            HelpMessage = 'Start date and time for the requested access.')]
        [string]$StartDateTime,
        
        [Parameter(Mandatory = $true,
            HelpMessage = 'Current status of the request.')]
        [string]$Status,

        [Parameter(Mandatory = $true,
            HelpMessage = 'Reference ticket number for the request.')]
        [string]$TicketNumber,

        [Parameter(Mandatory = $true,
            HelpMessage = 'Source system for the reference ticket.')]
        [string]$TicketSystem
    )

    Write-Host "================= PIM Request Details =================" -ForegroundColor 'Cyan'
    Write-Host ""
    Write-Host "Request details" -ForegroundColor 'Cyan'
    Write-Host "Role:          $RoleDefinitionName" -ForegroundColor 'White'
    Write-Host "Requestor:     $PrincipalName" -ForegroundColor 'White'
    Write-Host "Resource:      $ResourceName" -ForegroundColor 'White'
    Write-Host "Resource type: $ResourceType" -ForegroundColor 'White'
    Write-Host "Request time:  $CreatedOn" -ForegroundColor 'White'
    Write-Host "Reason:        $Justification" -ForegroundColor 'White'
    Write-Host "Status:        $Status" -ForegroundColor 'White'
    Write-Host ""
    Write-Host "Ticket information" -ForegroundColor 'Cyan'
    Write-Host "Ticket number: $TicketNumber" -ForegroundColor 'White'
    Write-Host "Ticket system: $TicketSystem" -ForegroundColor 'White'
    Write-Host ""
    Write-Host "Schedule information" -ForegroundColor 'Cyan'
    Write-Host "Start time:    $StartDateTime" -ForegroundColor 'White'
    Write-Host "Duration:      $Duration" -ForegroundColor 'White'
    Write-Host ""
    Write-Host "=======================================================" -ForegroundColor 'Cyan'
}