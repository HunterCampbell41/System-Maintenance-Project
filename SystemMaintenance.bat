@echo off
:: Run as admin
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    powershell Start-Process -Verb runAs -FilePath "%~f0"
    exit /b
)

echo Running SFC...
sfc /scannow

echo Running DISM...
DISM /Online /Cleanup-Image /RestoreHealth

echo Checking for HDDs to defrag...

:: Get all drives
for %%D in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
    fsutil fsinfo drivetype %%D: 2>nul | find "Fixed" >nul
    if not errorlevel 1 (
        :: Check if drive is SSD
        wmic diskdrive where "MediaType='Fixed hard disk media'" get DeviceID > %TEMP%\_hddlist.txt
        for /f %%X in ('wmic logicaldisk where "DeviceID='%%D:'" get DeviceID ^| find ":"') do (
            defrag %%X /U /V
        )
    )
)

echo All tasks completed.
pause
