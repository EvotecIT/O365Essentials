function Get-O365UnavailableResult {
    <#
    .SYNOPSIS
    Finds structured unavailable placeholder results in an object graph.

    .DESCRIPTION
    Walks nested O365Essentials result objects and returns each unavailable placeholder
    together with the path where it was found.

    .PARAMETER InputObject
    Object to inspect.

    .EXAMPLE
    $result = Get-O365CopilotOverview -Name Security
    Get-O365UnavailableResult -InputObject $result
    #>
    [cmdletbinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)] $InputObject
    )

    begin {
        function Visit-O365UnavailableNode {
            param(
                $Node,
                [Parameter(Mandatory)][string] $Path
            )

            if ($null -eq $Node) {
                return
            }

            if (Test-O365UnavailableResult -InputObject $Node) {
                [PSCustomObject] @{
                    Path            = $Path
                    Name            = $Node.Name
                    Reason          = $Node.Reason
                    Area            = $Node.Area
                    Description     = $Node.Description
                    IsOptional      = [bool] $Node.IsOptional
                    SuggestedAction = $Node.SuggestedAction
                    Result          = $Node
                }
                return
            }

            if ($Node -is [string] -or $Node -is [ValueType]) {
                return
            }

            if ($Node -is [System.Collections.IDictionary]) {
                foreach ($Key in $Node.Keys) {
                    $ChildPath = if ($Path -eq '$') { '$.' + $Key } else { $Path + '.' + $Key }
                    if ($null -ne $Node[$Key]) {
                        Visit-O365UnavailableNode -Node $Node[$Key] -Path $ChildPath
                    }
                }
                return
            }

            if ($Node -is [System.Collections.IEnumerable] -and $Node -isnot [string]) {
                $Index = 0
                foreach ($Item in $Node) {
                    $ChildPath = '{0}[{1}]' -f $Path, $Index
                    if ($null -ne $Item) {
                        Visit-O365UnavailableNode -Node $Item -Path $ChildPath
                    }
                    $Index++
                }
                return
            }

            if ($Node.PSObject -and $Node.PSObject.Properties) {
                foreach ($Property in $Node.PSObject.Properties) {
                    if ($Property.MemberType -notin 'NoteProperty', 'Property') {
                        continue
                    }
                    if ($Property.Name -like '__O365*') {
                        continue
                    }
                    $ChildPath = if ($Path -eq '$') { '$.' + $Property.Name } else { $Path + '.' + $Property.Name }
                    if ($null -ne $Property.Value) {
                        Visit-O365UnavailableNode -Node $Property.Value -Path $ChildPath
                    }
                }
            }
        }
    }

    process {
        Visit-O365UnavailableNode -Node $InputObject -Path '$'
    }
}
