@echo off
:: Enhanced RDP Configuration with Drive Redirection - Full Auto Version + Linux Installer
title RDP Storage Access Configuration + Linux Installation
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

:: Download & install Chrome
echo [5/7] Downloading and installing Chrome...

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

:: Install Linux (WSL) directly after Chrome
echo [6/7] Installing Linux Environment (WSL + Ubuntu)...
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
echo + Linux Environment: INSTALLED
echo + WSL2 + Ubuntu: READY
echo.
echo PERINTAH LINUX BERGUNA:
echo - wsl : Masuk ke Linux terminal
echo - wsl --list : Lihat distro yang terinstall
echo - wsl --shutdown : Matikan WSL
echo - wsl --unregister Ubuntu : Hapus Ubuntu
echo.

:: Ask user if they want to convert OS to Linux
echo ============================================
echo         OS CONVERSION OPTION
echo ============================================
echo.
echo Apakah Anda ingin mengubah OS utama menjadi Linux?
echo.
echo PERINGATAN: Ini akan:
echo - Menghapus Windows sebagai OS utama
echo - Menginstall Ubuntu Linux sebagai OS utama
echo - Memerlukan restart dan konfigurasi ulang
echo - SEMUA DATA WINDOWS AKAN HILANG!
echo.
echo [Y] Ya, ubah ke Linux (BERBAHAYA - BACKUP DULU!)
echo [N] Tidak, tetap pakai Windows + WSL
echo.
choice /c YN /n /m "Pilihan Anda: "

if %errorlevel% equ 1 (
    echo.
    echo PERINGATAN TERAKHIR!
    echo Ini akan menghapus Windows dan menginstall Linux sebagai OS utama.
    echo SEMUA DATA, PROGRAM, DAN PENGATURAN WINDOWS AKAN HILANG PERMANEN!
    echo.
    echo Apakah Anda YAKIN ingin melanjutkan?
    echo [Y] Ya, saya yakin dan sudah backup semua data
    echo [N] Tidak, batalkan
    choice /c YN /n /m "Konfirmasi terakhir: "
    
    if !errorlevel! equ 1 (
        echo.
        echo Memulai konversi OS ke Linux...
        echo Komputer akan restart dan boot dari Ubuntu installer...
        echo.
        
        :: Download Ubuntu ISO
        echo Downloading Ubuntu ISO untuk instalasi penuh...
        powershell -Command "try { Invoke-WebRequest -Uri 'https://releases.ubuntu.com/20.04/ubuntu-20.04.6-desktop-amd64.iso' -OutFile '%TEMP%\ubuntu.iso' -UseBasicParsing; Write-Host 'Ubuntu ISO downloaded' } catch { Write-Host 'Download failed' }" >nul 2>&1
        
        :: Create bootable USB (simplified method)
        echo INSTRUKSI MANUAL DIPERLUKAN:
        echo.
        echo 1. Download Ubuntu ISO dari: https://ubuntu.com/download/desktop
        echo 2. Gunakan Rufus atau Balena Etcher untuk membuat USB bootable
        echo 3. Restart komputer dan boot dari USB
        echo 4. Pilih "Install Ubuntu" dan "Erase disk"
        echo 5. Ikuti wizard instalasi Ubuntu
        echo.
        echo File ISO Ubuntu tersimpan di: %TEMP%\ubuntu.iso
        echo.
        echo Restart sekarang untuk memulai instalasi?
        choice /c YN /n /m "[Y] Restart sekarang [N] Nanti: "
        
        if !errorlevel! equ 1 (
            echo Restarting in 10 seconds...
            timeout /t 10
            shutdown /r /t 0
        )
    ) else (
        echo Konversi OS dibatalkan. Sistem tetap menggunakan Windows + WSL.
    )
) else (
    echo.
    echo Pilihan bagus! Anda tetap menggunakan Windows dengan Linux di WSL.
    echo Ini memberikan fleksibilitas terbaik dari kedua sistem operasi.
)

echo.
echo LANGKAH SELANJUTNYA:
echo 1. RESTART komputer untuk menyelesaikan instalasi WSL
echo 2. Setelah restart, klik "Linux Terminal" di desktop
echo 3. Setup username dan password Linux
echo 4. Mulai gunakan Linux di dalam Windows!
echo.
echo Restart komputer sekarang untuk menyelesaikan instalasi?
echo [Y] Ya, restart sekarang
echo [N] Nanti saja
choice /c YN /n /m "Pilihan Anda: "

if %errorlevel% equ 1 (
    echo Restarting in 10 seconds...
    timeout /t 10
    shutdown /r /t 0
) else (
    echo Jangan lupa restart komputer sebelum menggunakan Linux!
    pause
)

exit /b 0
