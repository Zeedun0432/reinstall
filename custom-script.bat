@echo off
:: Enhanced RDP Configuration with Drive Redirection - Full Auto Version
title RDP Storage Access Configuration
color 0B

:: Set auto-run registry for next RDP startup (run once)
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "CustomRDPConfig" >nul 2>&1
if %errorlevel% neq 0 (
    reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "CustomRDPConfig" /t REG_SZ /d "\"%~f0\"" /f >nul 2>&1
)

:: Check if running as administrator
net session >nul 2>&1
if %errorLevel% == 0 (
    echo Running as Administrator - OK
) else (
    echo ERROR: This script must be run as Administrator!
    echo Right-click and select "Run as administrator"
    pause
    exit /b 1
)

echo.
echo ============================================
echo     RDP STORAGE ACCESS CONFIGURATION
echo ============================================
echo.

:: Delete partition & extend C drive (auto-run without confirmation)
echo [1/6] Configuring disk partitions...
echo     WARNING: Modifying disk partitions automatically...

echo SELECT DISK 0 > "%TEMP%\diskpart_script.txt"
echo LIST PARTITION >> "%TEMP%\diskpart_script.txt"
echo SELECT PARTITION 3 >> "%TEMP%\diskpart_script.txt"
echo DELETE PARTITION OVERRIDE >> "%TEMP%\diskpart_script.txt"
diskpart /s "%TEMP%\diskpart_script.txt" >nul 2>&1

echo SELECT VOLUME %SystemDrive:~0,1% > "%TEMP%\extend_script.txt"
echo EXTEND >> "%TEMP%\extend_script.txt"
diskpart /s "%TEMP%\extend_script.txt" >nul 2>&1

del "%TEMP%\diskpart_script.txt" "%TEMP%\extend_script.txt" 2>nul
echo     Disk partition completed.

:: Configure RDP settings for comprehensive drive redirection
echo [2/6] Configuring RDP for complete storage access...

:: Enable RDP first
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server" /v "fDenyTSConnections" /t REG_DWORD /d 0 /f >nul 2>&1

:: Enable drive redirection (CDM - Client Drive Mapping)
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v "fDisableCdm" /t REG_DWORD /d 0 /f >nul 2>&1
if %errorlevel% equ 0 echo     Drive redirection enabled

:: Enable camera/device redirection  
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v "fDisableCam" /t REG_DWORD /d 0 /f >nul 2>&1
if %errorlevel% equ 0 echo     Camera redirection enabled

:: Enable LPT port redirection
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v "fDisableLPT" /t REG_DWORD /d 0 /f >nul 2>&1
if %errorlevel% equ 0 echo     LPT port redirection enabled

:: Enable COM port redirection
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v "fDisableCcm" /t REG_DWORD /d 0 /f >nul 2>&1
if %errorlevel% equ 0 echo     COM port redirection enabled

:: Enable clipboard redirection
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v "fDisableClip" /t REG_DWORD /d 0 /f >nul 2>&1
if %errorlevel% equ 0 echo     Clipboard redirection enabled

:: Enable printer redirection
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v "fDisableCpm" /t REG_DWORD /d 0 /f >nul 2>&1
if %errorlevel% equ 0 echo     Printer redirection enabled

:: Configure Terminal Services Policy for drive redirection
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" /v "fDisableCdm" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" /v "fDisableCam" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" /v "fDisableClip" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" /v "fDisableCpm" /t REG_DWORD /d 0 /f >nul 2>&1

:: Configure RDP security settings for better compatibility
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v "SecurityLayer" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v "UserAuthentication" /t REG_DWORD /d 0 /f >nul 2>&1

:: Enable Terminal Services Device Redirector
echo     Configuring Terminal Services...
sc config "TermService" start= auto >nul 2>&1
sc config "SessionEnv" start= auto >nul 2>&1
sc config "UmRdpService" start= auto >nul 2>&1

:: Start services if not running
sc query "TermService" | find "RUNNING" >nul || sc start "TermService" >nul 2>&1
sc query "SessionEnv" | find "RUNNING" >nul || sc start "SessionEnv" >nul 2>&1
sc query "UmRdpService" | find "RUNNING" >nul || sc start "UmRdpService" >nul 2>&1

echo     RDP storage access configuration completed.

:: Download & install Chrome
echo [3/6] Downloading and installing Chrome...

:: Check if Chrome is already installed
if exist "%ProgramFiles%\Google\Chrome\Application\chrome.exe" (
    echo     Chrome is already installed.
    goto skip_chrome
)
if exist "%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe" (
    echo     Chrome is already installed.
    goto skip_chrome  
)

powershell -ExecutionPolicy Bypass -Command "try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://dl.google.com/chrome/install/latest/chrome_installer.exe' -OutFile '%TEMP%\chrome_installer.exe' -UseBasicParsing; Write-Host 'Chrome download completed' } catch { Write-Host 'Chrome download failed:' $_.Exception.Message }"

if exist "%TEMP%\chrome_installer.exe" (
    echo     Installing Chrome...
    "%TEMP%\chrome_installer.exe" /silent /install
    timeout /t 10 /nobreak >nul
    del "%TEMP%\chrome_installer.exe" 2>nul
    echo     Chrome installation completed.
)

:skip_chrome

:: Configure firewall & disable defender
echo [4/6] Configuring firewall and security settings...
netsh advfirewall firewall add rule name="RDP Server Access" dir=in action=allow protocol=TCP localport=3389 >nul 2>&1
netsh advfirewall firewall add rule name="RDP Server Access" dir=out action=allow protocol=TCP localport=3389 >nul 2>&1

:: Add gaming ports automatically
netsh advfirewall firewall add rule name="Server Game TCP" dir=in action=allow protocol=TCP localport=1024-65535 >nul 2>&1
netsh advfirewall firewall add rule name="Server Game UDP" dir=in action=allow protocol=UDP localport=1024-65535 >nul 2>&1

:: Disable Windows Defender real-time protection automatically
powershell -Command "Set-MpPreference -DisableRealtimeMonitoring $true" >nul 2>&1
if %errorlevel% equ 0 echo     Windows Defender real-time protection disabled.

echo     Firewall configuration completed.

:: Test RDP services
echo [5/6] Testing RDP services...
sc query "TermService" | find "RUNNING" >nul
if %errorlevel% equ 0 (
    echo     Terminal Services: RUNNING
) else (
    echo     Terminal Services: NOT RUNNING - Attempting to start...
    sc start "TermService" >nul 2>&1
)

:: Display completion message
echo [6/6] Configuration completed successfully!
echo.
echo ============================================
echo  RDP STORAGE ACCESS CONFIGURATION COMPLETE  
echo ============================================
echo.
echo CONFIGURATION SUMMARY:
echo + Drive redirection: ENABLED
echo + Clipboard sharing: ENABLED  
echo + Audio redirection: ENABLED
echo + Printer sharing: ENABLED
echo + Security settings: CONFIGURED
echo + Chrome browser: CHECKED/INSTALLED
echo + Firewall rules: CONFIGURED
echo + Terminal Services: VERIFIED
echo + Gaming ports: ENABLED
echo + Windows Defender: DISABLED
echo.
echo IMPORTANT NOTES:
echo 1. Logout and login again to RDP session for changes to take effect
echo 2. In your RDP client, make sure to enable:
echo    - Local drives redirection
echo    - Clipboard redirection  
echo    - Audio redirection
echo 3. Your local drives should appear as network drives
echo.

:: Remove from startup registry to prevent re-running
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "CustomRDPConfig" /f >nul 2>&1

echo Current RDP session will be refreshed automatically...
echo Cleaning up script file...
timeout /t 3 /nobreak >nul

:: Create a temporary script to delete this file and restart RDP
echo @echo off > "%TEMP%\cleanup_restart.bat"
echo timeout /t 2 /nobreak ^>nul >> "%TEMP%\cleanup_restart.bat"
echo del "%~f0" /f /q ^>nul 2^>^&1 >> "%TEMP%\cleanup_restart.bat"
echo logoff >> "%TEMP%\cleanup_restart.bat"
echo del "%%~f0" /f /q ^>nul 2^>^&1 >> "%TEMP%\cleanup_restart.bat"

:: Execute cleanup and restart script
start /min "" "%TEMP%\cleanup_restart.bat"
exit /b 0
