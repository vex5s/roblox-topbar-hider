# This PowerShell script automates applying FFlags and copying textures/ExtraContent folders
# to Bloxstrap's Modifications directory.
# --- Configuration ---
$clientAppSettingsFileName = "ClientAppSettings.json" # The FFlags JSON file name

# --- Script Logic ---
Write-Host "--- Starting Bloxstrap Textures/FFlag Application ---"

# 1. Get the directory where this script is located
$scriptDir = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition

# 2. Locate Bloxstrap Installation Directory via Registry
Write-Host "Attempting to locate Bloxstrap installation via Registry..."
$bloxstrapExePathRaw = (Get-ItemProperty -Path "HKCU:\Software\Classes\roblox\DefaultIcon" -Name "(Default)" -ErrorAction SilentlyContinue).'(Default)'
if ([string]::IsNullOrEmpty($bloxstrapExePathRaw)) {
    Write-Error "Bloxstrap path not found in Registry key HKCU:\Software\Classes\roblox\DefaultIcon."
    exit 2  # Specific exit code for Bloxstrap not found
}

Write-Host "Raw Registry Value found: '$bloxstrapExePathRaw'"

# Clean up the extracted path - simplified version
$bloxstrapExePath = ($bloxstrapExePathRaw -split '","')[0].Trim('"')

# Get the Bloxstrap base directory (e.g., C:\Users\VEXUS\AppData\Local\Bloxstrap)
$bloxstrapBaseDir = Split-Path -Parent -Path $bloxstrapExePath

if (-not (Test-Path $bloxstrapBaseDir -PathType Container)) {
    Write-Error "Bloxstrap base directory not found at '$bloxstrapBaseDir'."
    exit 2  # Specific exit code for Bloxstrap not found
}
Write-Host "Bloxstrap base directory found: '$bloxstrapBaseDir'"

# 3. Define the Bloxstrap Modifications directory
$modificationsDir = Join-Path -Path $bloxstrapBaseDir -ChildPath "Modifications"

# Ensure the Modifications directory exists
if (-not (Test-Path $modificationsDir -PathType Container)) {
    Write-Host "Creating Bloxstrap Modifications directory: '$modificationsDir'"
    try {
        New-Item -Path $modificationsDir -ItemType Directory | Out-Null
    } catch {
        Write-Error "Failed to create Modifications directory. Error: $($_.Exception.Message). Exiting."
        exit 1
    }
}

# 4. Execute fflags.ps1 to apply FFlags
Write-Host "--- Executing FFlags Application ---"
$fflagsScriptPath = Join-Path -Path $scriptDir -ChildPath "fflags.ps1"
if (Test-Path $fflagsScriptPath) {
    Write-Host "Executing fflags.ps1..."
    try {
        & "$fflagsScriptPath"
        $fflagsExitCode = $LASTEXITCODE
        if ($fflagsExitCode -eq 2) {
            Write-Host "fflags.ps1 reported Bloxstrap not found."
            exit 2  # Pass through Bloxstrap not found error
        } elseif ($fflagsExitCode -ne 0) {
            Write-Error "fflags.ps1 failed with exit code $fflagsExitCode."
            exit 1
        }
        Write-Host "fflags.ps1 executed successfully."
    } catch {
        Write-Error "Failed to execute fflags.ps1. Error: $($_.Exception.Message)."
        exit 1
    }
} else {
    Write-Warning "fflags.ps1 not found. Skipping FFlags application."
}

# 5. Copy 'content' and 'ExtraContent' folders to Bloxstrap Modifications
Write-Host "--- Copying Textures to Bloxstrap Modifications ---"

# Source directories are within 'mods' subfolder
$sourceModsDir = Join-Path -Path $scriptDir -ChildPath "mods"
$sourceContentDir = Join-Path -Path $sourceModsDir -ChildPath "content"
$sourceExtraContentDir = Join-Path -Path $sourceModsDir -ChildPath "ExtraContent"

# Copy 'content' folder
if (Test-Path $sourceContentDir -PathType Container) {
    Write-Host "Copying folder '$sourceContentDir' into '$modificationsDir'..."
    try {
        Copy-Item -Path "$sourceContentDir" -Destination $modificationsDir -Recurse -Force -ErrorAction Stop
        Write-Host "'content' folder copied successfully."
    } catch {
        Write-Error "Failed to copy 'content' folder. Error: $($_.Exception.Message)."
        exit 1
    }
} else {
    Write-Warning "'content' folder not found in '$sourceModsDir'. Skipping."
}

# Copy 'ExtraContent' folder
if (Test-Path $sourceExtraContentDir -PathType Container) {
    Write-Host "Copying folder '$sourceExtraContentDir' into '$modificationsDir'..."
    try {
        Copy-Item -Path "$sourceExtraContentDir" -Destination $modificationsDir -Recurse -Force -ErrorAction Stop
        Write-Host "'ExtraContent' folder copied successfully."
    } catch {
        Write-Error "Failed to copy 'ExtraContent' folder. Error: $($_.Exception.Message)."
        exit 1
    }
} else {
    Write-Warning "'ExtraContent' folder not found in '$sourceModsDir'. Skipping."
}

Write-Host "--- Bloxstrap Textures/FFlag Application Finished ---"

# Explicitly exit with 0 for success
exit 0