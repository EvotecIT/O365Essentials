function Set-O365OrgBookings {
    <#
        .SYNOPSIS
        Set various settings for the Bookings app in the organization.
        .DESCRIPTION
        This function allows setting various configurations for the Bookings app in the organization.
        .PARAMETER Headers
        Authentication token and additional information created with Connect-O365Admin.
        .PARAMETER Enabled
        Enables or disables the Bookings app.
        .PARAMETER ShowPaymentsToggle
        Shows or hides the payments toggle in the Bookings app.
        .PARAMETER PaymentsEnabled
        Enables or disables payments in the Bookings app.
        .PARAMETER ShowSocialSharingToggle
        Shows or hides the social sharing toggle in the Bookings app.
        .PARAMETER SocialSharingRestricted
        Restricts social sharing in the Bookings app.
        .PARAMETER ShowBookingsAddressEntryRestrictedToggle
        Shows or hides the address entry restriction toggle in the Bookings app.
        .PARAMETER BookingsAddressEntryRestricted
        Restricts address entry in the Bookings app.
        .PARAMETER ShowBookingsAuthEnabledToggle
        Shows or hides the authentication enabled toggle in the Bookings app.
        .PARAMETER BookingsAuthEnabled
        Enables or disables authentication in the Bookings app.
        .PARAMETER ShowBookingsCreationOfCustomQuestionsRestrictedToggle
        Shows or hides the custom questions creation restriction toggle in the Bookings app.
        .PARAMETER BookingsCreationOfCustomQuestionsRestricted
        Restricts custom questions creation in the Bookings app.
        .PARAMETER ShowBookingsExposureOfStaffDetailsRestrictedToggle
        Shows or hides the staff details exposure restriction toggle in the Bookings app.
        .PARAMETER BookingsExposureOfStaffDetailsRestricted
        Restricts staff details exposure in the Bookings app.
        .PARAMETER ShowBookingsNotesEntryRestrictedToggle
        Shows or hides the notes entry restriction toggle in the Bookings app.
        .PARAMETER BookingsNotesEntryRestricted
        Restricts notes entry in the Bookings app.
        .PARAMETER ShowBookingsPhoneNumberEntryRestrictedToggle
        Shows or hides the phone number entry restriction toggle in the Bookings app.
        .PARAMETER BookingsPhoneNumberEntryRestricted
        Restricts phone number entry in the Bookings app.
        .PARAMETER ShowStaffApprovalsToggle
        Shows or hides the staff approvals toggle in the Bookings app.
        .PARAMETER StaffMembershipApprovalRequired
        Requires staff membership approval in the Bookings app.
        .EXAMPLE
        Set-O365OrgBookings -Headers $headers -Enabled $true -ShowPaymentsToggle $false -PaymentsEnabled $false
        .NOTES
        This function allows granular control over various settings in the Bookings app.
    #>
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
