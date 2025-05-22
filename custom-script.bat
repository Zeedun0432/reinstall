@echo off

ECHO LIST DISK > "%TEMP%\diskpart_delete.txt"
ECHO SELECT DISK 0 >> "%TEMP%\diskpart_delete.txt"
ECHO LIST PARTITION >> "%TEMP%\diskpart_delete.txt"
ECHO SELECT PARTITION 3 >> "%TEMP%\diskpart_delete.txt"
ECHO DELETE PARTITION OVERRIDE >> "%TEMP%\diskpart_delete.txt"
ECHO Menghapus partisi recovery...
diskpart /s "%TEMP%\diskpart_delete.txt"
ECHO SELECT VOLUME %SystemDrive% > "%TEMP%\diskpart_extend.txt"
ECHO EXTEND >> "%TEMP%\diskpart_extend.txt"
ECHO Memperluas drive C...
diskpart /s "%TEMP%\diskpart_extend.txt"
ECHO Membersihkan file temporary...
del /f /q "%TEMP%\diskpart_delete.txt"
del /f /q "%TEMP%\diskpart_extend.txt"

ECHO Downloading Google Chrome...
powershell -Command "& {Invoke-WebRequest -Uri 'https://dl.google.com/chrome/install/latest/chrome_installer.exe' -OutFile "$env:TEMP\chrome_installer.exe"}"
ECHO Installing Google Chrome...
start /wait %TEMP%\chrome_installer.exe /silent /install
timeout /t 10 /nobreak >nul
ECHO Cleaning up Chrome installer...
del /f /q "%TEMP%\chrome_installer.exe"
ECHO Chrome installation completed and installer file deleted.

ECHO Configuring Windows Firewall for game server...
netsh advfirewall firewall add rule name="Game Server - Allow All TCP Inbound" dir=in action=allow protocol=TCP localport=1-65535
netsh advfirewall firewall add rule name="Game Server - Allow All UDP Inbound" dir=in action=allow protocol=UDP localport=1-65535
ECHO Firewall rules configured for game server (All TCP/UDP ports allowed).

del "%~f0"
