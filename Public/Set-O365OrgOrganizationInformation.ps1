function Set-O365OrgOrganizationInformation {
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [string] $Name,
        [string] $StreetAddress,
        [string] $ApartmentOrSuite,
        [string] $City,
        [string] $State,
        [string] $PostalCode,
        #[string] $Country,
        #[string] $CountryCode,
        #[string] $PossibleStatesOrProvinces,
        [string] $PhoneNumber,
        [string] $TechnicalContactEmail
    )
    $Uri = "https://admin.microsoft.com/admin/api/Settings/company/profile"

    $CurrentSettings = Get-O365OrgOrganizationInformation -Headers $Headers
    if ($CurrentSettings) {
        $Body = @{
            Name                  = $CurrentSettings.Name                      ## : Evotec
            Address1              = $CurrentSettings.Address1                  ## :
            Address2              = $CurrentSettings.Address2                  ## :
            #Address3                  = $CurrentSettings.Address3                  ## :
            #Address4                  = $CurrentSettings.Address4                  ## :
            City                  = $CurrentSettings.City                      ## : KATOWICE
            State                 = $CurrentSettings.State                     ## : Śląskie
            PostalCode            = $CurrentSettings.PostalCode                ## : 40-
            Country               = $CurrentSettings.Country                   ## : Poland
            #CountryCode               = $CurrentSettings.CountryCode               ## : PL
            #PossibleStatesOrProvinces = $CurrentSettings.PossibleStatesOrProvinces ## :
            PhoneNumber           = $CurrentSettings.PhoneNumber               ## : +4
            TechnicalContactEmail = $CurrentSettings.TechnicalContactEmail     ## : p
            #DefaultDomain             = $CurrentSettings.DefaultDomain             ## :
            Language              = $CurrentSettings.Language                  ## : en
            #MSPPID                    = $CurrentSettings.MSPPID                    ## :
            #SupportUrl                = $CurrentSettings.SupportUrl                ## :
            #SupportEmail              = $CurrentSettings.SupportEmail              ## :
            #SupportPhone              = $CurrentSettings.SupportPhone              ## :
            SupportedLanguages    = $CurrentSettings.SupportedLanguages        ## : {@{ID=en; Name=English; Default=True; DefaultCulture=en-US; PluralFormRules=IsOne}, @{ID=pl; Name=polski; Default=False; DefaultCulture=pl-PL; PluralFormRules=IsOne,EndsInTwoThruFourNotTweleveThruFourteen}}
        }
        if ($PSBoundParameters.ContainsKey('Name')) {
            $Body.Name = $Name
        }
        if ($PSBoundParameters.ContainsKey('StreetAddress')) {
            $Body.Address1 = $StreetAddress
        }
        if ($PSBoundParameters.ContainsKey('ApartmentOrSuite')) {
            $Body.Address2 = $ApartmentOrSuite
        }
        if ($PSBoundParameters.ContainsKey('City')) {
            $Body.City = $City
        }
        if ($PSBoundParameters.ContainsKey('State')) {
            $Body.State = $State
        }
        if ($PSBoundParameters.ContainsKey('PostalCode')) {
            $Body.PostalCode = $PostalCode
        }
        #if ($PSBoundParameters.ContainsKey('Country')) {
        #    $Body.Country = $Country
        #}
        #if ($PSBoundParameters.ContainsKey('CountryCode')) {
        #    $Body.CountryCode = $CountryCode
        #}
        if ($PSBoundParameters.ContainsKey('PhoneNumber')) {
            $Body.PhoneNumber = $PhoneNumber
        }
        if ($PSBoundParameters.ContainsKey('TechnicalContactEmail')) {
            $Body.TechnicalContactEmail = $TechnicalContactEmail
        }

        $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method POST -Body $Body
        $Output
    }
}