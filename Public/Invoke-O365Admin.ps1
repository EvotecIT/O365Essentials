function Invoke-O365Admin {
    [cmdletBinding(SupportsShouldProcess)]
    param(
        [uri] $Uri,
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [validateset('GET', 'DELETE', 'POST', 'PATCH')][string] $Method = 'GET',
        [string] $ContentType = "application/json; charset=UTF-8",
        [System.Collections.IDictionary] $Body
    )
    if (-not $Headers -and $Script:AuthorizationO365Cache) {
        # This forces a reconnect of session in case it's about to time out. If it's not timeouting a cache value is used
        $Headers = Connect-O365Admin -Headers $Headers
    } else {
        Write-Warning "Invoke-O365Admin - Not connected. Please connect using Connect-O365Admin."
        return
    }
    if (-not $Headers) {
        Write-Warning "Invoke-O365Admin - Authorization error. Skipping."
        return
    }
    $RestSplat = @{
        Headers     = $Headers.Headers
        Method      = $Method
        ContentType = $ContentType
    }
    if ($Body) {
        $RestSplat['Body'] = $Body | ConvertTo-Json -Depth 5
    }
    $RestSplat.Uri = $Uri
    try {
        Write-Verbose "Invoke-O365Admin - Querying [$Method] $($RestSplat.Uri)"
        if ($PSCmdlet.ShouldProcess($($RestSplat.Uri), "Querying [$Method]")) {
            #$CookieContainer = [System.Net.CookieContainer]::new()
            #$CookieContainer.MaxCookieSize = 8096
            $OutputQuery = Invoke-RestMethod @RestSplat -Verbose:$false
            if ($Method -in 'GET') {
                if ($null -ne $OutputQuery) {
                    $OutputQuery
                }
                if ($OutputQuery.'@odata.nextLink') {
                    $RestSplat.Uri = $OutputQuery.'@odata.nextLink'
                    $MoreData = Invoke-O365Admin @RestSplat -FullUri
                    if ($MoreData) {
                        $MoreData
                    }
                }
            } elseif ($Method -in 'POST') {
                $OutputQuery
            } else {
                return $true
            }
        }
    } catch {
        $RestError = $_.ErrorDetails.Message
        if ($RestError) {
            try {
                $ErrorMessage = ConvertFrom-Json -InputObject $RestError -ErrorAction Stop
                # Write-Warning -Message "Invoke-Graph - [$($ErrorMessage.error.code)] $($ErrorMessage.error.message), exception: $($_.Exception.Message)"
                Write-Warning -Message "Invoke-O365Admin - Error JSON: $($_.Exception.Message) $($ErrorMessage.error.message)"
            } catch {
                Write-Warning -Message "Invoke-O365Admin - Error: $($RestError.Trim())"
            }
        } else {
            Write-Warning -Message "Invoke-O365Admin - $($_.Exception.Message)"
        }
        if ($_.ErrorDetails.RecommendedAction) {
            Write-Warning -Message "Invoke-O365Admin - Recommended action: $RecommendedAction"
        }
        if ($Method -notin 'GET', 'POST') {
            return $false
        }
    }
}