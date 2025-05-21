@echo off
ECHO SELECT VOLUME=%%SystemDrive%% > "%SystemDrive%\diskpart.extend"
ECHO EXTEND >> "%SystemDrive%\diskpart.extend"
START /WAIT DISKPART /S "%SystemDrive%\diskpart.extend"
del /f /q "%SystemDrive%\diskpart.extend"

REM Download and install Chrome
ECHO Downloading Google Chrome...
powershell -Command "& {Invoke-WebRequest -Uri 'https://dl.google.com/chrome/install/latest/chrome_installer.exe' -OutFile '%TEMP%\chrome_installer.exe'}"

ECHO Installing Google Chrome...
START /WAIT "%TEMP%\chrome_installer.exe" /silent /install

REM Wait a moment for installation to complete
timeout /t 10 /nobreak >nul

REM Delete Chrome installer file
ECHO Cleaning up Chrome installer...
del /f /q "%TEMP%\chrome_installer.exe"

ECHO Chrome installation completed and installer file deleted.

del "%~f0"
