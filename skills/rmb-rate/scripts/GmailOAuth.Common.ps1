<#
Shared helpers for Phase 3 (Gmail draft automation), dot-sourced by both
Connect-GmailOAuth.ps1 and New-WeeklyEmailDraft.ps1.

Tokens are stored encrypted via Windows DPAPI (ConvertTo-SecureString /
ConvertFrom-SecureString with no explicit key) - this ties the encrypted file to the
current Windows user account and machine, so it can't be decrypted if copied elsewhere.
#>

$script:GmailTokenPath = Join-Path (Split-Path $PSScriptRoot -Parent) 'Credentials\gmail_oauth_token.enc'

function Save-GmailToken {
    param(
        [Parameter(Mandatory)][string]$ClientId,
        [Parameter(Mandatory)][string]$ClientSecret,
        [Parameter(Mandatory)][string]$RefreshToken
    )
    $json = (@{ client_id = $ClientId; client_secret = $ClientSecret; refresh_token = $RefreshToken } | ConvertTo-Json -Compress)
    $secure = ConvertTo-SecureString -String $json -AsPlainText -Force
    $encrypted = ConvertFrom-SecureString -SecureString $secure
    Set-Content -Path $script:GmailTokenPath -Value $encrypted -Encoding ASCII
}

function Get-GmailTokenData {
    if (-not (Test-Path $script:GmailTokenPath)) {
        throw "No stored Gmail authorization found at $script:GmailTokenPath - run Connect-GmailOAuth.ps1 first (see PHASE3_GMAIL_OAUTH_SETUP.md)."
    }
    # .Trim() matters here - Set-Content appends a trailing newline that Get-Content -Raw
    # includes verbatim, and ConvertTo-SecureString rejects the encrypted string if it has
    # any extra trailing whitespace/newline characters.
    $encrypted = (Get-Content -Path $script:GmailTokenPath -Raw).Trim()
    $secure = ConvertTo-SecureString -String $encrypted
    $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
    try {
        $json = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
    } finally {
        [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
    }
    return $json | ConvertFrom-Json
}

function Get-GmailAccessToken {
    $data = Get-GmailTokenData
    $body = @{
        client_id     = $data.client_id
        client_secret = $data.client_secret
        refresh_token = $data.refresh_token
        grant_type    = 'refresh_token'
    }
    try {
        $response = Invoke-RestMethod -Uri 'https://oauth2.googleapis.com/token' -Method Post -Body $body
    } catch {
        throw "Failed to refresh the Gmail access token - the stored authorization may have expired or been revoked. Re-run Connect-GmailOAuth.ps1. Original error: $($_.Exception.Message)"
    }
    return $response.access_token
}
