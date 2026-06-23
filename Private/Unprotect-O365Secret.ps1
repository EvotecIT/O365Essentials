function Unprotect-O365Secret {
    param([Parameter(Mandatory)][string] $Protected)

    try {
        $sec = ConvertTo-SecureString -String $Protected
        $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($sec)
        try {
            return [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr)
        }
        finally {
            if ($bstr -ne [IntPtr]::Zero) {
                [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
            }
        }
    }
    catch {
        return $Protected
    }
}
