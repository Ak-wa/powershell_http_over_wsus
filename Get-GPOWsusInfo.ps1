# Original from https://365lab.net/2014/02/05/powershell-gpo-reporting-wsus/
# Edited for compact output & no error output for a full list of HTTP and HTTPs WSUS entries in any GPO

function Get-GPOWsusInfo {
    $GPO = Get-GPO -All
    foreach ($Policy in $GPO) {
        $GPOID = $Policy.Id
        $GPODisp = $Policy.DisplayName

        $xml = Get-GPOReport -Id $GPOID -ReportType xml -ErrorAction SilentlyContinue

        $WSUSServer = $null
        $WSUSBase = Get-GPRegistryValue -Guid $GPOID -Key 'HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate' -ErrorAction SilentlyContinue

        if ($WSUSBase -and $WSUSBase.Count -gt 0) {
            $WSUSServerValue = $WSUSBase | Where-Object { $_.ValueName -eq 'WUServer' }
            if ($WSUSServerValue -and $WSUSServerValue.Count -gt 0) {
                $WSUSServer = $WSUSServerValue.Value
            }
        }

        if ($GPODisp -and $WSUSServer) {
            [PSCustomObject]@{
                GPOName = $GPODisp
                WSUSServer = $WSUSServer
            }
        }
    }
}

Get-GPOWsusInfo -ErrorAction SilentlyContinue
