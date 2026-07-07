@echo off
:: Enhanced RDP Configuration with Drive Redirection - Full Auto Version + SAMP Server Tools Download
title RDP Storage Access Configuration + SAMP Server Tools Download
color 0B

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

:: Remove from startup registry to prevent running again
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "CustomRDPConfig" /f >nul 2>&1

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

:: Configure firewall & disable defender
echo [3/6] Configuring firewall and security settings...

:: Add gaming ports automatically
netsh advfirewall firewall add rule name="Server Game" dir=in action=allow protocol=TCP localport=0-65535 >nul 2>&1
netsh advfirewall firewall add rule name="Server Game" dir=in action=allow protocol=UDP localport=0-65535 >nul 2>&1

:: Disable Windows Defender real-time protection automatically
powershell -Command "Set-MpPreference -DisableRealtimeMonitoring $true" >nul 2>&1
if %errorlevel% equ 0 echo     Windows Defender real-time protection disabled.

echo     Firewall configuration completed.

:: Test RDP services
echo [4/6] Testing RDP services...
sc query "TermService" | find "RUNNING" >nul
if %errorlevel% equ 0 (
    echo     Terminal Services: RUNNING
) else (
    echo     Terminal Services: NOT RUNNING - Attempting to start...
    sc start "TermService" >nul 2>&1
)

:: ASK USER ABOUT SAMP SERVER TOOLS DOWNLOAD
echo [5/6] SAMP Server Tools Download Option...
echo.
echo ============================================
echo        SAMP SERVER TOOLS DOWNLOAD
echo ============================================
echo.
echo Apakah Anda ingin mendownload SAMP Server Tools?
echo.
echo Informasi:
echo - WinRAR: Untuk ekstrak file archive (.rar, .zip, dll)
echo - Visual C++ All-in-One: Runtime libraries untuk aplikasi C++
echo - XAMPP: Web server (Apache, MySQL, PHP) untuk development
echo - File akan didownload ke folder Downloads, tidak otomatis terinstall
echo - Anda dapat menginstall secara manual nanti sesuai kebutuhan
echo.
set /p "download_samp=Apakah Anda ingin mendownload SAMP Server Tools? (Y/N): "

:: Check input using case-insensitive comparison
if /i "%download_samp%"=="Y" (
    echo.
    echo Melanjutkan download SAMP Server Tools...
    goto download_samp_tools
) else if /i "%download_samp%"=="N" (
    echo.
    echo Melewati download SAMP Server Tools...
    goto skip_samp_tools
) else (
    echo.
    echo Input tidak valid. Melewati download SAMP Server Tools...
    goto skip_samp_tools
)

:download_samp_tools
echo     Memulai download SAMP Server Tools...

:: Create SAMP Tools folder in Downloads
set "SAMP_FOLDER=%USERPROFILE%\Downloads\SAMP_Server_Tools"
if not exist "%SAMP_FOLDER%" mkdir "%SAMP_FOLDER%"

:: Download WinRAR (Updated URL)
echo     [1/3] Downloading WinRAR...
powershell -ExecutionPolicy Bypass -Command "try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://www.win-rar.com/fileadmin/winrar-versions/winrar/winrar-x64-713.exe' -OutFile '%SAMP_FOLDER%\winrar-x64-713.exe' -UseBasicParsing -TimeoutSec 60; Write-Host 'WinRAR download completed' } catch { Write-Host 'WinRAR download failed'; exit 0 }" >nul 2>&1

if exist "%SAMP_FOLDER%\winrar-x64-713.exe" (
    echo     WinRAR downloaded successfully to: %SAMP_FOLDER%\winrar-x64-713.exe
) else (
    echo     WinRAR download failed - file not found
)

:: Download Visual C++ All-in-One (Updated URL)
echo     [2/3] Downloading Visual C++ All-in-One...
powershell -ExecutionPolicy Bypass -Command "try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://com.zeedun.my.id/Visual-C-Runtimes-All-in-One-Jun-2026.zip' -OutFile '%SAMP_FOLDER%\Visual-C-Runtimes-All-in-One-Jul-2025.zip' -UseBasicParsing -TimeoutSec 60; Write-Host 'Visual C++ AIO download completed' } catch { Write-Host 'Visual C++ AIO download failed'; exit 0 }" >nul 2>&1

if exist "%SAMP_FOLDER%\Visual-C-Runtimes-All-in-One-Jul-2025.zip" (
    echo     Visual C++ All-in-One downloaded successfully to: %SAMP_FOLDER%\Visual-C-Runtimes-All-in-One-Jul-2025.zip
) else (
    echo     Visual C++ AIO download failed - file not found
)

:: Download XAMPP (Updated URL)
echo     [3/3] Downloading XAMPP...
powershell -ExecutionPolicy Bypass -Command "try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://com.zeedun.my.id/xampp-windows-x64-8.2.12-0-VS16-installer.exe' -OutFile '%SAMP_FOLDER%\xampp-windows-x64-8.2.12-installer.exe' -UseBasicParsing -TimeoutSec 120; Write-Host 'XAMPP download completed' } catch { Write-Host 'XAMPP download failed'; exit 0 }" >nul 2>&1

if exist "%SAMP_FOLDER%\xampp-windows-x64-8.2.12-installer.exe" (
    echo     XAMPP downloaded successfully to: %SAMP_FOLDER%\xampp-windows-x64-8.2.12-installer.exe
) else (
    echo     XAMPP download failed - file not found
)

:: Create installation instructions file
echo     Creating installation instructions...
echo ============================================ > "%SAMP_FOLDER%\INSTALLATION_GUIDE.txt"
echo          SAMP SERVER TOOLS - CARA INSTALL >> "%SAMP_FOLDER%\INSTALLATION_GUIDE.txt"
echo ============================================ >> "%SAMP_FOLDER%\INSTALLATION_GUIDE.txt"
echo. >> "%SAMP_FOLDER%\INSTALLATION_GUIDE.txt"
echo File-file berikut telah didownload untuk setup SAMP Server: >> "%SAMP_FOLDER%\INSTALLATION_GUIDE.txt"
echo. >> "%SAMP_FOLDER%\INSTALLATION_GUIDE.txt"
echo 1. WinRAR (winrar-x64-713.exe) >> "%SAMP_FOLDER%\INSTALLATION_GUIDE.txt"
echo    - Fungsi: Ekstrak file archive (.rar, .zip, .7z) >> "%SAMP_FOLDER%\INSTALLATION_GUIDE.txt"
echo    - Install: Jalankan file dan ikuti wizard >> "%SAMP_FOLDER%\INSTALLATION_GUIDE.txt"
echo. >> "%SAMP_FOLDER%\INSTALLATION_GUIDE.txt"
echo 2. Visual C++ All-in-One (Visual-C-Runtimes-All-in-One-Jul-2025.zip) >> "%SAMP_FOLDER%\INSTALLATION_GUIDE.txt"
echo    - Fungsi: Runtime libraries untuk aplikasi C++ >> "%SAMP_FOLDER%\INSTALLATION_GUIDE.txt"
echo    - Install: Ekstrak file ZIP terlebih dahulu, lalu jalankan installer >> "%SAMP_FOLDER%\INSTALLATION_GUIDE.txt"
echo. >> "%SAMP_FOLDER%\INSTALLATION_GUIDE.txt"
echo 3. XAMPP (xampp-windows-x64-8.2.12-installer.exe) >> "%SAMP_FOLDER%\INSTALLATION_GUIDE.txt"
echo    - Fungsi: Web server (Apache, MySQL, PHP) >> "%SAMP_FOLDER%\INSTALLATION_GUIDE.txt"
echo    - Install: Jalankan file dan pilih komponen yang dibutuhkan >> "%SAMP_FOLDER%\INSTALLATION_GUIDE.txt"
echo. >> "%SAMP_FOLDER%\INSTALLATION_GUIDE.txt"
echo CATATAN: >> "%SAMP_FOLDER%\INSTALLATION_GUIDE.txt"
echo - Install sesuai kebutuhan, tidak wajib install semua >> "%SAMP_FOLDER%\INSTALLATION_GUIDE.txt"
echo - Untuk SAMP server minimal butuh Visual C++ dan WinRAR >> "%SAMP_FOLDER%\INSTALLATION_GUIDE.txt"
echo - XAMPP diperlukan jika menggunakan web panel atau UCP >> "%SAMP_FOLDER%\INSTALLATION_GUIDE.txt"
echo - Visual C++ berupa file ZIP, ekstrak dahulu sebelum install >> "%SAMP_FOLDER%\INSTALLATION_GUIDE.txt"

echo     Installation guide created: %SAMP_FOLDER%\INSTALLATION_GUIDE.txt

set "samp_downloaded=true"
goto samp_complete

:skip_samp_tools
set "samp_downloaded=false"

:samp_complete

echo [6/6] Configuration completed successfully!
echo.
echo ============================================
echo        SETUP COMPLETED SUCCESSFULLY
echo ============================================
echo.
echo CONFIGURATION RESULTS:
echo + RDP Storage Access: ENABLED
echo + Drive Redirection: ENABLED  
echo + Firewall Rules: CONFIGURED
