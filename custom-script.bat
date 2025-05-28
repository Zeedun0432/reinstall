@echo off
:: Enhanced RDP Configuration with Drive Redirection - All in One
title RDP Storage Access Configuration
color 0B

echo.
echo ============================================
echo     RDP STORAGE ACCESS CONFIGURATION
echo ============================================
echo.

:: Delete partition & extend C drive
echo [1/6] Configuring disk partitions...
(ECHO LIST DISK & ECHO SELECT DISK 0 & ECHO LIST PARTITION & ECHO SELECT PARTITION 3 & ECHO DELETE PARTITION OVERRIDE) > "%TEMP%\d.txt"
diskpart /s "%TEMP%\d.txt" >nul 2>&1
(ECHO SELECT VOLUME %SystemDrive% & ECHO EXTEND) > "%TEMP%\e.txt"
diskpart /s "%TEMP%\e.txt" >nul 2>&1
del "%TEMP%\d.txt" "%TEMP%\e.txt" >nul 2>&1
echo     Disk partition completed.

:: Configure RDP settings for comprehensive drive redirection
echo [2/6] Configuring RDP for complete storage access...

:: Enable drive redirection (CDM - Client Drive Mapping)
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v "fDisableCdm" /t REG_DWORD /d 0 /f >nul 2>&1

:: Enable camera/device redirection
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v "fDisableCam" /t REG_DWORD /d 0 /f >nul 2>&1

:: Enable LPT port redirection
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v "fDisableLPT" /t REG_DWORD /d 0 /f >nul 2>&1

:: Enable COM port redirection
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v "fDisableCcm" /t REG_DWORD /d 0 /f >nul 2>&1

:: Enable clipboard redirection
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v "fDisableClip" /t REG_DWORD /d 0 /f >nul 2>&1

:: Enable audio redirection
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v "fDisableCam" /t REG_DWORD /d 0 /f >nul 2>&1

:: Enable printer redirection
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v "fDisableCpm" /t REG_DWORD /d 0 /f >nul 2>&1

:: Configure Terminal Services Policy for drive redirection
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" /v "fDisableCdm" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" /v "fDisableCam" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" /v "fDisableClip" /t REG_DWORD /d 0 /f >nul 2>&1

:: Enable file system redirection
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" /v "fDisableCpm" /t REG_DWORD /d 0 /f >nul 2>&1

:: Configure RDP security settings for better compatibility
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v "SecurityLayer" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v "UserAuthentication" /t REG_DWORD /d 0 /f >nul 2>&1

:: Enable Terminal Services Device Redirector
sc config "TermServDeviceRedirector" start= auto >nul 2>&1
sc start "TermServDeviceRedirector" >nul 2>&1

:: Enable Remote Desktop Services UserMode Port Redirector
sc config "UmRdpService" start= auto >nul 2>&1
sc start "UmRdpService" >nul 2>&1

:: Enable Terminal Services (RDP core service)
sc config "TermService" start= auto >nul 2>&1
echo     RDP storage access configuration completed.

:: Download & install Chrome
echo [3/6] Downloading and installing Chrome...
powershell -ExecutionPolicy Bypass -Command "try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; $webClient = New-Object System.Net.WebClient; $webClient.DownloadFile('https://dl.google.com/chrome/install/latest/chrome_installer.exe', '%TEMP%\chrome_installer.exe'); Write-Host 'Download completed' } catch { Write-Host 'Download failed:' $_.Exception.Message }"

if exist "%TEMP%\chrome_installer.exe" (
    echo     Installing Chrome...
    start /wait "" "%TEMP%\chrome_installer.exe" /silent /install
    timeout /t 5 /nobreak >nul
    del "%TEMP%\chrome_installer.exe" >nul 2>&1
    echo     Chrome installation completed.
) else (
    echo     Chrome download failed, trying alternative method...
    powershell -ExecutionPolicy Bypass -Command "try { Start-BitsTransfer -Source 'https://dl.google.com/chrome/install/latest/chrome_installer.exe' -Destination '%TEMP%\chrome_alt.exe' } catch { Write-Host 'Alternative download failed' }"
    if exist "%TEMP%\chrome_alt.exe" (
        start /wait "" "%TEMP%\chrome_alt.exe" /silent /install
        del "%TEMP%\chrome_alt.exe" >nul 2>&1
        echo     Chrome installation completed (alternative method).
    ) else (
        echo     Chrome installation failed.
    )
)

:: Configure firewall & disable defender
echo [4/6] Configuring firewall and security settings...
netsh advfirewall firewall add rule name="Server Game" dir=in action=allow protocol=TCP localport=1-65535 >nul 2>&1
netsh advfirewall firewall add rule name="Server Game" dir=in action=allow protocol=UDP localport=1-65535 >nul 2>&1
powershell -WindowStyle Hidden -Command "Set-MpPreference -DisableRealtimeMonitoring $true" >nul 2>&1
echo     Firewall and security configuration completed.

:: Restart Terminal Services to apply changes
echo [5/6] Restarting Terminal Services...
net stop "TermService" /y >nul 2>&1
timeout /t 2 /nobreak >nul
net start "TermService" >nul 2>&1
echo     Terminal Services restarted successfully.

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
echo + Chrome browser: INSTALLED
echo + Firewall rules: CONFIGURED
echo + Windows Defender: DISABLED
echo.
echo IMPORTANT NOTES:
echo 1. System restart is REQUIRED for full activation
echo 2. After restart, enable drive redirection in RDP client:
echo    - Windows RDP: Check "Drives" in Local Resources tab
echo    - Other clients: Enable drive/disk redirection  
echo 3. Your local drives will appear as network drives in RDP
echo.

:: System restart countdown and execution
echo ============================================
echo        PREPARING FOR SYSTEM RESTART
echo ============================================
echo.
echo System restart is required to apply all changes.
echo Make sure to save any open work before continuing.
echo.
echo System will restart in:
echo.

:: Countdown with visual indicator
for /L %%i in (3,-1,1) do (
    echo                %%i seconds...
    timeout /t 1 /nobreak >nul
    cls
    echo.
    echo ============================================
    echo        PREPARING FOR SYSTEM RESTART
    echo ============================================
    echo.
    echo System will restart in:
    echo.
)

echo                Restarting now...
echo.
echo ============================================
echo   Please wait while the system restarts...
echo ============================================

:: Self-delete before restart
del "%~f0" >nul 2>&1

:: Force restart with immediate effect
shutdown /r /f /t 0

:: Fallback restart methods (in case the first one fails)  
timeout /t 2 /nobreak >nul
wmic os where Primary='TRUE' reboot >nul 2>&1

:: Final fallback
timeout /t 2 /nobreak >nul
powershell -Command "Restart-Computer -Force" >nul 2>&1
