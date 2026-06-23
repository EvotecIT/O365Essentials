function ConvertTo-MicrosoftEdgeDeviceSummary {
    [cmdletbinding()]
    param(
        [Parameter(Mandatory)] $DeviceResult
    )

    [PSCustomObject] @{
        Count       = $DeviceResult.'@odata.count'
        Sample      = @($DeviceResult.value)
        RawSettings = $DeviceResult
    }
}
