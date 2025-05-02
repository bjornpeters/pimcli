function Disconnect-AzPim {
    <#
    .SYNOPSIS
        Disconnects from Azure.
    .DESCRIPTION
        Disconnects the current Azure session.
    .EXAMPLE
        Disconnect-AzPim
    #>
    [CmdletBinding()]
    param()
    
    try {
        Disconnect-AzAccount -ErrorAction Stop
        Write-Host "Successfully disconnected from Azure." -ForegroundColor Green
        return $true
    }
    catch {
        Write-Error "Failed to disconnect: $_"
        return $false
    }
}