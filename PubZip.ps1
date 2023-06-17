# This is a PowerShell script that will create a zip file suitable for a "portable" non-installation
#
# To call it add something similar to the following to the project file:
#
#      <Target Name="PublishZip" AfterTargets="Publish" >
#        <PropertyGroup>
#            <PowerShellScript>-File &quot;D:\Visual Studio\Source\PowerShell\PublishZip\PubZip.ps1&quot;</PowerShellScript>
#            <Name>-name $(AssemblyName)</Name>
#            <Version>-version $(AssemblyVersion)</Version>
#            <Path>-path &quot;$(ProjectDir)&quot;</Path>
#        </PropertyGroup>
#        <Exec Command="pwsh -NoProfile $(PowerShellScript) $(Name) $(Version) $(Path)" />
#      </Target>
#
# Note that &quot;Your Name Here&quot; can be substituted for $(AssemblyName)

Param(
    [Parameter(Mandatory = $true)] [string] $name,
    [Parameter(Mandatory = $true)] [string] $version,
    [Parameter(Mandatory = $true)] [string] $path
)

# Stop if there is an error
$ErrorActionPreference = "Stop"

# Begin message
$now = (Get-Date).ToString("HH:mm:ss.ff")
Write-Host "PubZip: entering script at $now"

# Variable names for files and paths
try {
    $name = $name.Trim('"')
    $pubFolder = [IO.Path]::Combine($path.Trim('"'), "bin", "Publish")
    $pubFiles = -join ($pubFolder, "\*")
    $tempFolder = [IO.Path]::Combine($path.Trim('"'), "bin", "Temp")
    $tempPath = [IO.Path]::Combine($tempFolder, $name)
    $tempPath = -join ($tempPath, "\")
    $zipFile = -join ($name, "_", $version, "_NonInstall.zip")
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
    Write-Host "PubZip: copying."
    Copy-Item $pubFiles $tempPath -Recurse
}
catch {
    Write-Host "PubZip: Error copying files."
    [Environment]::Exit(3)
}

# Zip the files - note that zipped files will be in a folder
try {
    Write-Host "PubZip: zipping."
    Compress-Archive -Path $tempPath -DestinationPath $theZip -Force
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

# Finished message
$now = (Get-Date).ToString("HH:mm:ss.ff")
Write-Host "PubZip: script completed at $now"