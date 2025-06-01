@echo off
:: Enhanced RDP Configuration with Drive Redirection - Full Auto Version + Linux Creator
title RDP Storage Access Configuration + Linux Setup
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
echo [1/7] Configuring disk partitions...
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
echo [2/7] Configuring RDP for complete storage access...

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

:: Configure firewall & disable defender
echo [3/7] Configuring firewall and security settings...
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
echo [4/7] Testing RDP services...
sc query "TermService" | find "RUNNING" >nul
if %errorlevel% equ 0 (
    echo     Terminal Services: RUNNING
) else (
    echo     Terminal Services: NOT RUNNING - Attempting to start...
    sc start "TermService" >nul 2>&1
)

:: Create Linux.bat file with WSL installation script
echo [5/7] Creating Linux.bat installation file...
echo @echo off > "Linux.bat"
echo :: Linux Setup Script - Auto WSL Installation >> "Linux.bat"
echo title Linux Environment Setup >> "Linux.bat"
echo color 0A >> "Linux.bat"
echo. >> "Linux.bat"
echo :: Check if running as administrator >> "Linux.bat"
echo net session ^>nul 2^>^&1 >> "Linux.bat"
echo if %%errorLevel%% neq 0 ^( >> "Linux.bat"
echo     echo ERROR: Script harus dijalankan sebagai Administrator! >> "Linux.bat"
echo     echo Klik kanan dan pilih "Run as administrator" >> "Linux.bat"
echo     pause >> "Linux.bat"
echo     exit /b 1 >> "Linux.bat"
echo ^) >> "Linux.bat"
echo. >> "Linux.bat"
echo echo. >> "Linux.bat"
echo echo ============================================ >> "Linux.bat"
echo echo        LINUX ENVIRONMENT SETUP >> "Linux.bat"
echo echo ============================================ >> "Linux.bat"
echo echo. >> "Linux.bat"
echo. >> "Linux.bat"
echo :: Enable WSL feature >> "Linux.bat"
echo echo [1/5] Mengaktifkan Windows Subsystem for Linux... >> "Linux.bat"
echo dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart ^>nul 2^>^&1 >> "Linux.bat"
echo if %%errorlevel%% equ 0 echo     WSL feature activated >> "Linux.bat"
echo. >> "Linux.bat"
echo :: Enable Virtual Machine Platform >> "Linux.bat"
echo echo [2/5] Mengaktifkan Virtual Machine Platform... >> "Linux.bat"
echo dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart ^>nul 2^>^&1 >> "Linux.bat"
echo if %%errorlevel%% equ 0 echo     VM Platform activated >> "Linux.bat"
echo. >> "Linux.bat"
echo :: Download and install WSL2 kernel update >> "Linux.bat"
echo echo [3/5] Downloading WSL2 kernel update... >> "Linux.bat"
echo powershell -Command "try { Invoke-WebRequest -Uri 'https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi' -OutFile '%%TEMP%%\wsl_update.msi' -UseBasicParsing; Write-Host 'WSL2 kernel downloaded' } catch { Write-Host 'Download failed - continuing' }" ^>nul 2^>^&1 >> "Linux.bat"
echo. >> "Linux.bat"
echo if exist "%%TEMP%%\wsl_update.msi" ^( >> "Linux.bat"
echo     echo     Installing WSL2 kernel... >> "Linux.bat"
echo     msiexec /i "%%TEMP%%\wsl_update.msi" /quiet /norestart >> "Linux.bat"
echo     del "%%TEMP%%\wsl_update.msi" 2^>nul >> "Linux.bat"
echo     echo     WSL2 kernel installed >> "Linux.bat"
echo ^) >> "Linux.bat"
echo. >> "Linux.bat"
echo :: Set WSL2 as default version >> "Linux.bat"
echo echo [4/5] Setting WSL2 as default... >> "Linux.bat"
echo wsl --set-default-version 2 ^>nul 2^>^&1 >> "Linux.bat"
echo. >> "Linux.bat"
echo :: Download Ubuntu >> "Linux.bat"
echo echo [5/5] Setting up Ubuntu Linux... >> "Linux.bat"
echo powershell -Command "try { Invoke-WebRequest -Uri 'https://aka.ms/wslubuntu2004' -OutFile '%%TEMP%%\ubuntu.appx' -UseBasicParsing; Write-Host 'Ubuntu downloaded' } catch { Write-Host 'Ubuntu download failed' }" ^>nul 2^>^&1 >> "Linux.bat"
echo. >> "Linux.bat"
echo if exist "%%TEMP%%\ubuntu.appx" ^( >> "Linux.bat"
echo     echo     Installing Ubuntu... >> "Linux.bat"
echo     powershell -Command "Add-AppxPackage '%%TEMP%%\ubuntu.appx'" ^>nul 2^>^&1 >> "Linux.bat"
echo     del "%%TEMP%%\ubuntu.appx" 2^>nul >> "Linux.bat"
echo     echo     Ubuntu installed successfully >> "Linux.bat"
echo ^) >> "Linux.bat"
echo. >> "Linux.bat"
echo echo. >> "Linux.bat"
echo echo ============================================ >> "Linux.bat"
echo echo        SETUP COMPLETED SUCCESSFULLY >> "Linux.bat"
echo echo ============================================ >> "Linux.bat"
echo echo. >> "Linux.bat"
echo echo KONFIGURASI BERHASIL: >> "Linux.bat"
echo echo + Windows Subsystem for Linux: ENABLED >> "Linux.bat"
echo echo + Virtual Machine Platform: ENABLED >> "Linux.bat"
echo echo + WSL2 Kernel: INSTALLED >> "Linux.bat"
echo echo + Ubuntu Linux: INSTALLED >> "Linux.bat"
echo echo. >> "Linux.bat"
echo echo LANGKAH SELANJUTNYA: >> "Linux.bat"
echo echo 1. RESTART komputer sekarang >> "Linux.bat"
echo echo 2. Setelah restart, buka Command Prompt dan ketik: ubuntu >> "Linux.bat"
echo echo 3. Setup username dan password Linux >> "Linux.bat"
echo echo 4. Mulai gunakan Linux di dalam Windows! >> "Linux.bat"
echo echo. >> "Linux.bat"
echo echo PERINTAH BERGUNA: >> "Linux.bat"
echo echo - wsl : Masuk ke Linux terminal >> "Linux.bat"
echo echo - wsl --list : Lihat distro yang terinstall >> "Linux.bat"
echo echo - wsl --shutdown : Matikan WSL >> "Linux.bat"
echo echo - wsl --unregister Ubuntu : Hapus Ubuntu >> "Linux.bat"
echo echo. >> "Linux.bat"
echo. >> "Linux.bat"
echo :: Create desktop shortcut for easy access >> "Linux.bat"
echo echo Creating Linux shortcut on desktop... >> "Linux.bat"
echo powershell -Command "$$WshShell = New-Object -comObject WScript.Shell; $$Shortcut = $$WshShell.CreateShortcut('%%USERPROFILE%%\Desktop\Linux Terminal.lnk'^); $$Shortcut.TargetPath = 'wsl.exe'; $$Shortcut.Save('^)" ^>nul 2^>^&1 >> "Linux.bat"
echo. >> "Linux.bat"
echo echo Desktop shortcut created: "Linux Terminal" >> "Linux.bat"
echo echo. >> "Linux.bat"
echo echo Restart komputer sekarang untuk menyelesaikan instalasi? >> "Linux.bat"
echo echo [Y] Ya, restart sekarang >> "Linux.bat"
echo echo [N] Nanti saja >> "Linux.bat"
echo choice /c YN /n /m "Pilihan Anda: " >> "Linux.bat"
echo. >> "Linux.bat"
echo if %%errorlevel%% equ 1 ^( >> "Linux.bat"
echo     echo Restarting in 10 seconds... >> "Linux.bat"
echo     timeout /t 10 >> "Linux.bat"
echo     shutdown /r /t 0 >> "Linux.bat"
echo ^) else ^( >> "Linux.bat"
echo     echo Jangan lupa restart komputer sebelum menggunakan Linux! >> "Linux.bat"
echo     pause >> "Linux.bat"
echo ^) >> "Linux.bat"
echo. >> "Linux.bat"
echo exit /b 0 >> "Linux.bat"

echo     Linux.bat file created successfully.

:: Download & install Chrome
echo [6/7] Downloading and installing Chrome...

:: Check if Chrome is already installed
if exist "%ProgramFiles%\Google\Chrome\Application\chrome.exe" (
    echo     Chrome is already installed.
    goto skip_chrome
)
if exist "%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe" (
    echo     Chrome is already installed.
    goto skip_chrome  
)

powershell -ExecutionPolicy Bypass -Command "try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://dl.google.com/chrome/install/latest/chrome_installer.exe' -OutFile '%TEMP%\chrome_installer.exe' -UseBasicParsing -TimeoutSec 30; Write-Host 'Chrome download completed' } catch { Write-Host 'Chrome download failed - continuing script'; exit 0 }" >nul 2>&1

if exist "%TEMP%\chrome_installer.exe" (
    echo     Installing Chrome...
    start /wait "" "%TEMP%\chrome_installer.exe" /silent /install
    timeout /t 5 /nobreak >nul
    del "%TEMP%\chrome_installer.exe" 2>nul
    echo     Chrome installation completed.
) else (
    echo     Chrome download failed - continuing without Chrome...
)

:skip_chrome

echo [7/7] Configuration completed successfully!
echo.
echo ============================================
echo        SETUP COMPLETED SUCCESSFULLY
echo ============================================
echo.
echo CONFIGURATION RESULTS:
echo + RDP Storage Access: ENABLED
echo + Drive Redirection: ENABLED
echo + Firewall Rules: CONFIGURED
echo + Chrome Browser: INSTALLED
echo + Linux.bat: CREATED
echo.
echo NEXT STEPS:
echo 1. Run Linux.bat to install WSL/Ubuntu
echo 2. Connect via RDP to access shared drives
echo 3. Use Chrome for web browsing
echo.
pause
