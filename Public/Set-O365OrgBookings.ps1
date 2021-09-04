function Set-O365OrgBookings {
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [nullable[bool]] $Enabled,
        [nullable[bool]] $ShowPaymentsToggle,
        [nullable[bool]] $PaymentsEnabled,
        [nullable[bool]] $ShowSocialSharingToggle,
        [nullable[bool]] $SocialSharingRestricted,
        [nullable[bool]] $ShowBookingsAddressEntryRestrictedToggle,
        [nullable[bool]] $BookingsAddressEntryRestricted,
        [nullable[bool]] $ShowBookingsAuthEnabledToggle,
        [nullable[bool]] $BookingsAuthEnabled,
        [nullable[bool]] $ShowBookingsCreationOfCustomQuestionsRestrictedToggle,
        [nullable[bool]] $BookingsCreationOfCustomQuestionsRestricted,
        [nullable[bool]] $ShowBookingsExposureOfStaffDetailsRestrictedToggle,
        [nullable[bool]] $BookingsExposureOfStaffDetailsRestricted,
        [nullable[bool]] $ShowBookingsNotesEntryRestrictedToggle,
        [nullable[bool]] $BookingsNotesEntryRestricted,
        [nullable[bool]] $ShowBookingsPhoneNumberEntryRestrictedToggle,
        [nullable[bool]] $BookingsPhoneNumberEntryRestricted,
        [nullable[bool]] $ShowStaffApprovalsToggle,
        [nullable[bool]] $StaffMembershipApprovalRequired
    )
    $Uri = "https://admin.microsoft.com/admin/api/settings/apps/bookings"

    $CurrentSettings = Get-O365OrgBookings -Headers $Headers
    if ($CurrentSettings) {
        $Body = @{
            Enabled                                               = $CurrentSettings.Enabled                                               #: True
            ShowPaymentsToggle                                    = $CurrentSettings.ShowPaymentsToggle                                    #: False
            PaymentsEnabled                                       = $CurrentSettings.PaymentsEnabled                                       #: False
            ShowSocialSharingToggle                               = $CurrentSettings.ShowSocialSharingToggle                               #: True
            SocialSharingRestricted                               = $CurrentSettings.SocialSharingRestricted                               #: False
            ShowBookingsAddressEntryRestrictedToggle              = $CurrentSettings.ShowBookingsAddressEntryRestrictedToggle              #: False
            BookingsAddressEntryRestricted                        = $CurrentSettings.BookingsAddressEntryRestricted                        #: False
            ShowBookingsAuthEnabledToggle                         = $CurrentSettings.ShowBookingsAuthEnabledToggle                         #: False
            BookingsAuthEnabled                                   = $CurrentSettings.BookingsAuthEnabled                                   #: False
            ShowBookingsCreationOfCustomQuestionsRestrictedToggle = $CurrentSettings.ShowBookingsCreationOfCustomQuestionsRestrictedToggle #: False
            BookingsCreationOfCustomQuestionsRestricted           = $CurrentSettings.BookingsCreationOfCustomQuestionsRestricted           #: False
            ShowBookingsExposureOfStaffDetailsRestrictedToggle    = $CurrentSettings.ShowBookingsExposureOfStaffDetailsRestrictedToggle    #: False
            BookingsExposureOfStaffDetailsRestricted              = $CurrentSettings.BookingsExposureOfStaffDetailsRestricted              #: False
            ShowBookingsNotesEntryRestrictedToggle                = $CurrentSettings.ShowBookingsNotesEntryRestrictedToggle                #: False
            BookingsNotesEntryRestricted                          = $CurrentSettings.BookingsNotesEntryRestricted                          #: False
            ShowBookingsPhoneNumberEntryRestrictedToggle          = $CurrentSettings.ShowBookingsPhoneNumberEntryRestrictedToggle          #: False
            BookingsPhoneNumberEntryRestricted                    = $CurrentSettings.BookingsPhoneNumberEntryRestricted                    #: False
            ShowStaffApprovalsToggle                              = $CurrentSettings.ShowStaffApprovalsToggle                              #: True
            StaffMembershipApprovalRequired                       = $CurrentSettings.StaffMembershipApprovalRequired                       #: False
        }

        if ($null -ne $Enabled) {
            $Body.Enabled = $Enabled
        }
        if ($null -ne $ShowPaymentsToggle) {
            $Body.ShowPaymentsToggle = $ShowPaymentsToggle
        }
        if ($null -ne $PaymentsEnabled) {
            $Body.PaymentsEnabled = $PaymentsEnabled
        }
        if ($null -ne $ShowSocialSharingToggle) {
            $Body.ShowSocialSharingToggle = $ShowSocialSharingToggle
        }
        if ($null -ne $SocialSharingRestricted) {
            $Body.SocialSharingRestricted = $SocialSharingRestricted
        }
        if ($null -ne $ShowBookingsAddressEntryRestrictedToggle) {
            $Body.ShowBookingsAddressEntryRestrictedToggle = $ShowBookingsAddressEntryRestrictedToggle
        }
        if ($null -ne $BookingsAddressEntryRestricted) {
            $Body.BookingsAddressEntryRestricted = $BookingsAddressEntryRestricted
        }
        if ($null -ne $ShowBookingsAuthEnabledToggle) {
            $Body.ShowBookingsAuthEnabledToggle = $ShowBookingsAuthEnabledToggle
        }
        if ($null -ne $BookingsAuthEnabled) {
            $Body.BookingsAuthEnabled = $BookingsAuthEnabled
        }
        if ($null -ne $ShowBookingsCreationOfCustomQuestionsRestrictedToggle) {
            $Body.ShowBookingsCreationOfCustomQuestionsRestrictedToggle = $ShowBookingsCreationOfCustomQuestionsRestrictedToggle
        }
        if ($null -ne $BookingsCreationOfCustomQuestionsRestricted) {
            $Body.BookingsCreationOfCustomQuestionsRestricted = $BookingsCreationOfCustomQuestionsRestricted
        }
        if ($null -ne $ShowBookingsExposureOfStaffDetailsRestrictedToggle) {
            $Body.ShowBookingsExposureOfStaffDetailsRestrictedToggle = $ShowBookingsExposureOfStaffDetailsRestrictedToggle
        }
        if ($null -ne $BookingsExposureOfStaffDetailsRestricted) {
            $Body.BookingsExposureOfStaffDetailsRestricted = $BookingsExposureOfStaffDetailsRestricted
        }
        if ($null -ne $ShowBookingsNotesEntryRestrictedToggle) {
            $Body.ShowBookingsNotesEntryRestrictedToggle = $ShowBookingsNotesEntryRestrictedToggle
        }
        if ($null -ne $BookingsNotesEntryRestricted) {
            $Body.BookingsNotesEntryRestricted = $BookingsNotesEntryRestricted
        }
        if ($null -ne $ShowBookingsPhoneNumberEntryRestrictedToggle) {
            $Body.ShowBookingsPhoneNumberEntryRestrictedToggle = $ShowBookingsPhoneNumberEntryRestrictedToggle
        }
        if ($null -ne $BookingsPhoneNumberEntryRestricted) {
            $Body.BookingsPhoneNumberEntryRestricted = $BookingsPhoneNumberEntryRestricted
        }
        if ($null -ne $ShowStaffApprovalsToggle) {
            $Body.ShowStaffApprovalsToggle = $ShowStaffApprovalsToggle
        }
        if ($null -ne $StaffMembershipApprovalRequired) {
            $Body.StaffMembershipApprovalRequired = $StaffMembershipApprovalRequired
        }
        Remove-EmptyValue -Hashtable $Body
        $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method POST -Body $Body
        $Output
    }
}