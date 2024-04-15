# This is a PowerShell script that will create zip files suitable for a "portable" installation.
#
# See the README.md file for an example showing how to add to a .csproj file.

Param(
    [Parameter(Mandatory = $true)] [string] $name,
    [Parameter(Mandatory = $true)] [string] $version,
    [Parameter(Mandatory = $true)] [string] $path,
    [Parameter(Mandatory = $true)] [string] $pubDir,
    [Parameter(Mandatory = $false)] [string] $pubType
)

# Stop if there is an error
$ErrorActionPreference = "Stop"

# Start timer
$elapsed = [System.Diagnostics.Stopwatch]::StartNew()

# Startup messages
$now = (Get-Date).ToString("HH:mm:ss.ff")
Write-Host "PubZip: entering script at $now"
Write-Host "PubZip: Application name    : $name"
Write-Host "PubZip: Application version : $version"
Write-Host "PubZip: Base path           : $path"
Write-Host "PubZip: Publish Folder      : $pubDir"
Write-Host "PubZip: Publish type        : $pubType"

# Variable names for files and paths
try {
    $name = $name.Trim('"')
    $nameWithoutSpaces = $name.Replace(" ", "")
    $pubFolder = [IO.Path]::Combine($path.Trim('"'), $pubDir)
    $pubFiles = -join ($pubFolder, "\*")
    $tempFolder = [IO.Path]::Combine($path.Trim('"'), "bin", "Temp")
    $tempPath = [IO.Path]::Combine($tempFolder, $name)
    $tempPath = -join ($tempPath, "\")
    $zipFile = -join ($nameWithoutSpaces, "_", $version, "_", $pubType, "_Portable.zip")
    $zipPath = [IO.Path]::Combine($path.Trim('"'), "bin", "Zip")
    $theZip = [IO.Path]::Combine($zipPath, $zipFile)
}
catch {
    Write-Host "PubZip: Error combining or joining paths."
    [Environment]::Exit(1)
}

# Create folders if needed
try {

    if (!(Test-Path $zipPath -PathType Container)) {
        New-Item -ItemType Directory -Force -Path $zipPath | Out-Null
        Write-Host "PubZip: created Zip folder."
    }

    if (!(Test-Path $tempPath -PathType Container)) {
        New-Item -ItemType Directory -Force -Path $tempPath | Out-Null
        Write-Host "PubZip: created Temp folder."
    }
}
catch {
    Write-Host "PubZip: Error creating folders."
    [Environment]::Exit(2)
}

# Sleep a bit to let build finish
Start-Sleep -Milliseconds 1500

# Copy the files to the temp folder
try {
    Write-Host "PubZip: copying the files."
    Copy-Item $pubFiles $tempPath -Recurse
    Write-Host "PubZip: Elapsed time $([Math]::round($elapsed.Elapsed.TotalSeconds,4)) seconds."
}
catch {
    Write-Host "PubZip: Error copying files."
    [Environment]::Exit(3)
}

# Zip the files - note that zipped files will be in a folder
try {
    Write-Host "PubZip: Zipping the files."
    Compress-Archive -Path $tempPath -DestinationPath $theZip -CompressionLevel Fastest -Force
    Write-Host "PubZip: Elapsed time $([Math]::round($elapsed.Elapsed.TotalSeconds,4)) seconds."
}
catch {
    Write-Host "PubZip: Error zipping files."
    [Environment]::Exit(4)
}

# Remove the temp folder
try {
    Write-Host "PubZip: removing Temp folder."
    Remove-Item $tempPath -Include *.* -Recurse
    Remove-Item $tempFolder -Recurse
}
catch {
    Write-Host "PubZip: Error removing Temp folder."
    [Environment]::Exit(5)
}

#  Get the SHA256 hash
Write-Host "PubZip: Getting file hash."
$hash = (Get-FileHash $theZip -Algorithm SHA256).Hash.ToLower()
Write-Host "PubZip: SHA256 for $theZip is $hash"

#
Write-Host "PubZip: Opening zip output folder."
Invoke-Item $zipPath

# Finished message
$now = (Get-Date).ToString("HH:mm:ss.ff")
Write-Host "PubZip: script completed at $now."
Write-Host "PubZip: Elapsed time $([Math]::round($elapsed.Elapsed.TotalSeconds,4)) seconds."