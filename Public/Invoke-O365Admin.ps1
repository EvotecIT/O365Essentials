function Invoke-O365Admin {
    [cmdletBinding(SupportsShouldProcess)]
    param(
        #[alias('PrimaryUri')][uri] $BaseUri = '',
        [uri] $Uri,
        [parameter(Mandatory)][alias('Authorization')][System.Collections.IDictionary] $Headers,
        [validateset('GET', 'DELETE', 'POST', 'PATCH')][string] $Method = 'GET',
        [string] $ContentType = "application/json; charset=UTF-8",
        [System.Collections.IDictionary] $Body,
        [System.Collections.IDictionary] $QueryParameter #,
       # [switch] $FullUri
    )
    # This forces a reconnect of session in case it's about to time out. If it's not timeouting a cache value is used
    if ($Headers.Splat) {
        $Splat = $Headers.Splat
        #$Headers = Connect-O365Admin @Splat
    }

    if ($Authorization.Error) {
        Write-Warning "Invoke-O365Admin - Authorization error. Skipping."
        return
    }
    $RestSplat = @{
        Headers     = $Headers
        Method      = $Method
        ContentType = $ContentType
    }
    if ($Body) {
        $RestSplat['Body'] = $Body | ConvertTo-Json -Depth 5
    }
  #  if ($FullUri) {
        $RestSplat.Uri = $Uri
   # } else {
   #     $RestSplat.Uri = Join-UriQuery -BaseUri $BaseUri -RelativeOrAbsoluteUri $Uri -QueryParameter $QueryParameter
   # }
    try {
        Write-Verbose "Invoke-O365Admin - Querying [$Method] $($RestSplat.Uri)"
        if ($PSCmdlet.ShouldProcess($($RestSplat.Uri), "Querying [$Method]")) {
            $OutputQuery = Invoke-RestMethod @RestSplat -Verbose:$false
            if ($Method -in 'GET') {
                if ($OutputQuery) {
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
                $ErrorMessage = ConvertFrom-Json -InputObject $RestError
                # Write-Warning -Message "Invoke-Graph - [$($ErrorMessage.error.code)] $($ErrorMessage.error.message), exception: $($_.Exception.Message)"
                Write-Warning -Message "Invoke-O365Admin - Error: $($_.Exception.Message) $($ErrorMessage.error.message)"
            } catch {
                Write-Warning -Message "Invoke-O365Admin - Error: $($_.Exception.Message)"
            }
        } else {
            Write-Warning $_.Exception.Message
        }
        if ($Method -notin 'GET', 'POST') {
            return $false
        }
    }
}