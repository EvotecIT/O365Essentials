function Get-O365OrgAdoptionScore {
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )
    $Uri = "https://admin.microsoft.com/admin/api/reports/productivityScoreCustomerOption"
    $OutputSettings = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method GET
    if ($OutputSettings) {
        if ($OutputSettings.Output) {
            try {
                $OutputSettings.Output | ConvertFrom-Json -ErrorAction Stop
            } catch {
                Write-Warning -Message "Get-O365OrgAdoptionScore - Unable to convert output from JSON $($_.Exception.Message)"
            }
        }
    }
}

<#

TenantId                  : CEB371F687454876A04069F2D10A9D1A
ProductivityScoreSignedup : True
SignupUserPuid            : 10030000944DB84D
SignupTime                : 2021-05-22T15:03:09.6894484+00:00
ReadyTime                 : 2021-05-22T18:52:10.0074484+00:00
AdoptionScorePreOptedOut  : False
PreOptedOutUserPuid       :
PreOptedOutTime           : 0001-01-01T00:00:00

#>

<#

$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$session.UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/117.0.0.0 Safari/537.36 Edg/117.0.2045.31"
$session.Cookies.Add((New-Object System.Net.Cookie("MC1", "GUID=ddaa99563cae4ea7886e4ec3b3b65816&HASH=ddaa&LV=202302&V=4&LU=1675709115517", "/", ".microsoft.com")))
$session.Cookies.Add((New-Object System.Net.Cookie("x-portal-routekey", "frc", "/", "admin.microsoft.com")))
$session.Cookies.Add((New-Object System.Net.Cookie("p.BDId", "1beed528-292c-46ff-984b-a0381412e186", "/", "admin.microsoft.com")))
$session.Cookies.Add((New-Object System.Net.Cookie("s.AjaxSessionKey", "RKVmBkPFeoFItafEbR6EzK1YXjonPABkGkd6MUG5qS6p5KN7kaWXxsEc8yLpECj0jKCvc%2B7N3CjJiLqTHyXP9Q%3D%3D", "/", "admin.microsoft.com")))
$session.Cookies.Add((New-Object System.Net.Cookie("s.CURedir", "True", "/", "admin.microsoft.com")))
$session.Cookies.Add((New-Object System.Net.Cookie("s.DCLoc", "frcprod", "/", "admin.microsoft.com")))
$session.Cookies.Add((New-Object System.Net.Cookie("s.MFG", "True", "/", "admin.microsoft.com")))
$session.Cookies.Add((New-Object System.Net.Cookie("p.TenantCulture", "ceb371f6-8745-4876-a040-69f2d10a9d1a::pl-PL", "/", "admin.microsoft.com")))
$session.Cookies.Add((New-Object System.Net.Cookie("s.DisplayCulture", "en-US", "/", "admin.microsoft.com")))
$session.Cookies.Add((New-Object System.Net.Cookie("s.cachemap", "21", "/", "admin.microsoft.com")))
$session.Cookies.Add((New-Object System.Net.Cookie("at_check", "true", "/", ".microsoft.com")))
$session.Cookies.Add((New-Object System.Net.Cookie("MicrosoftApplicationsTelemetryDeviceId", "e01995fb-07ec-49ee-8e9d-18523250772b", "/", "admin.microsoft.com")))
$session.Cookies.Add((New-Object System.Net.Cookie("MicrosoftApplicationsTelemetryFirstLaunchTime", "2023-02-10T08:45:14.247Z", "/", "admin.microsoft.com")))
$session.Cookies.Add((New-Object System.Net.Cookie("p.UtcOffset", "-120", "/", "admin.microsoft.com")))
$session.Cookies.Add((New-Object System.Net.Cookie("MSCC", "cid=c9n5zpp31dsappt5iwgis9uh-c1=2-c2=2-c3=2", "/", ".microsoft.com")))
$session.Cookies.Add((New-Object System.Net.Cookie("MUID", "043B5B7D7C466052000849907DC56114", "/", ".microsoft.com")))
$session.Cookies.Add((New-Object System.Net.Cookie("AMCVS_EA76ADE95776D2EC7F000101%40AdobeOrg", "1", "/", ".microsoft.com")))
$session.Cookies.Add((New-Object System.Net.Cookie("s.SessID", "d5a8d432-eb7b-4867-9fb7-fa159fc69450", "/", "admin.microsoft.com")))
$session.Cookies.Add((New-Object System.Net.Cookie("s.Cart", "{`"BaseOffers`":null,`"Frequency`":0,`"IWPurchaseUserId`":null,`"PromotionCodes`":null,`"IsOfferTransition`":false}", "/", "admin.microsoft.com")))
$session.Cookies.Add((New-Object System.Net.Cookie("s.InNewAdmin", "True", "/", "admin.microsoft.com")))
$session.Cookies.Add((New-Object System.Net.Cookie("market", "PL", "/", ".microsoft.com")))
$session.Cookies.Add((New-Object System.Net.Cookie("fptctx2", "taBcrIH61PuCVH7eNCyH0B9zcK90d%252bIeoo1r5v7Zc255mYjwcvIyy5SXEpMD5ZZmKtx8SvGsNdflRgroe1lGFQjbRB2oIOUZnp7ZuzTwF6ML4CUkA2fz%252firyPQA1EFJP9mWScg0dMyOIYsQGMIHQg6fTt0hGhZf9A6Oq0Eh4nikMmzoAB1jEIbK2HsSS81IMMhx5t0knQJrj4M6Vet4nLKXsWDSebMGDMv1AAY4GuaOT8VEffwqCWe6ZI3gEKTzUMp1XJ%252bw4SpnwewPGH3kBxgr4vzIEFqyebSD98xMv9YUmOdTLeq%252f2JgZRRUmC8L4cr%252bWPXrPD1DZVJdnlXfjYM0jRNANLnYqaWFWJCiB4q7Q%253d", "/", ".microsoft.com")))
$session.Cookies.Add((New-Object System.Net.Cookie("s.ImpressionId", "4f371552-4ad3-41b6-b115-00fa0cc7db21", "/", "admin.microsoft.com")))
$session.Cookies.Add((New-Object System.Net.Cookie("s.classic", "False", "/", "admin.microsoft.com")))
$session.Cookies.Add((New-Object System.Net.Cookie("p.LastLoginDateTimeUtc", "Sep_08_2023_05_17_07", "/", "admin.microsoft.com")))
$session.Cookies.Add((New-Object System.Net.Cookie("s.DmnHQT", "09/08/2023 19:00:17", "/", "admin.microsoft.com")))
$session.Cookies.Add((New-Object System.Net.Cookie("s.DmnRQT", "09/08/2023 19:00:17", "/", "admin.microsoft.com")))
$session.Cookies.Add((New-Object System.Net.Cookie("s.DmnSOQT", "09/08/2023 19:00:18", "/", "admin.microsoft.com")))
$session.Cookies.Add((New-Object System.Net.Cookie("AMCV_EA76ADE95776D2EC7F000101%40AdobeOrg", "1176715910%7CMCIDTS%7C19615%7CMCMID%7C78153368502771671351739697554512531599%7CMCAID%7CNONE%7CMCOPTOUT-1694687814s%7CNONE%7CvVersion%7C5.4.0", "/", ".microsoft.com")))
$session.Cookies.Add((New-Object System.Net.Cookie("mbox", "PC#8ec11c042d71426bbd5bc070c32f1048.37_0#1728867264|session#ee311747d7314eb7905d18055bf69b3d#1694929843", "/", ".microsoft.com")))
$session.Cookies.Add((New-Object System.Net.Cookie("RootAuthToken", "AwAAABoxMi8xNi8yMDIzIDEzOjUxOjIyICswMDowMMIJMC5BUzhBOW5HenprV0hka2lnUUdueTBRcWRHZ1lBQUFBQUFQRVB6Z0FBQUFBQUFBQ3dBQzguQWdBQkFBRUFBQUF0eW9sRE9icFFRNVZ0bEk0dUdqRVBBZ0RzX3dVQTlQOF9yOGxqb1RQV29LZWQ2NnFHRGNjRU1LTFVJQlZTUk54RzVuNGw3b2VZQWxXa3EtV0hsUUczcE5ETGI2d3ppOWFUNHFrckdueHBjY1Y3aDBWdk1pUWN5bC1YVEdBNGJhS0M1YjluSHNXUFM1Vmp4WFpMczM5dWNxVzZhYXVHWUtUS0VVOFFGX0llNU5CamI3NnlSRmtHZ1pCYlVjYS1tcTlsTEhmZzFSR204WEYtSzc1aHBUUVVWdHplSUg3c3FMWXExZDNTeGk3cXBtQWZDOEpsbHlVREhKZjlndmh3VWJ0WjVrTGhPNS1OQ2hfWW9UUjRzbDhlQVJOZm13RUZaM25PWDRCUkVzdVM1VE96d3NxWHRUMDBMZEtpNXJzY1FmXzVPQUFjUmxOUGwxU1hlcUhaaUxmbTVBLWlWTnlVVnpqNUxaY3ZSNHVSVF9UcVhkREdWR2ZCUXEtLTNBRkZ1ZDJKdkJtYnVBdWh6WnVTa21xeUhIU2xQd0ZicUtsMFVjdmpGS3pxd3FKX2FQRmRJSW1rMXNXY0IyNVZ5OGdtNmFUVjNnNG9SbnVpZ1VjTkhTOW42SUwwLVVEVXROUkZvaUx6blRacmJiNm55ZFFWRTNGazFIQ2tuR21UNEpreGhfTy1rQ1RNVkd2djl0c1dsVUJtMzMtX29MenhQOFJNMlNZRENYcWR2amctU1dsZ2xRcEhGY0x3R3Z1b2tGSDEyd0JqczN0SDhWaXQ5SGRjYjN6R2pSMzJEcGJENGNvSXMyRmR1V2F5NDUya3p1bG1hekQwN1h4cDZ6VnJ3cER0UVQ0OUNiTC05REE2eEJwX1ZmQTc3c0UxeGhrUzVtNjFpajU0a0d5V1ljZi1GdlN3NlgxWjdvdzZwQ2ZXU2JzRVRCSGt6SVVMczl3YndJN1hJaWRSWGRmUHJVY3Job042aVZMZFhYOG92bGNIXzFSMGdjdG5UQ0VWMlE4V2hOMVNPYkM5djY0NXJtTGgzMWtab0gtZFd4MC1CNF9aa2FjdVpEYVR5NTB6WUV6S0dlQ3N4THNGOTZyaDJrSkJmY29Eci1LM0NjeDNNZnJyTklnY1VoY3pLZndPWkM0Z3dIWktseWJqZDc5NDVoYWhHQnN5UzNUUG1SeFF5T2FrdnBpbk85UTJpWTNGcTI0NDh3eU5ZUnp2RzdiY3VlY1FhY0htX21ZVW1hZk1jcWJzTnAtRWRHaHNTVWowaDFsZXFqRmNQVlNweDlCYkZCYUZ4WnROOXJ4X1Q0akJhR2xSZ202bVFvN0VVTFlTTzFGWDNqalJUSGZLLVllbFNJSFZValBDQzMtSDNsZVQwcndBbDFyNzBLOUNZN0VRbWo3eFBqeEtrWWxqY0g5a2ZfeHVLM3lFQlRwOGVnWV85N1lXbW1uYnZ3b2Y0LWFFbVVhU2xyLWEzVGxoaDhlUzM1Z3ZxMkRxTTRNRUY5U0p0WnhzSV9vN0lacmN6UGZaV2o3U0g5UGY2dUMxAA%3D%3D", "/", "admin.microsoft.com")))
$session.Cookies.Add((New-Object System.Net.Cookie("UserIndex", "H4sIAAAAAAAEABWMOw7CMBBETfgdgIqedsOuvXbsVFScgAvYsdNgREQQKJweu3ijkUZvGiHEqrAvNLWfS4jj9PqlxzJn%2F23veZkv6fN8p6Gd8rqsB4lSATogeyPZK%2BpZV%2F80pKA6Gg3YjjWw7Qx4ZATjRhkJvYvkN%2FV%2FW7n6PKdd9fyYlNYYIAW2wN4gBFIOcHCSOMbic9X%2B0IKQra0AAAA%3D", "/", "admin.microsoft.com")))
$session.Cookies.Add((New-Object System.Net.Cookie("OIDCAuthCookie", "yfCjU5IPAVLwmpBj6sGbqfxj5wZ5DWHOVJdL7ghJKVO50arh05rDZIt2JXeKs01xaAIyvPegl%2F6CgfxPbJbAzzkdDrvjejbrJ0%2FT%2FlNidBR49Wr8ppUggygMrBmOu6txULnL4Onu8s4nDtlXH1acEp6drFKkDJqsquBaWKjf6JZbVK4nItYVwAfb%2BXuX4R3H9OS%2BZpyeKOdUjmiof1v5%2BW7ZiQ9N7InlGzrKOk6iPRUtZ%2F6fGZM3DdtojSEIlWD%2F5bfNYiF336nyc9LXWntg2XPc4r1b%2FKThssjGo%2Fb52Y%2BtI4dEpk%2FzkEBS7aN%2BmEVwVv44lNwmevIuB3uKyU6TPuowFnAtOgOipjgbmm14oCSnhUgg5ohdpbldFJ9PqrWg%2BskUHDM1ktrs%2Ffery%2FbQ0443AasI0GedkdqIwZI9csTev3xHNql8zdnbEkOk%2BE29FjkKHn%2FaQS0%2FeHdym%2Ft2lUiIia3RtgHCrkU5Sx%2B0EHuFQYrCkbOTdCo6ZQTIqorQ5JFhnTo%2BArfVIAqrTqHQCVUSNB4jyaS7HPk3iBtQSqcQ%2FvAt8XToz3wloMQgL8wxU9f2sKuOhSFRN7HsyeNx9tUwwrrxxf3UH2b1Z75AEWZyOlfKXGx9yMPWlOo4A%2FtPagWVzeOrlDUxiVbmHjbMGq3gRZZe4x0Jyg1H4KUxxE0ikCtVZzl1y8%2BpHiPi4a8Zuz5TuN4u%2Be74F7%2Fn7HV9Qlm2x7z%2FFSqpbPUAKv%2BhyTjsGvdCiFqaSNItpAit9ZXgaWJzah3VF7vPawjcKU5c6Et2ATLnU%2BzQcL%2FUGjcB6sbB7S64yuH3LwY1OrxTJpjglMBSLAfOFYPJV%2BUU49V0kkGEnQAMBhNF2Elju2xAOvyJivJowYlL7Kpp%2FmyldJqak6E5dm09ew2gsul6u%2FTAt1CCS2XKddRzbybE9N8hKD1lS4VCVfsOyD1NDh75M7StDFxB%2Bj8QnRVbfBUxRpqYRoBKopfnfyWWdWbIbE%2FpvnRxp3tyXOL45Ay%2B9CDqY31oNIRKMiNFULmF%2Bl7WKjWDZglot7yohfecwBbKQhwkPCeX1p6AL3TMd3lto9fgWeFRTse3nqH6VFLiNfWte8cC1%2BshwB1N1uTlRi7cXjCcsAXkHVd%2BsLZUfHtbdQTCwmt9D2osulMGgZc46DBts6GFuYuqb9%2BrqXgTC%2BGCa6gCIqmxwdwIFdX00FvbS%2BK3xsoiH7FmZFmxASr%2FfBMxheiJmKv0IQt4ociak5x08IH8ONPzw2t4J5GGWTpT4vY7S51ULQ3Py1Xl1My1tRR9%2FQ7gpBA0Hb51E%2BJM6Rz3IIPO6vLcQW%2ByQbAP4P%2FZ4cISK2H%2B92yTxLrLtLBK1gNorbEbqC6YKGR%2FVLCaUax%2FHL%2BnkSpIeY8hSvcv0vt519VfVkEKb1H5PFQ41eVErO%2BppmtapukmtAUjGKT%2FQjCZBLGiEbOa9DTnIrZvrNHUEMl8gyZy0C%2BhoMWw9U6ATeNyi0O5x65rXXBHzm4OCLtqFsQ%2FVPU0I%2B8jHnS5%2BTyonI%2FlY3PYsr83Z6fS3Q8yQg%2B8CX1LGE0CRs99DmbymIO7gpcIXxsftp4Muet1VObrxD1Moc06Af%2BBZJraYtOgCuDei2z1PygqcbrBmxtXNMWDrYI9InmsuMwzw28XitJpn6bpNTrxDcC9sfkAFk4O1wBIvoTSiGUr1Tr6dqYxROOqz1nFYWmckb40DPb9ZAXlHMmc%2FCa17bo1j0GrPby%2F2ITFKpG0%2Ba2nCrhxuiEFPy9%2Bz9bqsjixISP0xs6pyny43pLp21ac8WPKXtfBcd2v9Dj5Wfh%2Bhnf79%2FaT8F3Ps2B1TzTWD6lzR7iBQgc2PE9cnb0MvEZP%2FPW%2FmEfIIqPR8CsPuBUOO8JYc%2F3CrPwwNMDUR0qVLxM%3D", "/", "admin.microsoft.com")))
$session.Cookies.Add((New-Object System.Net.Cookie("s.LoginUserTenantId", "U+ms1lH88ux27Dt5adoWQA2yiafOW1Xc3V/cvWpZJnPBwwQ2WBuze2W1/uPcJ7M3FOqJzcDA1z1Yq5kqq1C9AQCKLzrE5k0J8+HF8JSaicBWrS/jMqmKM2J/xqwdWJOIFrfatr0sBlPYp4+5b06HaQ==", "/", "admin.microsoft.com")))
$session.Cookies.Add((New-Object System.Net.Cookie("ak_bmsc", "107E5A2198C5BAAC55286ED502988D1A~000000000000000000000000000000~YAAQtDYQYHjh6o6KAQAAC7BHqBXpkLeWKfcybZoS013viOD9hP84htrgGWloObAO5uSUATmpevkEz9ssI1vsV9B/i0ZM/gK7U48hODRClPdCgMKcww/XisrHwqah6dk8suhd22e4LS0SQ708tFS9ozxiHTOlp8X5jvEeaJlRNLL5u8YrlEGHT1nCB4wY3c6F6eXOFQxLXK0M4z9unny+UhbJ2wkLaqlXHs1S0mr/d+7GsaU825nDWl+UxteoToYCdjnNdZP9Q1aLW6S3XBkhy37lNVMemRjpmW2EM4ySlBm3WyFkR3qJfh3KsSdfXfhbna1IO73M1Vk2FMU+kmhxsTH5BLMlGQTUsDbERmowlgB/qKQyc0FPJ+lRlRGeDSSsZlhTqhNnmwVvv6Gb+FA=", "/", ".microsoft.com")))
Invoke-WebRequest -UseBasicParsing -Uri "https://admin.microsoft.com/admin/api/reports/productivityScoreConfig/GetProductivityScoreConfig" `
-WebSession $session `
-Headers @{
"authority"="admin.microsoft.com"
  "method"="GET"
  "path"="/admin/api/reports/productivityScoreConfig/GetProductivityScoreConfig"
  "scheme"="https"
  "accept"="application/json, text/plain, */*"
  "accept-encoding"="gzip, deflate, br"
  "accept-language"="en-US,en;q=0.9,pl;q=0.8"
  "ajaxsessionkey"="RKVmBkPFeoFItafEbR6EzK1YXjonPABkGkd6MUG5qS6p5KN7kaWXxsEc8yLpECj0jKCvc+7N3CjJiLqTHyXP9Q=="
  "cache-control"="no-cache"
  "dnt"="1"
  "pragma"="no-cache"
  "referer"="https://admin.microsoft.com/?auth_upn=przemyslaw.klys%40evotec.pl&source=applauncher"
  "sec-ch-ua"="`"Microsoft Edge`";v=`"117`", `"Not;A=Brand`";v=`"8`", `"Chromium`";v=`"117`""
  "sec-ch-ua-mobile"="?0"
  "sec-ch-ua-platform"="`"Windows`""
  "sec-fetch-dest"="empty"
  "sec-fetch-mode"="cors"
  "sec-fetch-site"="same-origin"
  "x-adminapp-request"="/Settings/Services/:/Settings/L1/AdoptionScore"
  "x-ms-mac-appid"="414daeb8-ee33-491c-aafa-3ff6cd1a27c2"
  "x-ms-mac-hostingapp"="M365AdminPortal"
  "x-ms-mac-target-app"="MAC"
  "x-ms-mac-version"="host-mac_2023.9.11.3"
  "x-portal-routekey"="frc"
}
#>