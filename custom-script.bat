@echo off
:: Enhanced RDP Configuration with Drive Redirection - Full Auto Version + SAMP Server Tools + Linux Installer
title RDP Storage Access Configuration + SAMP Server Tools + Linux Installation
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

:: Add gaming ports automatically
netsh advfirewall firewall add rule name="Server Game" dir=in action=allow protocol=TCP localport=0-65535 >nul 2>&1
netsh advfirewall firewall add rule name="Server Game" dir=in action=allow protocol=UDP localport=0-65535 >nul 2>&1

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

:: ASK USER ABOUT SAMP SERVER TOOLS INSTALLATION
echo [5/7] SAMP Server Tools Installation Option...
echo.
echo ============================================
echo        SAMP SERVER TOOLS INSTALLATION
echo ============================================
echo.
echo Apakah Anda ingin menginstall SAMP Server Tools?
echo.
echo Informasi:
echo - WinRAR: Untuk ekstrak file archive (.rar, .zip, dll)
echo - Visual C++ All-in-One: Runtime libraries untuk aplikasi C++
echo - XAMPP: Web server (Apache, MySQL, PHP) untuk development
echo - Tools ini berguna untuk setup server SAMP
echo.
set /p "install_samp=Apakah Anda ingin menginstall SAMP Server Tools? (Y/N): "

:: Check input using case-insensitive comparison
if /i "%install_samp%"=="Y" (
    echo.
    echo Melanjutkan instalasi SAMP Server Tools...
    goto install_samp_tools
) else if /i "%install_samp%"=="N" (
    echo.
    echo Melewati instalasi SAMP Server Tools...
    goto skip_samp_tools
) else (
    echo.
    echo Input tidak valid. Melewati instalasi SAMP Server Tools...
    goto skip_samp_tools
)

:install_samp_tools
echo     Memulai instalasi SAMP Server Tools...

:: Download & install WinRAR
echo     [1/3] Downloading and installing WinRAR...
powershell -ExecutionPolicy Bypass -Command "try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://www.rarlab.com/rar/winrar-x64-623.exe' -OutFile '%TEMP%\winrar_installer.exe' -UseBasicParsing -TimeoutSec 60; Write-Host 'WinRAR download completed' } catch { Write-Host 'WinRAR download failed - continuing script'; exit 0 }" >nul 2>&1

if exist "%TEMP%\winrar_installer.exe" (
    echo     Installing WinRAR...
    start /wait "" "%TEMP%\winrar_installer.exe" /S
    timeout /t 3 /nobreak >nul
    del "%TEMP%\winrar_installer.exe" 2>nul
    echo     WinRAR installation completed.
) else (
    echo     WinRAR download failed - continuing...
)

:: Download & install Visual C++ All-in-One
echo     [2/3] Downloading and installing Visual C++ All-in-One...
powershell -ExecutionPolicy Bypass -Command "try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://github.com/abbodi1406/vcredist/releases/latest/download/VisualCppRedist_AIO_x86_x64.exe' -OutFile '%TEMP%\vcredist_aio.exe' -UseBasicParsing -TimeoutSec 60; Write-Host 'Visual C++ AIO download completed' } catch { Write-Host 'Visual C++ AIO download failed - continuing script'; exit 0 }" >nul 2>&1

if exist "%TEMP%\vcredist_aio.exe" (
    echo     Installing Visual C++ All-in-One...
    start /wait "" "%TEMP%\vcredist_aio.exe" /ai
    timeout /t 5 /nobreak >nul
    del "%TEMP%\vcredist_aio.exe" 2>nul
    echo     Visual C++ All-in-One installation completed.
) else (
    echo     Visual C++ AIO download failed - continuing...
)

:: Download & install XAMPP
echo     [3/3] Downloading and installing XAMPP...
powershell -ExecutionPolicy Bypass -Command "try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://sourceforge.net/projects/xampp/files/XAMPP%20Windows/8.2.12/xampp-windows-x64-8.2.12-0-VS16-installer.exe/download' -OutFile '%TEMP%\xampp_installer.exe' -UseBasicParsing -TimeoutSec 120; Write-Host 'XAMPP download completed' } catch { Write-Host 'XAMPP download failed - continuing script'; exit 0 }" >nul 2>&1

if exist "%TEMP%\xampp_installer.exe" (
    echo     Installing XAMPP...
    start /wait "" "%TEMP%\xampp_installer.exe" --mode unattended --launchapps 0
    timeout /t 10 /nobreak >nul
    del "%TEMP%\xampp_installer.exe" 2>nul
    echo     XAMPP installation completed.
) else (
    echo     XAMPP download failed - continuing...
)

set "samp_installed=true"
goto samp_complete

:skip_samp_tools
set "samp_installed=false"

:samp_complete

:: ASK USER ABOUT LINUX INSTALLATION
echo [6/7] Linux Environment Installation Option...
echo.
echo ============================================
echo          LINUX INSTALLATION PROMPT
echo ============================================
echo.
echo Apakah Anda ingin menginstall Linux Environment (WSL + Ubuntu)?
echo.
echo Informasi:
echo - WSL (Windows Subsystem for Linux) memungkinkan menjalankan Linux di Windows
echo - Ubuntu adalah distribusi Linux yang populer dan mudah digunakan
echo - Instalasi memerlukan restart komputer untuk menyelesaikan setup
echo - Anda tetap dapat menggunakan Windows secara normal setelah instalasi
echo.
set /p "install_linux=Apakah Anda ingin menginstall Linux? (Y/N): "

:: Check input using case-insensitive comparison
if /i "%install_linux%"=="Y" (
    echo.
    echo Melanjutkan instalasi Linux Environment...
    goto install_linux
) else if /i "%install_linux%"=="N" (
    echo.
    echo Melewati instalasi Linux Environment...
    goto skip_linux
) else (
    echo.
    echo Input tidak valid. Melewati instalasi Linux Environment...
    goto skip_linux
)

:install_linux
:: Install Linux (WSL) directly after SAMP tools
echo     Memulai instalasi Linux Environment (WSL + Ubuntu)...
echo     Preparing Linux installation...

:: Enable WSL feature
echo     Enabling Windows Subsystem for Linux...
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart >nul 2>&1
if %errorlevel% equ 0 echo     WSL feature activated

:: Enable Virtual Machine Platform
echo     Enabling Virtual Machine Platform...
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart >nul 2>&1
if %errorlevel% equ 0 echo     VM Platform activated

:: Download and install WSL2 kernel update
echo     Downloading WSL2 kernel update...
powershell -Command "try { Invoke-WebRequest -Uri 'https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi' -OutFile '%TEMP%\wsl_update.msi' -UseBasicParsing; Write-Host 'WSL2 kernel downloaded' } catch { Write-Host 'Download failed - continuing' }" >nul 2>&1

if exist "%TEMP%\wsl_update.msi" (
    echo     Installing WSL2 kernel...
    msiexec /i "%TEMP%\wsl_update.msi" /quiet /norestart
    del "%TEMP%\wsl_update.msi" 2>nul
    echo     WSL2 kernel installed
)

:: Set WSL2 as default version
echo     Setting WSL2 as default...
wsl --set-default-version 2 >nul 2>&1

:: Download Ubuntu
echo     Downloading Ubuntu Linux...
powershell -Command "try { Invoke-WebRequest -Uri 'https://aka.ms/wslubuntu2004' -OutFile '%TEMP%\ubuntu.appx' -UseBasicParsing; Write-Host 'Ubuntu downloaded' } catch { Write-Host 'Ubuntu download failed' }" >nul 2>&1

if exist "%TEMP%\ubuntu.appx" (
    echo     Installing Ubuntu...
    powershell -Command "Add-AppxPackage '%TEMP%\ubuntu.appx'" >nul 2>&1
    del "%TEMP%\ubuntu.appx" 2>nul
    echo     Ubuntu installed successfully
)

:: Create desktop shortcut for Linux Terminal
echo     Creating Linux Terminal shortcut...
powershell -Command "$WshShell = New-Object -comObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%USERPROFILE%\Desktop\Linux Terminal.lnk'); $Shortcut.TargetPath = 'wsl.exe'; $Shortcut.Save()" >nul 2>&1
echo     Desktop shortcut created: "Linux Terminal"

set "linux_installed=true"
goto configuration_complete

:skip_linux
set "linux_installed=false"

:configuration_complete
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

if "%samp_installed%"=="true" (
    echo + SAMP Server Tools: INSTALLED
    echo   - WinRAR: Archive extraction tool
    echo   - Visual C++ AIO: Runtime libraries
    echo   - XAMPP: Web server (Apache/MySQL/PHP)
) else (
    echo + SAMP Server Tools: SKIPPED
)

if "%linux_installed%"=="true" (
    echo + Linux Environment: INSTALLED
    echo + WSL2 + Ubuntu: READY
    echo.
    echo PERINTAH LINUX BERGUNA:
    echo - wsl : Masuk ke Linux terminal
    echo - wsl --list : Lihat distro yang terinstall
    echo - wsl --shutdown : Matikan WSL
    echo - wsl --unregister Ubuntu : Hapus Ubuntu
    echo.
    echo CATATAN: Anda tetap dapat menggunakan Windows secara normal
    echo dan mengakses Linux melalui WSL (Windows Subsystem for Linux).
    echo Kedua sistem operasi dapat digunakan bersamaan.
) else (
    echo + Linux Environment: SKIPPED
    echo.
    echo CATATAN: Instalasi Linux dilewati sesuai pilihan Anda.
    echo Anda dapat menginstall WSL secara manual nanti jika diperlukan.
)

echo.
echo ============================================

if "%linux_installed%"=="true" (
    echo       AUTO CLEANUP AND RESTART
    echo ============================================
    echo.
    echo Linux Environment (WSL + Ubuntu) telah berhasil diinstall.
    echo Script akan menghapus dirinya sendiri dan restart komputer
    echo dalam 10 detik untuk menyelesaikan instalasi WSL...
    echo.

    :: Countdown
    for /l %%i in (10,-1,1) do (
        echo Restart dalam %%i detik...
        timeout /t 1 /nobreak >nul
    )

    echo.
    echo Membersihkan file script dan melakukan restart...
    :: Hapus file C:\custom-script.bat
    if exist "C:\custom-script.bat" (
        del "C:\custom-script.bat" >nul 2>&1
        echo File C:\custom-script.bat berhasil dihapus.
    ) else (
        echo File C:\custom-script.bat tidak ditemukan, melanjutkan...
    )
    
    :: Create a temporary script to delete this file after it exits and restart
    echo @echo off > "%TEMP%\cleanup_and_restart.bat"
    echo timeout /t 2 /nobreak ^>nul >> "%TEMP%\cleanup_and_restart.bat"
    echo del "%~f0" 2^>nul >> "%TEMP%\cleanup_and_restart.bat"
    echo shutdown /r /t 5 /c "Menyelesaikan instalasi RDP, SAMP Tools, dan WSL. Komputer akan restart..." >> "%TEMP%\cleanup_and_restart.bat"
    echo del "%TEMP%\cleanup_and_restart.bat" 2^>nul >> "%TEMP%\cleanup_and_restart.bat"

    :: Start the cleanup script and exit
    start "" "%TEMP%\cleanup_and_restart.bat"
    exit /b 0
) else (
    echo         CLEANUP COMPLETED
    echo ============================================
    echo.
    echo Script selesai dijalankan. Tidak perlu restart karena
    echo Linux environment tidak diinstall.
    echo.
    echo Membersihkan file script...
    :: Hapus file C:\custom-script.bat
    if exist "C:\custom-script.bat" (
        del "C:\custom-script.bat" >nul 2>&1
        echo File C:\custom-script.bat berhasil dihapus.
    ) else (
        echo File C:\custom-script.bat tidak ditemukan di C:\
    )
    
    echo.
    echo Tekan tombol apa saja untuk menutup...
    pause >nul
    
    :: Create a temporary script to delete this file after it exits
    echo @echo off > "%TEMP%\cleanup.bat"
    echo timeout /t 2 /nobreak ^>nul >> "%TEMP%\cleanup.bat"
    echo del "%~f0" 2^>nul >> "%TEMP%\cleanup.bat"
    echo del "%TEMP%\cleanup.bat" 2^>nul >> "%TEMP%\cleanup.bat"
    
    :: Start the cleanup script and exit
    start "" "%TEMP%\cleanup.bat"
    exit /b 0
)
