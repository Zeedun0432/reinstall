@echo off

net user admin %Password123%
net user administrator %Password123%

@REM del "%~f0"