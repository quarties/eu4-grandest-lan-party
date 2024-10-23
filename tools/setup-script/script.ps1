# Author:       Michał 'Quarties' Sypko
# License:      MIT
# Description:  Script for setting up a new Windows PC for the EU4 Grandest LAN party


## Step 0: Initial setup

### Important variables - change them to match your environment
#### Logging levels
# -1 - Logging disabled
#  0 - Info
#  1 - Debug
$debugLevel = 0;
#### Google Apps Script setup-script webhook URL and auth secret token
$webhookUrl = "https://example.com";
$webhookToken = "<secret token>";

### Constants - do not change them unless you know what you are doing
#### Installation steps
$STEPS = "Renaming PC", "Windows Update", "Install software",  "Reboot";
#### Current installation step
$STEP = 0;

### Helpers
#### Logging
Function Log ($arg)
{
    $level, $restArgs = $arg;
    if ($level -gt $Global:debugLevel)
    {
        Return;
    }
    Echo $restArgs;
}

function InfoLog ($content)
{
    Log(0, $content);
}

function DebugLog ($content)
{
    Log(1, $content);
}

function NewLine
{
    InfoLog ""
}

function NextStep
{
    $currentStepName = $Global:STEPS[$Global:STEP];
    $Global:STEP++;
    $progress = "$Global:STEP/$($Global:STEPS.Length)"
    NewLine
    InfoLog "Current Step: $currentStepName ($progress)";
    NewLine
}

### Set execution policy and install NuGet
InfoLog "Starting setup script..."
Set-ExecutionPolicy RemoteSigned -Scope Process | Out-Null
Install-PackageProvider -Name NuGet -Force | Out-Null


## Step 1: Rename PC and save MAC address in Google Sheet
NextStep

### Get PC ID
Do
{
    $pc = (Read-Host -Prompt 'Type PC ID (i.e. gm1)').ToLower()
}
Until (!([string]::IsNullOrEmpty($pc)))
Rename-Computer -NewName $pc | Out-Null
DebugLog "PC: $pc";

### Get MAC address
$interfaces = Get-NetAdapter -IncludeHidden | Select-Object Name, MacAddress;
$ethernet = $interfaces | where { $_.Name -like "Ethernet" -and $_.MacAddress -notlike "" };
$mac = $ethernet.MacAddress;
DebugLog "MAC: $mac";

### Send MAC address to Google Apps Script webhook
$body = @{
    "token" = $webhookToken
    "pc" = $pc
    "mac" = $mac
} | ConvertTo-Json;
$headers = @{
    "Accept" = "application/json"
    "Content-Type" = "application/json"
};
$result = Invoke-RestMethod -Uri $webhookUrl -Method 'POST' -Body $body -Headers $header | ConvertTo-Json;
DebugLog "Webhook result:"
DebugLog $result
InfoLog "PC renamed and MAC address saved"


## Step 2: Windows Update
NextStep

### Install PSWindowsUpdate module
Install-Module -Name PSWindowsUpdate -Force | Out-Null
InfoLog "PSWindowsUpdate installed"

$updatesList = Get-WindowsUpdate -MicrosoftUpdate

### Install Windows updates
$i = 0;
$updatesList = Get-WindowsUpdate -MicrosoftUpdate
Do {
    $i++;
    InfoLog "Installing Windows update (batch #$i)..."
    DebugLog $updatesList
    $updates = Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -IgnoreReboot
    DebugLog $updates
    $updatesList = Get-WindowsUpdate -MicrosoftUpdate
} While (!($updatesList -eq $null))
InfoLog "Windows Updates installed"

### Pause updates (based on: https://stackoverflow.com/questions/70261571/pause-windows-11-updates-with-powershell)
$pause = (Get-Date).AddDays(7)
$pause = $pause.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
$pause_start = (Get-Date)
$pause_start = $pause_start.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings' -Name 'PauseUpdatesExpiryTime' -Value $pause
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings' -Name 'PauseFeatureUpdatesStartTime' -Value $pause_start
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings' -Name 'PauseFeatureUpdatesEndTime' -Value $pause
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings' -Name 'PauseQualityUpdatesStartTime' -Value $pause_start
Set-itemproperty -Path 'HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings' -Name 'PauseQualityUpdatesEndTime' -Value $pause
InfoLog "Windows Updates paused for 7 days"


## Step 3: Install software
NextStep

Install-Module -Name Microsoft.WinGet.Client -Force | Out-Null
InfoLog "Installing VNC..."
$vnc = Install-WinGetPackage -Id GlavSoft.TightVNC
DebugLog $vnc
InfoLog "Installing 7-Zip..."
$7zip = Install-WinGetPackage -Id 7zip.7zi
DebugLog $7zip
InfoLog "Installing Chrome..."
$chrome = Install-WinGetPackage -Id Google.Chrome
DebugLog $chrome
InfoLog "Installing Discord..."
$discord = Install-WinGetPackage -Id Discord.Discord
DebugLog $discord
InfoLog "Installing Steam..."
$steam = Install-WinGetPackage -Id Valve.Steam
DebugLog $steam
InfoLog "Software installed"


## Step 4: Reboot
NextStep

InfoLog "Press enter to reboot, or close this window to reboot manually later"
Read-Host
Restart-Computer
