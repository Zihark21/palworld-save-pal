# Build and Run Script for PALWorld Save Pal
param(
    [string]$Version = $null,
    [switch]$Help
)

if ($Help) {
    Write-Host "Usage: .\build-desktop.ps1 [-Version <version>] [-Help]"
    Write-Host ""
    Write-Host "Parameters:"
    Write-Host "  -Version <version>  Set the version number (e.g., '1.0.0')"
    Write-Host "  -Help              Show this help message"
    Write-Host ""
    Write-Host "If no version is specified, the current version from __version__.py will be used."
    exit 0
}

Set-Location -Path $PSScriptRoot

# Function to update version in a file
function Update-Version {
    param(
        [string]$FilePath,
        [string]$NewVersion,
        [string]$Pattern,
        [string]$Replacement
    )
    
    if (Test-Path $FilePath) {
        $content = Get-Content -Path $FilePath -Raw
        $newContent = $content -replace $Pattern, $Replacement
        Set-Content -Path $FilePath -Value $newContent -NoNewline
        Write-Host "Updated version to $NewVersion in $FilePath"
    }
    else {
        Write-Warning "File not found: $FilePath"
    }
}

# Get or set version
if ($Version) {
    # Validate version format (basic semver check)
    if ($Version -notmatch '^\d+\.\d+\.\d+(-[a-zA-Z0-9\-\.]+)?(\+[a-zA-Z0-9\-\.]+)?$') {
        Write-Error "Invalid version format. Please use semantic versioning (e.g., '1.0.0', '1.0.0-beta', '1.0.0+build.1')"
        exit 1
    }
    
    Write-Host "Updating version to $Version..."
    
    # Update __version__.py
    Update-Version -FilePath ".\palworld_save_pal\__version__.py" -NewVersion $Version -Pattern '__version__ = "[^"]*"' -Replacement "__version__ = `"$Version`""
    
    # Update pyproject.toml
    Update-Version -FilePath ".\pyproject.toml" -NewVersion $Version -Pattern 'version = "[^"]*"' -Replacement "version = `"$Version`""
    
    $version = $Version
}
else {
    # Read current version
    $version = (Get-Content -Path ".\palworld_save_pal\__version__.py" | Select-String -Pattern "__version__").Line.Split('"')[1]
}

Write-Host "Building PALWorld Save Pal Desktop App version $version"

$distDir = ".\dist\psp-windows-$version"
if (Test-Path -Path $distDir) {
    Write-Host "Removing existing distribution directory $distDir"
    Remove-Item -Path $distDir -Recurse -Force
}
New-Item -Path $distDir -ItemType Directory | Out-Null
Write-Host "Created $distDir"

# Build Front end

if (Test-Path -Path ".\build\") {
    Write-Host "Removing existing build directory .\build\"
    Remove-Item -Path ".\build\" -Recurse -Force
}

if (Test-Path -Path ".\ui_build\") {
    Write-Host "Removing existing ui_build directory .\ui_build\"
    Remove-Item -Path ".\ui_build\" -Recurse -Force
}

@"
PUBLIC_WS_URL=127.0.0.1:5174/ws
PUBLIC_DESKTOP_MODE=true
"@ | Set-Content -Path ".\ui\.env"

Set-Location -Path ".\ui"

# Function to check if a command exists
function Test-Command($command) {
    $oldPreference = $ErrorActionPreference
    $ErrorActionPreference = 'stop'
    try {
        if (Get-Command $command) { return $true }
    }
    catch { return $false }
    finally { $ErrorActionPreference = $oldPreference }
}

# Determine which package manager to use
$packageManager = if (Test-Command 'bun') {
    'bun'
}
elseif (Test-Command 'npm') {
    'npm'
}
elseif (Test-Command 'yarn') {
    'yarn'
}
else {
    Write-Error "No suitable package manager found. Please install Bun, npm, or Yarn."
    exit 1
}

Write-Host "Using $packageManager as the package manager."

# Install dependencies
Write-Host "Installing dependencies..."
& $packageManager install

if ($LASTEXITCODE -ne 0) {
    Write-Error "$packageManager install failed. Exiting."
    exit 1
}

# Build the frontend
Write-Host "Building the frontend..."
& $packageManager run build

if ($LASTEXITCODE -ne 0) {
    Write-Error "$packageManager run build failed. Exiting."
    exit 1
}

Set-Location -Path ".."

Write-Host "Building standalone..."

# Build standalone executable
python setup.py build

if ($LASTEXITCODE -ne 0) {
    Write-Error "cx_Freeze build failed. Exiting."
    exit 1
}

Write-Host "Building installer..."
# Create MSI installer
python setup.py bdist_msi

if ($LASTEXITCODE -ne 0) {
    Write-Error "cx_Freeze build failed. Exiting."
    exit 1
}

Write-Host "Copying files to distribution directory..."
Copy-Item -Path ".\build\exe.win-amd64-*\*" -Destination $distDir -Recurse -Force

Write-Host "Cleaning up..."
Remove-Item -Path ".\ui_build\" -Recurse -Force

# Create ZIP archive of the distribution files
$zipPath = ".\dist\PalworldSavePal-$version-win-standalone.zip"
Write-Host "Creating ZIP archive at $zipPath..."
if (Test-Command '7za') {
    & 7za a -tzip $zipPath "$distDir\*" -mx=9
    if ($LASTEXITCODE -ne 0) {
        Write-Error "7za failed to create the ZIP archive. Exiting."
        exit 1
    }
    Write-Host "Created ZIP archive using 7za."
}
else {
    Compress-Archive -Path "$distDir\*" -DestinationPath $zipPath -Force
}

Write-Host "Done building the desktop app."