function ConvertFrom-JSONWebToken {
    <#
    .SYNOPSIS
    Converts JWT token to PowerShell object allowing for easier analysis.

    .DESCRIPTION
    Converts JWT token to PowerShell object allowing for easier analysis.

    .PARAMETER Token
    Provide Token to convert to PowerShell object

    .PARAMETER IncludeHeader
    Include header as part of ordered dictionary

    .EXAMPLE
    ConvertFrom-JSONWebToken -Token .....

    .NOTES
    Based on https://www.michev.info/Blog/Post/2140/decode-jwt-access-and-id-tokens-via-powershell
 
    Basically does what: https://jwt.ms/ and https://jwt.io/ do for you online
    #>
    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true)][string]$Token,
        [switch] $IncludeHeader
    )

    # Validate as per https://tools.ietf.org/html/rfc7519
    # Access and ID tokens are fine, Refresh tokens will not work
    if (!$Token.Contains(".") -or !$Token.StartsWith("eyJ")) {
        Write-Warning -Message "ConvertFrom-JSONWebToken - Wrong token. Skipping."
        return
    }

    # Extract header and payload
    $tokenheader, $tokenPayload = $Token.Split(".").Replace('-', '+').Replace('_', '/')[0..1]

    # Fix padding as needed, keep adding "=" until string length modulus 4 reaches 0
    while ($tokenheader.Length % 4) {
        $tokenheader += "="
    }
    # Invalid length for a Base-64 char array or string, adding =
    while ($tokenPayload.Length % 4) {
        $tokenPayload += "="
    }
    # Convert header from Base64 encoded string to PSObject all at once
    $header = [System.Text.Encoding]::UTF8.GetString([system.convert]::FromBase64String($tokenheader)) | ConvertFrom-Json

    # Convert payload to string array
    $tokenArray = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($tokenPayload))

    # Convert from JSON to PSObject
    $TokenObject = $tokenArray | ConvertFrom-Json

    # Signature
    foreach ($i in 0..2) {
        $Signature = $Token.Split('.')[$i].Replace('-', '+').Replace('_', '/')
        switch ($Signature.Length % 4) {
            0 { break }
            2 { $Signature += '==' }
            3 { $Signature += '=' }
        }
    }
    $TokenObject | Add-Member -Type NoteProperty -Name "signature" -Value $Signature

    # Convert Expire time to PowerShell DateTime
    $DateZero = (Get-Date -Year 1970 -Month 1 -Day 1 -Hour 0 -Minute 0 -Second 0 -Millisecond 0)
    $TimeZone = Get-TimeZone
    $UTC = $DateZero.AddSeconds($TokenObject.exp)
    $Offset = $TimeZone.GetUtcOffset($(Get-Date)).TotalMinutes
    $LocalTime = $UTC.AddMinutes($Offset)
    Add-Member -Type NoteProperty -Name "expires" -Value $LocalTime -InputObject $TokenObject

    # Time to Expire
    $TimeToExpire = ($LocalTime - (Get-Date))
    Add-Member -Type NoteProperty -Name "timeToExpire" -Value $TimeToExpire -InputObject $TokenObject

    if ($IncludeHeader) {
        [ordered] @{
            Header = $header
            Token  = $TokenObject
        }
    } else {
        $TokenObject
    }
}
