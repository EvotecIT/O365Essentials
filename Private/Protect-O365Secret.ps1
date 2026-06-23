function Protect-O365Secret {
    param([Parameter(Mandatory)][string] $PlainText)

    try {
        $sec = ConvertTo-SecureString -String $PlainText -AsPlainText -Force
        return ConvertFrom-SecureString -SecureString $sec
    }
    catch {
        return $PlainText
    }
}
