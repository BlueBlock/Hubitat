# Name: Hubitat-Configuration-Backup.ps1
# Purpose: To backup latest hubitat configuration to off-device location
# Version: 1.0.1

# ex: .\Hubitat-Configuration-Backup.ps1 -HubHostname 192.168.1.99 -BackupDestination c:\temp -WhatIf
# ex: .\Hubitat-Configuration-Backup.ps1 -HubHostname 192.168.1.99 -BackupDestination c:\temp
# ex: .\Hubitat-Configuration-Backup.ps1 -HubHostname 192.168.1.99 -BackupDestination c:\temp -BackupNamePrefix MyPrefix_
# ex: .\Hubitat-Configuration-Backup.ps1 -HubHostname hubitat3 -BackupDestination \\mynas\hubitat-backup


param
(
    [Parameter(Mandatory=$true)]
    [string]$HubHostname,
    [Parameter(Mandatory=$true)]
    [string]$BackupDestination,
    [string]$BackupNamePrefix = "hubitat_backup_",
    [switch]$WhatIf
)

# hub base url
$urlhub = "https://$HubHostname"

# ignore cert validation
$web = New-Object Net.WebClient
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
$output = $web.DownloadString($urlhub)
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = $null

# hub location/name
$WebResponseObj = Invoke-WebRequest -Uri "$urlhub/location/edit"
$location = ($WebResponseObj.Forms | Where {$_.Action -eq "/location/update"}).Fields.name

# hub software version
$WebResponseObj = Invoke-WebRequest -Uri "$urlhub/hub/edit"
$version = $WebResponseObj.ParsedHtml.IHTMLDocument3_getElementByID("hubPopup").getElementsByClassName("menu-text")[0].outerText.Trim()

# get and save backup file
$url = "$($urlhub)/hub/backupDB?fileName=latest"
$output = "$BackupDestination\$($BackupNamePrefix)$($location)_$(get-date -f yyyy-MM-dd-HHmmss)_$($version).lzf"
if ($WhatIf) {
    write-host "WhatIf: Would write backup to $output" -ForegroundColor Cyan
} else {
    Invoke-WebRequest -OutFile $output -Uri $url
}
