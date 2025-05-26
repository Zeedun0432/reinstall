@echo off
:: Delete partition & extend C drive
(ECHO LIST DISK & ECHO SELECT DISK 0 & ECHO LIST PARTITION & ECHO SELECT PARTITION 3 & ECHO DELETE PARTITION OVERRIDE) > "%TEMP%\d.txt"
diskpart /s "%TEMP%\d.txt" >nul 2>&1
(ECHO SELECT VOLUME %SystemDrive% & ECHO EXTEND) > "%TEMP%\e.txt"
diskpart /s "%TEMP%\e.txt" >nul 2>&1
del "%TEMP%\d.txt" "%TEMP%\e.txt" >nul 2>&1

:: Configure RDP settings for drive redirection
echo Configuring RDP for storage access...
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v "fDisableCdm" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v "fDisableCam" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v "fDisableLPT" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v "fDisableCcm" /t REG_DWORD /d 0 /f >nul 2>&1

:: Enable drive redirection in Terminal Services
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" /v "fDisableCdm" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" /v "fDisableCam" /t REG_DWORD /d 0 /f >nul 2>&1

:: Enable clipboard redirection
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v "fDisableClip" /t REG_DWORD /d 0 /f >nul 2>&1

:: Configure RDP security settings
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v "SecurityLayer" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v "UserAuthentication" /t REG_DWORD /d 0 /f >nul 2>&1

:: Enable Terminal Services Device Redirector
sc config "TermServDeviceRedirector" start= auto >nul 2>&1
sc start "TermServDeviceRedirector" >nul 2>&1

:: Download & install Chrome (Fixed version)
echo Downloading Chrome...
powershell -ExecutionPolicy Bypass -Command "try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; $webClient = New-Object System.Net.WebClient; $webClient.DownloadFile('https://dl.google.com/chrome/install/latest/chrome_installer.exe', '%TEMP%\chrome_installer.exe'); Write-Host 'Download completed' } catch { Write-Host 'Download failed:' $_.Exception.Message }"
if exist "%TEMP%\chrome_installer.exe" (
    echo Installing Chrome...
    start /wait "" "%TEMP%\chrome_installer.exe" /silent /install
    timeout /t 5 /nobreak >nul
    del "%TEMP%\chrome_installer.exe" >nul 2>&1
    echo Chrome installation completed
) else (
    echo Chrome download failed, trying alternative method...
    powershell -ExecutionPolicy Bypass -Command "try { Start-BitsTransfer -Source 'https://dl.google.com/chrome/install/latest/chrome_installer.exe' -Destination '%TEMP%\chrome_alt.exe' } catch { Write-Host 'Alternative download failed' }"
    if exist "%TEMP%\chrome_alt.exe" (
        start /wait "" "%TEMP%\chrome_alt.exe" /silent /install
        del "%TEMP%\chrome_alt.exe" >nul 2>&1
    )
)

:: Configure firewall & disable defender
netsh advfirewall firewall add rule name="SERVER GAME" dir=in action=allow protocol=TCP localport=1-65535 >nul 2>&1
netsh advfirewall firewall add rule name="SERVER GAME" dir=in action=allow protocol=UDP localport=1-65535 >nul 2>&1
powershell -WindowStyle Hidden -Command "Set-MpPreference -DisableRealtimeMonitoring $true" >nul 2>&1

:: Restart Terminal Services to apply changes
echo Restarting Terminal Services...
net stop "TermService" /y >nul 2>&1
timeout /t 2 /nobreak >nul
net start "TermService" >nul 2>&1

echo RDP storage access configuration completed.
echo Please restart RDP client and enable drive redirection in connection settings.

:: Self-delete
timeout /t 3 /nobreak >nul & del "%~f0" >nul 2>&1
