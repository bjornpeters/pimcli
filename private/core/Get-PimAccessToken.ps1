function Get-PimAccessToken {
    <#
    .SYNOPSIS
        Returns a cached access token for the requested audience.

    .DESCRIPTION
        The module talks to two audiences: ARM for Azure resource PIM and
        Microsoft Graph for Entra ID role PIM. Both tokens are cached per
        audience for the lifetime of the session and refreshed once they fall
        inside the expiry margin, so a long menu session cannot outlive its
        token.

        The token stays a SecureString end to end. That is the type
        'Invoke-RestMethod -Authentication Bearer -Token' expects, so there is
        never a reason to convert it to plaintext.

    .PARAMETER Audience
        Which audience to return a token for: 'Arm' or 'Graph'.

    .PARAMETER Force
        Bypass the cache and request a fresh token.

    .EXAMPLE
        Invoke-RestMethod -Uri $uri -Authentication Bearer -Token (Get-PimAccessToken -Audience Graph)
    #>
    [CmdletBinding()]
    [OutputType([securestring])]
    param(
        [Parameter()]
        [ValidateSet('Arm', 'Graph')]
        [string]$Audience = 'Arm',

        [Parameter()]
        [switch]$Force
    )

    # Refresh this far ahead of the stated expiry so a call started now cannot
    # land after the token has already gone stale.
    $expiryMargin = [timespan]::FromMinutes(5)

    if (-not $script:PimTokenCache) {
        $script:PimTokenCache = @{}
    }

    $cached = $script:PimTokenCache[$Audience]

    if (-not $Force -and $cached -and $cached.ExpiresOn -gt ([datetimeoffset]::UtcNow + $expiryMargin)) {
        Write-Verbose "Using cached $Audience token (expires $($cached.ExpiresOn.ToString('u')))."
        return $cached.Token
    }

    $config = (Get-PimConfig)[$(if ($Audience -eq 'Arm') { 'Arm' } else { 'Graph' })]

    $tokenParams = @{
        AsSecureString = $true
        ErrorAction    = 'Stop'
    }

    # The default audience is already ARM, so only Graph needs an explicit
    # resource. Passing ResourceUrl unnecessarily can force a fresh interactive
    # prompt on some Az.Accounts versions.
    if ($Audience -ne 'Arm') {
        $tokenParams['ResourceUrl'] = $config.Audience
    }

    Write-Verbose "Requesting a new $Audience access token."
    $response = Get-AzAccessToken @tokenParams

    $script:PimTokenCache[$Audience] = @{
        Token     = $response.Token
        ExpiresOn = [datetimeoffset]$response.ExpiresOn
    }

    $response.Token
}
