function ConvertTo-Base64Url {
    [cmdletbinding()]
    param(
        [byte[]] $bytes
    )
    [Convert]::ToBase64String($bytes).TrimEnd('=')
    | ForEach-Object { $_.Replace('+', '-').Replace('/', '_') }
}