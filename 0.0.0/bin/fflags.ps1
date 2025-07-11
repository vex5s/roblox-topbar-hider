# This PowerShell script locates the Bloxstrap installation,
# reads its ClientAppSettings.json, modifies settings (including FFlags) from fflags.json, and saves it back.

# --- Configuration ---
$jsonFileName = "ClientAppSettings.json"
$fflagsConfigFileName = "fflags.json"  # External configuration file

# --- Script Logic ---
Write-Host "--- Starting Bloxstrap ClientAppSettings Editor ---"

# 1. Get the directory where this script is located
$scriptDir = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
$fflagsConfigPath = Join-Path -Path $scriptDir -ChildPath "mods" | Join-Path -ChildPath $fflagsConfigFileName

# 2. Read FFlags configuration from external JSON file
Write-Host "Reading FFlags configuration from '$fflagsConfigPath'..."
if (-not (Test-Path $fflagsConfigPath)) {
    Write-Error "FFlags configuration file not found at '$fflagsConfigPath'. Exiting."
    exit 1
}

try {
    $fflagsContent = Get-Content -Path $fflagsConfigPath -Raw -Encoding UTF8
    $fflagsConfig = $fflagsContent | ConvertFrom-Json
    Write-Host "Successfully loaded FFlags configuration."
}
catch {
    Write-Error "Failed to read or parse FFlags configuration. Error: $($_.Exception.Message). Exiting."
    exit 1
}

$settingsToModify = $fflagsConfig

# 3. Locate Bloxstrap Installation Directory via Registry
Write-Host "Attempting to locate Bloxstrap installation via Registry..."
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

# 4. Define the path to ClientAppSettings.json within the Modifications folder
$modificationsDir = Join-Path -Path $bloxstrapBaseDir -ChildPath "Modifications"
$clientSettingsDir = Join-Path -Path $modificationsDir -ChildPath "ClientSettings"
$jsonFilePath = Join-Path -Path $clientSettingsDir -ChildPath $jsonFileName

# Ensure ClientSettings directory exists within Modifications
if (-not (Test-Path $clientSettingsDir -PathType Container)) {
    Write-Host "ClientSettings directory within Modifications not found. Creating it: '$clientSettingsDir'"
    try {
        New-Item -Path $clientSettingsDir -ItemType Directory | Out-Null
    } catch {
        Write-Error "Failed to create ClientSettings directory within Modifications. Error: $($_.Exception.Message). Exiting."
        exit 1
    }
}

# 5. Read existing JSON or create a new object
Write-Host "Reading existing ClientAppSettings.json or creating new from '$jsonFilePath'..."

$json = New-Object PSCustomObject
if (Test-Path $jsonFilePath) {
    try {
        $jsonContent = Get-Content -Path $jsonFilePath -Raw -Encoding UTF8
        # Check if file is empty or contains only whitespace before converting from JSON
        if ([string]::IsNullOrWhiteSpace($jsonContent)) {
            Write-Warning "ClientAppSettings.json is empty or contains only whitespace. Creating a new empty object."
        } else {
            $json = $jsonContent | ConvertFrom-Json -ErrorAction Stop
            Write-Host "Successfully loaded existing ClientAppSettings.json."
        }
    }
    catch {
        Write-Warning "Failed to read or parse existing ClientAppSettings.json. Error: $($_.Exception.Message). Creating a new empty object."
        $json = New-Object PSCustomObject
    }
}
else {
    Write-Host "ClientAppSettings.json not found. Creating a new empty object."
}

# 6. Apply modifications from fflags.json
Write-Host "Applying modifications from configuration..."
foreach ($property in $settingsToModify.PSObject.Properties) {
    $key = $property.Name
    $newValue = $property.Value
    $oldValue = if ($json.PSObject.Properties.Name -contains $key) { $json.$key } else { "N/A (New FFlag)" }
    Write-Host "Setting '$key' to '$newValue' (Old value: '$oldValue')"

    if ($json.PSObject.Properties.Name -contains $key) {
        $json.$key = $newValue
    }
    else {
        $json | Add-Member -MemberType NoteProperty -Name $key -Value $newValue -Force
    }
}
Write-Host "Modifications applied."

# 7. Write the modified JSON back to the file
Write-Host "Writing modified JSON back to '$jsonFilePath'..."
try {
    $modifiedJsonContent = $json | ConvertTo-Json -Depth 100
    Set-Content -Path $jsonFilePath -Value $modifiedJsonContent -Encoding UTF8
    Write-Host "ClientAppSettings.json updated successfully with FFlags applied (UTF8 encoding)."
} catch {
    Write-Error "Failed to write modified ClientAppSettings.json. Error: $($_.Exception.Message). Exiting."
    exit 1
}

Write-Host "--- Bloxstrap ClientAppSettings Editor Finished ---"

# Explicitly exit with 0 for success
exit 0