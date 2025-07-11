# This PowerShell script uninstalls the textures and FFlags applied by the setup scripts.
# --- Configuration ---
$clientAppSettingsFileName = "ClientAppSettings.json" # Name of the FFlags JSON file
$fflagsConfigFileName = "fflags.json" # Name of the external FFlags configuration file

# --- Script Logic ---
Write-Host "--- Starting Bloxstrap Textures/FFlag Uninstallation ---"

# Get the directory where this PowerShell script is located
$scriptDir = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
$fflagsConfigPath = Join-Path -Path $scriptDir -ChildPath "mods" | Join-Path -ChildPath $fflagsConfigFileName

# 1. Read the FFlags from the external fflags.json file to know which ones to remove
Write-Host "Reading FFlags to remove from '$fflagsConfigPath'..."
$fflagsToRemoveKeys = @()    # Will store the names of FFlags to remove

try {
    if (Test-Path $fflagsConfigPath) {
        $fflagsContent = Get-Content -Path $fflagsConfigPath -Raw -Encoding UTF8
        $fflagsToRemoveObject = $fflagsContent | ConvertFrom-Json
        
        # Extract keys from the PSCustomObject
        foreach ($property in $fflagsToRemoveObject.PSObject.Properties) {
            $fflagsToRemoveKeys += $property.Name
        }
        
        Write-Host "Successfully loaded FFlags to remove: $($fflagsToRemoveKeys -join ', ')."
    } else {
        Write-Warning "FFlags configuration file not found at '$fflagsConfigPath'. Skipping FFlag removal from ClientAppSettings.json."
    }
} catch {
    Write-Error "Failed to read or parse FFlags configuration for removal. Error: $($_.Exception.Message). Skipping FFlag removal."
}

# 2. Locate Bloxstrap Installation Directory via Registry
Write-Host "Attempting to locate Bloxstrap installation via Registry for uninstallation..."
$bloxstrapExePathRaw = (Get-ItemProperty -Path "HKCU:\Software\Classes\roblox\DefaultIcon" -Name "(Default)" -ErrorAction SilentlyContinue).'(Default)'
if ([string]::IsNullOrEmpty($bloxstrapExePathRaw)) {
    Write-Error "Bloxstrap path not found in Registry key HKCU:\Software\Classes\roblox\DefaultIcon."
    exit 2  # Specific exit code for Bloxstrap not found
}

Write-Host "Raw Registry Value found: '$bloxstrapExePathRaw'"

# Clean up the extracted path - simplified version
$bloxstrapExePath = ($bloxstrapExePathRaw -split '","')[0].Trim('"')

# Get the Bloxstrap base directory
$bloxstrapBaseDir = Split-Path -Parent -Path $bloxstrapExePath

if (-not (Test-Path $bloxstrapBaseDir -PathType Container)) {
    Write-Error "Bloxstrap base directory not found at '$bloxstrapBaseDir'."
    exit 2  # Specific exit code for Bloxstrap not found
}
Write-Host "Bloxstrap base directory found: '$bloxstrapBaseDir'"

# 3. Remove Textures folders (content and ExtraContent)
Write-Host "--- Removing Textures from Bloxstrap Modifications ---"
$modificationsDir = Join-Path -Path $bloxstrapBaseDir -ChildPath "Modifications"
$contentDir = Join-Path -Path $modificationsDir -ChildPath "content"
$extraContentDir = Join-Path -Path $modificationsDir -ChildPath "ExtraContent"

if (Test-Path $contentDir -PathType Container) {
    Write-Host "Removing '$contentDir'..."
    try {
        Remove-Item -Path $contentDir -Recurse -Force -ErrorAction Stop
        Write-Host "'content' folder removed successfully from Modifications."
    } catch {
        Write-Error "Failed to remove 'content' folder. Error: $($_.Exception.Message)."
    }
} else {
    Write-Host "'content' folder not found in Modifications directory. Skipping removal."
}

if (Test-Path $extraContentDir -PathType Container) {
    Write-Host "Removing '$extraContentDir'..."
    try {
        Remove-Item -Path $extraContentDir -Recurse -Force -ErrorAction Stop
        Write-Host "'ExtraContent' folder removed successfully from Modifications."
    } catch {
        Write-Error "Failed to remove 'ExtraContent' folder. Error: $($_.Exception.Message)."
    }
} else {
    Write-Host "'ExtraContent' folder not found in Modifications directory. Skipping removal."
}

# 4. Remove FFlags from ClientAppSettings.json within Modifications
Write-Host "--- Removing FFlags from ClientAppSettings.json ---"
$clientSettingsDir = Join-Path -Path $modificationsDir -ChildPath "ClientSettings"
$clientAppSettingsPath = Join-Path -Path $clientSettingsDir -ChildPath $clientAppSettingsFileName

if (Test-Path $clientAppSettingsPath) {
    Write-Host "Found ClientAppSettings.json at '$clientAppSettingsPath'. Attempting to remove FFlags..."
    try {
        $clientAppSettingsContent = Get-Content -Path $clientAppSettingsPath -Raw -Encoding UTF8
        $currentClientAppSettings = $clientAppSettingsContent | ConvertFrom-Json -ErrorAction Stop
        
        $removedCount = 0

        foreach ($fflagName in $fflagsToRemoveKeys) {
            if ($currentClientAppSettings.PSObject.Properties.Name -contains $fflagName) {
                $currentClientAppSettings.PSObject.Properties.Remove($fflagName)
                Write-Host "FFlag '$fflagName' removed."
                $removedCount++
            } else {
                Write-Host "FFlag '$fflagName' not found in ClientAppSettings.json. Skipping removal."
            }
        }

        if ($removedCount -gt 0) {
            Write-Host "Removed $removedCount FFlags."
            $modifiedClientAppSettingsContent = $currentClientAppSettings | ConvertTo-Json -Depth 100
            Set-Content -Path $clientAppSettingsPath -Value $modifiedClientAppSettingsContent -Encoding UTF8
            Write-Host "ClientAppSettings.json updated successfully with FFlags removed."
        } else {
            Write-Host "No specified FFlags were found or removed from ClientAppSettings.json."
        }

    } catch {
        Write-Error "Failed to modify ClientAppSettings.json to remove FFlags. Error: $($_.Exception.Message)."
    }
} else {
    Write-Host "ClientAppSettings.json not found at '$clientAppSettingsPath'. Skipping FFlag removal."
}

Write-Host "--- Uninstallation Finished ---"

# Explicitly exit with 0 for success
exit 0