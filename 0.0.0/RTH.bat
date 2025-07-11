@echo off
setlocal enabledelayedexpansion
title Roblox TopBar Hider

cls

:menu
echo.
echo =================================
echo   Roblox TopBar Hider
echo =================================
echo.
echo [1] Hide
echo [2] Show  
echo [3] Exit
echo.
choice /c 123 /n /m "Please select an option: "

if errorlevel 3 goto exit
if errorlevel 2 goto uninstall
if errorlevel 1 goto install

:install
cls
echo.
echo ========================================
echo Starting Installation...
echo ========================================
echo.

set "installScript=%~dp0bin\install.ps1"
if not exist "%installScript%" (
    echo ERROR: Install script not found at: %installScript%
    echo Please ensure the bin folder and install.ps1 exist.
    echo.
    pause
    goto menu
)

echo Executing install.ps1...
echo Please wait, this may take a few moments...
echo.

REM Create a temporary file to capture PowerShell output
set "tempOutput=%temp%\rth_install_output_%random%.tmp"

REM Execute PowerShell and capture all output to temporary file
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%installScript%" > "%tempOutput%" 2>&1
set exitcode=%errorlevel%

REM Display the captured output
type "%tempOutput%"

echo.
if %exitcode% equ 0 (
    echo ========================================
    echo    INSTALLATION SUCCESSFUL!
    echo ========================================
    echo Launch Roblox through Bloxstrap to see the changes
    echo ========================================
) else if %exitcode% equ 2 (
    echo ========================================
    echo    BLOXSTRAP NOT FOUND!
    echo ========================================
    echo.
    echo Bloxstrap is required for this modification to work.
    echo.
    echo To install Bloxstrap:
    echo 1. Visit: https://github.com/bloxstraplabs/bloxstrap/releases/latest
    echo 2. Download the Bloxstrap installer
    echo 3. Run the installer and follow the setup instructions
    echo 4. Launch Roblox at least once through Bloxstrap
    echo 5. Return here and try the installation again
    echo.
    echo Note: Bloxstrap is a safe, open-source Roblox bootstrapper
    echo that allows for custom modifications like this one.
    echo ========================================
) else if %exitcode% equ 1 (
    echo ========================================
    echo    INSTALLATION FAILED!
    echo ========================================
    echo.
    echo Error Code: %exitcode%
    echo.
    echo Common solutions:
    echo - Run this program as Administrator
    echo - Check that all required files are present
    echo - Ensure antivirus isn't blocking file access
    echo.
    echo If the problem persists, try:
    echo - Restarting your computer
    echo - Reinstalling Bloxstrap
    echo ========================================
) else (
    echo ========================================
    echo    UNEXPECTED ERROR!
    echo ========================================
    echo.
    echo Error Code: %exitcode%
    echo.
    echo This is an unexpected error code.
    echo Please try:
    echo - Running as Administrator
    echo - Restarting your computer
    echo - Checking Windows Event Viewer for details
    echo ========================================
)

echo.
echo ========================================
echo Options:
echo ========================================
echo [1] Save output to log file
echo [2] Return to main menu
echo [3] Exit
echo.
choice /c 123 /n /m "Please select an option: "

if errorlevel 3 (
    REM Clean up temporary file before exit
    if exist "%tempOutput%" del "%tempOutput%"
    goto exit
)
if errorlevel 2 (
    REM Clean up temporary file before returning to menu
    if exist "%tempOutput%" del "%tempOutput%"
    cls
    goto menu
)
if errorlevel 1 goto save_install_log

:save_install_log
set "logfile=%~dp0install_log_%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%%time:~6,2%.txt"
set "logfile=%logfile: =0%"
echo.
echo Saving installation output to log file...
(
echo Installation Log - %date% %time%
echo ========================================
echo Script Path: %~f0
echo Install Script: %installScript%
echo Exit Code: %exitcode%
echo.
echo FULL INSTALLATION OUTPUT:
echo ========================================
type "%tempOutput%"
echo.
echo ========================================
echo INSTALLATION SUMMARY:
echo ========================================
if %exitcode% equ 0 (
    echo INSTALLATION SUCCESSFUL!
    echo Launch Roblox through Bloxstrap to see the changes
) else if %exitcode% equ 2 (
    echo BLOXSTRAP NOT FOUND!
    echo Bloxstrap is required for this modification to work.
    echo Download from: https://github.com/bloxstraplabs/bloxstrap/releases/latest
) else if %exitcode% equ 1 (
    echo INSTALLATION FAILED!
    echo Error Code: %exitcode%
    echo Troubleshooting steps:
    echo - Run this program as Administrator
    echo - Check that all required files are present
    echo - Ensure antivirus isn't blocking file access
    echo - Try restarting your computer
    echo - Try reinstalling Bloxstrap
) else (
    echo UNEXPECTED ERROR!
    echo Error Code: %exitcode%
    echo Try running as Administrator or check Windows Event Viewer
)
echo ========================================
) > "%logfile%"

REM Clean up temporary file
if exist "%tempOutput%" del "%tempOutput%"

echo Log saved to: %logfile%
echo.
pause
cls
goto menu

:uninstall
cls
echo.
echo ========================================
echo Starting Uninstallation...
echo ========================================
echo.

set "uninstallScript=%~dp0bin\uninstall.ps1"
if not exist "%uninstallScript%" (
    echo ERROR: Uninstall script not found at: %uninstallScript%
    echo Please ensure the bin folder and uninstall.ps1 exist.
    echo.
    pause
    goto menu
)

echo Executing uninstall.ps1...
echo Please wait, this may take a few moments...
echo.

REM Create a temporary file to capture PowerShell output
set "tempOutput=%temp%\rth_uninstall_output_%random%.tmp"

REM Execute PowerShell and capture all output to temporary file
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%uninstallScript%" > "%tempOutput%" 2>&1
set exitcode=%errorlevel%

REM Display the captured output
type "%tempOutput%"

echo.
if %exitcode% equ 0 (
    echo ========================================
    echo    UNINSTALLATION SUCCESSFUL!
    echo ========================================
    echo The TopBar menu has been restored
    echo ========================================
) else if %exitcode% equ 2 (
    echo ========================================
    echo    BLOXSTRAP NOT FOUND!
    echo ========================================
    echo.
    echo Bloxstrap is required for this modification to work.
    echo.
    echo To install Bloxstrap:
    echo 1. Visit: https://github.com/bloxstraplabs/bloxstrap/releases/latest
    echo 2. Download the Bloxstrap installer
    echo 3. Run the installer and follow the setup instructions
    echo 4. Launch Roblox at least once through Bloxstrap
    echo 5. Return here and try the installation again
    echo.
    echo Note: Bloxstrap is a safe, open-source Roblox bootstrapper
    echo that allows for custom modifications like this one.
    echo ========================================
) else if %exitcode% equ 1 (
    echo ========================================
    echo    UNINSTALLATION FAILED!
    echo ========================================
    echo.
    echo Error Code: %exitcode%
    echo.
    echo Possible causes:
    echo - Files are in use by another program
    echo - Insufficient permissions
    echo - Bloxstrap configuration issues
    echo.
    echo Try:
    echo - Run as Administrator
    echo - Restart your computer if files seem locked
    echo - Manually check Bloxstrap Modifications folder
    echo ========================================
) else (
    echo ========================================
    echo    UNEXPECTED ERROR!
    echo ========================================
    echo.
    echo Error Code: %exitcode%
    echo.
    echo This is an unexpected error code.
    echo Please try:
    echo - Running as Administrator
    echo - Restarting your computer
    echo - Checking Windows Event Viewer for details
    echo ========================================
)

echo.
echo ========================================
echo Options:
echo ========================================
echo [1] Save output to log file
echo [2] Return to main menu
echo [3] Exit
echo.
choice /c 123 /n /m "Please select an option: "

if errorlevel 3 (
    REM Clean up temporary file before exit
    if exist "%tempOutput%" del "%tempOutput%"
    goto exit
)
if errorlevel 2 (
    REM Clean up temporary file before returning to menu
    if exist "%tempOutput%" del "%tempOutput%"
    cls
    goto menu
)
if errorlevel 1 goto save_uninstall_log

:save_uninstall_log
set "logfile=%~dp0uninstall_log_%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%%time:~6,2%.txt"
set "logfile=%logfile: =0%"
echo.
echo Saving uninstallation output to log file...
(
echo Uninstallation Log - %date% %time%
echo ========================================
echo Script Path: %~f0
echo Uninstall Script: %uninstallScript%
echo Exit Code: %exitcode%
echo.
echo FULL UNINSTALLATION OUTPUT:
echo ========================================
type "%tempOutput%"
echo.
echo ========================================
echo UNINSTALLATION SUMMARY:
echo ========================================
if %exitcode% equ 0 (
    echo UNINSTALLATION SUCCESSFUL!
    echo The TopBar menu has been restored
) else if %exitcode% equ 2 (
    echo BLOXSTRAP NOT FOUND!
    echo Bloxstrap is required for this modification to work.
    echo Download from: https://github.com/bloxstraplabs/bloxstrap/releases/latest
) else if %exitcode% equ 1 (
    echo UNINSTALLATION FAILED!
    echo Error Code: %exitcode%
    echo Possible causes:
    echo - Files are in use by another program
    echo - Insufficient permissions  
    echo - Bloxstrap configuration issues
    echo Troubleshooting:
    echo - Run as Administrator
    echo - Restart computer if files seem locked
    echo - Manually check Bloxstrap Modifications folder
) else (
    echo UNEXPECTED ERROR!
    echo Error Code: %exitcode%
    echo Try running as Administrator or check Windows Event Viewer
)
echo ========================================
) > "%logfile%"

REM Clean up temporary file
if exist "%tempOutput%" del "%tempOutput%"

echo Log saved to: %logfile%
echo.
pause
cls
goto menu

:exit
exit /b 0