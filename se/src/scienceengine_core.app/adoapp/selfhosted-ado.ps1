
$desktopPath = [Environment]::GetFolderPath("Desktop")
$destinationFolder = Join-Path -Path $desktopPath -ChildPath "Temp"

if (!(Test-Path -Path $destinationFolder)) {
    Write-Host "Creating Temp folder on Desktop..."
    New-Item -ItemType Directory -Path $destinationFolder | Out-Null
}

function Download-File {
    param (
        [string]$Url,
        [string]$OutputPath
    )
    Write-Host "Downloading from $Url to $OutputPath..."
    Invoke-WebRequest -Uri $Url -OutFile $OutputPath -UseBasicParsing
}

# Additional Tool Installations
Write-Host "Starting additional tool installations..."

# 1. AzCopy
$azCopyUrl = "https://aka.ms/downloadazcopy-v10-windows"
$azCopyFile = Join-Path -Path $destinationFolder -ChildPath "azcopy.zip"
Download-File -Url $azCopyUrl -OutputPath $azCopyFile
Write-Host "Extracting AzCopy..."
Expand-Archive -Path $azCopyFile -DestinationPath $destinationFolder -Force
Remove-Item -Path $azCopyFile -Force

# 2. PowerShell 7.x.x
$psDownloadUrl = "https://github.com/PowerShell/PowerShell/releases/download/v7.4.6/PowerShell-7.4.6-win-x64.msi"
$psInstaller = Join-Path -Path $destinationFolder -ChildPath "PowerShell-7.3.6-win-x64.msi"
Download-File -Url $psDownloadUrl -OutputPath $psInstaller
Write-Host "Installing PowerShell 7..."
Start-Process -FilePath $psInstaller -ArgumentList "/quiet /norestart" -Wait

# 3. Service Fabric SDK
$sfUrl = "https://webpihandler.azurewebsites.net/web/handlers/webpi.ashx/getinstaller/MicrosoftAzure-ServiceFabric-CoreSDK.appids"
$sfInstaller = Join-Path -Path $destinationFolder -ChildPath "ServiceFabricSDK.exe"
Download-File -Url $sfUrl -OutputPath $sfInstaller
Write-Host "Installing Service Fabric SDK..."
Start-Process -FilePath $sfInstaller -ArgumentList "/quiet /norestart" -Wait

# 4. Azure CLI
$azCliUrl = "https://azcliprod.blob.core.windows.net/msi/azure-cli-2.67.0.msi"
$azCliInstaller = Join-Path -Path $destinationFolder -ChildPath "azure-cli-2.67.0.msi"
Download-File -Url $azCliUrl -OutputPath $azCliInstaller
Write-Host "Installing Azure CLI..."
Start-Process -FilePath $azCliInstaller -ArgumentList "/quiet /norestart" -Wait

# 5. Helm 3.x.x
$helmDownloadUrl = "https://get.helm.sh/helm-v3.16.4-windows-amd64.zip"
$helmFile = Join-Path -Path $destinationFolder -ChildPath "helm.zip"
Download-File -Url $helmDownloadUrl -OutputPath $helmFile
Write-Host "Extracting Helm..."
Expand-Archive -Path $helmFile -DestinationPath $destinationFolder -Force
Remove-Item -Path $helmFile -Force

# 6. OpenSSL Latest
$opensslUrl = "https://slproweb.com/download/Win64OpenSSL-3_4_0.msi"
$opensslInstaller = Join-Path -Path $destinationFolder -ChildPath "openssl.msi"
Download-File -Url $opensslUrl -OutputPath $opensslInstaller
Write-Host "Installing OpenSSL..."
Start-Process -FilePath $opensslInstaller -ArgumentList "/quiet /norestart" -Wait

# 7. SqlPackage.exe
$sqlPackageUrl = "https://download.microsoft.com/download/a/a/c/aacb9da7-b103-4bec-99ab-cfaf28b0ba78/x64/DacFramework.msi"
$sqlPackageInstaller = Join-Path -Path $destinationFolder -ChildPath "DacFramework.msi"
Download-File -Url $sqlPackageUrl -OutputPath $sqlPackageInstaller
Write-Host "Installing SqlPackage.exe..."
Start-Process -FilePath $sqlPackageInstaller -ArgumentList "/quiet /norestart" -Wait


Write-Host "Setting the PowerShell execution policy to RemoteSigned..."
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

# 8. Azure PowerShell Az module
Write-Host "Installing Az PowerShell module..."
Install-Module -Name Az -Repository PSGallery -Force

# Verify installation
Write-Host "Verifying Az PowerShell module installation..."
if (Get-Module -Name Az -ListAvailable) {
    Write-Host "Az PowerShell module installed successfully!"
} else {
    Write-Host "Failed to install the Az PowerShell module. Please check the logs."
}

# Completion Message
Write-Host "All tools have been downloaded to $destinationFolder and installed successfully."
