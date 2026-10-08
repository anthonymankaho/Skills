#requires -Version 5.1
<#
Reusable functions for logging into the Meyer Management System (MMS) portal
(https://portal.meyer-mhk.com/MMS) — password step + mandatory email-OTP step.
See SKILL.md in this folder for the full flow explanation.
#>

$MMSBase = 'https://portal.meyer-mhk.com'
$CredPath = Join-Path $PSScriptRoot 'credentials\mms_credentials.dat'

function Set-MMSCredentials {
    <#
    One-time (or re-run when password changes) interactive setup.
    Stores the email in plain text and the password DPAPI-encrypted
    (current Windows user + machine only) in credentials\mms_credentials.dat.
    Never pass the password as a parameter/argument — this prompts securely.
    #>
    param(
        [Parameter(Mandatory)][string]$Email
    )
    $securePassword = Read-Host -Prompt "MMS password for $Email" -AsSecureString
    $encrypted = ConvertFrom-SecureString $securePassword
    $dir = Split-Path $CredPath -Parent
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    [PSCustomObject]@{ Email = $Email; EncryptedPassword = $encrypted } |
        ConvertTo-Json | Set-Content -Path $CredPath -Encoding utf8
    Write-Host "Saved encrypted credentials for $Email to $CredPath"
}

function Get-MMSCredential {
    if (-not (Test-Path $CredPath)) {
        throw "No stored MMS credentials found at $CredPath. Run Set-MMSCredentials -Email <you>@meyer-msc.com first."
    }
    $data = Get-Content $CredPath -Raw | ConvertFrom-Json
    $secure = ConvertTo-SecureString $data.EncryptedPassword
    $plain = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
        [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure))
    [PSCustomObject]@{ Email = $data.Email; Password = $plain }
}

function Get-VerificationToken($Html) {
    if ($Html -match 'name="__RequestVerificationToken"\s+type="hidden"\s+value="([^"]+)"') {
        return $Matches[1]
    }
    throw "Could not find __RequestVerificationToken in page HTML"
}

function Start-MMSLogin {
    <#
    Step 1 of 2. Submits email+password. Returns a hashtable with the
    WebSession (cookies) and the fresh verification token needed for the
    OTP step. At this point MMS has emailed a 6-digit OTP to the account's
    IT-support-relayed address (see SKILL.md "OTP retrieval").
    #>
    param([string]$Email, [string]$Password)

    $loginUrl = "$MMSBase/MMS/Account/Login?ReturnUrl=%2FMMS%2FHome%2FIndex"
    $page = Invoke-WebRequest -Uri $loginUrl -SessionVariable sess -UseBasicParsing
    $token = Get-VerificationToken $page.Content

    $body = @{
        __RequestVerificationToken = $token
        Email                      = $Email
        Password                   = $Password
        RememberMe                 = 'false'
    }
    $resp = Invoke-WebRequest -Uri "$MMSBase/MMS/?ReturnUrl=%2FMMS%2FHome%2FIndex" `
        -Method Post -Body $body -WebSession $sess -UseBasicParsing

    # MMS skips the OTP step entirely once it trusts this device/session
    # (seen after several logins in a short window from the same machine) -
    # in that case the POST lands straight on the dashboard.
    if ($resp.BaseResponse.ResponseUri.AbsoluteUri -match '/MMS/Home/Index' -or $resp.Content -match 'Hello [A-Za-z ]+!') {
        return @{ Session = $sess; Token = $null; Email = $Email; AlreadyAuthenticated = $true }
    }

    if ($resp.Content -notmatch 'Input One-time Password Here') {
        throw "Did not reach the OTP prompt after submitting credentials — check Email/Password (see 'Invalid login Password' text in the response)."
    }

    return @{ Session = $sess; Token = Get-VerificationToken $resp.Content; Email = $Email; AlreadyAuthenticated = $false }
}

function Complete-MMSLogin {
    <#
    Step 2 of 2. Submits the 6-digit OTP code (read from the account's email
    inbox — see SKILL.md) and returns the authenticated WebSession, ready to
    call any /MMS/... page or DataTables API (GetViewSKUSearch, GetPartList, etc.)
    #>
    param(
        [Parameter(Mandatory)]$LoginState,   # object returned by Start-MMSLogin
        [string]$OtpCode
    )
    if ($LoginState.AlreadyAuthenticated) {
        return $LoginState.Session
    }
    if (-not $OtpCode) { throw "OtpCode is required when Start-MMSLogin did not already authenticate." }
    $body = @{
        __RequestVerificationToken = $LoginState.Token
        userName                   = $LoginState.Email
        passCode                   = $OtpCode
        Code                       = $OtpCode
        Provider                   = 'EmailCode'
        Email                      = $LoginState.Email
    }
    $resp = Invoke-RestMethod -Uri "$MMSBase/MMS/Account/VerifyCode" -Method Post `
        -Body $body -WebSession $LoginState.Session

    if (-not $resp.isSuccess) {
        throw "OTP verification failed: $($resp.message)"
    }

    # Follow through like the site's own JS does, to finalize the auth cookie.
    Invoke-WebRequest -Uri "$MMSBase/MMS/home/index" -WebSession $LoginState.Session -UseBasicParsing | Out-Null
    return $LoginState.Session
}

function Connect-MMS {
    <#
    Convenience wrapper for INTERACTIVE use only (blocks on Read-Host for the
    OTP). When driving this from Claude Code, call Start-MMSLogin yourself,
    fetch the OTP via the Gmail tool, then call Complete-MMSLogin directly —
    see SKILL.md.
    #>
    $cred = Get-MMSCredential
    $state = Start-MMSLogin -Email $cred.Email -Password $cred.Password
    Write-Host "OTP email sent — check $($cred.Email)'s inbox (sender: itsupport@meyer-msc.com)."
    $otp = Read-Host "Enter the 6-digit OTP"
    return Complete-MMSLogin -LoginState $state -OtpCode $otp
}
