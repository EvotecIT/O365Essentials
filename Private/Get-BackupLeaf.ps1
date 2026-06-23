function Get-BackupLeaf {
    [cmdletbinding()]
    param(
        [Parameter(Mandatory)][string] $Uri
    )

    Invoke-O365Admin -Uri $Uri -Headers $Headers -Method GET -AdditionalHeaders $AdditionalHeaders
}
