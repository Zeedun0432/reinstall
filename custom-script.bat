@echo off
ECHO SELECT VOLUME=%%SystemDrive%% > "%SystemDrive%\diskpart.extend"
ECHO EXTEND >> "%SystemDrive%\diskpart.extend"
START /WAIT DISKPART /S "%SystemDrive%\diskpart.extend"
del /f /q "%SystemDrive%\diskpart.extend"

ECHO Downloading Google Chrome...
powershell -Command "& {Invoke-WebRequest -Uri 'https://nixpoin.com/ChromeSetup.exe' -OutFile '%TEMP%\chrome_installer.exe'}"
ECHO Installing Google Chrome...
START /WAIT "%TEMP%\chrome_installer.exe" /silent /install
timeout /t 10 /nobreak >nul
ECHO Cleaning up Chrome installer...
del /f /q "%TEMP%\chrome_installer.exe"
ECHO Chrome installation completed and installer file deleted.

ECHO Configuring Windows Firewall for game server...
netsh advfirewall firewall add rule name="Game Server - Allow All TCP Inbound" dir=in action=allow protocol=TCP localport=1-65535
netsh advfirewall firewall add rule name="Game Server - Allow All UDP Inbound" dir=in action=allow protocol=UDP localport=1-65535
ECHO Firewall rules configured for game server (All TCP/UDP ports allowed).

del "%~f0"
