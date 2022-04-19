@ECHO OFF
SETLOCAL EnableDelayedExpansion
CLS

:: BatchGotAdmin
:: Source: https://stackoverflow.com/a/10052222
:-------------------------------------
:: Check For Permissions
REM  --> Check For Permissions
IF "%PROCESSOR_ARCHITECTURE%" EQU "amd64" (
>nul 2>&1 "%SYSTEMROOT%\SysWOW64\cacls.exe" "%SYSTEMROOT%\SysWOW64\config\system"
) ELSE (
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
)

:: Not Admin
:: If Error Flag Set, We Do Not Have Admin.
REM --> If Error Flag Set, We Do Not Have Admin.
IF "%ERRORLEVEL%" NEQ "0" (
    :: Now Escalating Privileges
    ECHO Requesting Administrative Privileges...
    GOTO UACPrompt
) ELSE ( GOTO GotAdmin )

:: UAC Prompt
:UACPrompt
    ECHO Set UAC = CreateObject^("Shell.Application"^) >> "%TEMP%\getadmin.vbs"
    SET params= %*
    ECHO UAC.ShellExecute "cmd.exe", "/c ""%~s0"" %params:"=""%", "", "runas", 1 >> "%TEMP%\getadmin.vbs"

    "%TEMP%\getadmin.vbs"
    DEL "%TEMP%\getadmin.vbs"
    EXIT /B

:: Actual Script
:GotAdmin
    PUSHD "%CD%"
    CD /D "%~dp0"
:-------------------------------------

:: Menu
:MENU
SET VERSION=v1.0
TITLE Hyper-V-Toggle %VERSION%
CLS
for /f "tokens=4-6 delims=[] " %%G in ('ver') do set WINVER=%%G
ECHO .................................................................................
:::   _    _                           __      __  _______                _
:::  | |  | |                          \ \    / / |__   __|              | |
:::  | |__| |_   _ _ __   ___ _ __ _____\ \  / /_____| | ___   __ _  __ _| | ___
:::  |  __  | | | | '_ \ / _ \ '__|______\ \/ /______| |/ _ \ / _` |/ _` | |/ _ \
:::  | |  | | |_| | |_) |  __/ |          \  /       | | (_) | (_| | (_| | |  __/
:::  |_|  |_|\__, | .__/ \___|_|           \/        |_|\___/ \__, |\__, |_|\___|
:::           __/ | |                                          __/ | __/ |
:::          |___/|_|                                         |___/ |___/
:::
for /f "delims=: tokens=*" %%A in ('findstr /b ::: "%~f0"') do @echo(%%A
ECHO .................................................................................
ECHO.
ECHO Hyper-V-Toggle %VERSION%
ECHO.
ECHO Windows Version: %WINVER%
ECHO.
ECHO Hyper-V Status:
ECHO -----------------------------
bcdedit /enum | find /I "hypervisorlaunchtype"
ECHO -----------------------------
ECHO.
ECHO   1 - Enable Hyper-V
ECHO   2 - Disable Hyper-V
ECHO   3 - Info
ECHO   4 - Exit
ECHO.

:: Options Set By User
SET /P M="Select An Option And Then Press ENTER: "
IF "%M%" == "1" GOTO ENABLE
IF "%M%" == "2" GOTO DISABLE
IF "%M%" == "3" GOTO INFO
IF "%M%" == "4" GOTO EOF
GOTO MENU

:: Enable Hyper-V
:ENABLE
CLS
ECHO Enabling Hyper-V...
ECHO.
bcdedit /set hypervisorlaunchtype auto
ECHO.
ECHO Hyper-V Status:
ECHO -----------------------------
bcdedit /enum | find /I "hypervisorlaunchtype"
ECHO -----------------------------
ECHO.
GOTO REBOOT

:: Disable Hyper-V
:DISABLE
CLS
ECHO Disabling Hyper-V...
ECHO.
bcdedit /set hypervisorlaunchtype off
ECHO.
ECHO Hyper-V Status:
ECHO -----------------------------
bcdedit /enum | find /I "hypervisorlaunchtype"
ECHO -----------------------------
ECHO.
GOTO REBOOT

:: Show Info
:INFO
CLS
ECHO ==========================================================
ECHO.
ECHO  Hyper-V-Toggle %VERSION%
ECHO.
ECHO  Made By RC Chuah-(RaynerSec)
ECHO.
ECHO  https://github.com/rc-chuah/Hyper-V-Toggle
ECHO  https://github.com/RaynerSec/Hyper-V-Toggle
ECHO ----------------------------------------------------------
ECHO                  -- Licensed GNU GPL v3.0 --
ECHO.
ECHO  A Batch Script Made For Easily Disabling And Enabling
ECHO  Hyper-V For Usage Of Virtualization Products
ECHO  Without Uninstalling Windows Subsystem For Linux
ECHO  (WSL) And Hyper-V Hypervisor Features In Windows.
ECHO  Feel Free To Contribute On The Github Page.
ECHO.
ECHO   1 - Main Menu
ECHO   2 - Exit
ECHO.
ECHO ==========================================================
ECHO.

:: Options Set By User
SET /P N="Select An Option And Then Press ENTER: "
IF "%N%" == "1" GOTO MENU
IF "%N%" == "2" GOTO EOF

:: Reboot
:REBOOT
ECHO Operation Complete, Reboot Is Required To Apply Changes.
ECHO.
    :: Options Set By User
    SET /P O="Do You Want To Reboot Now? [Y/n]: "
    IF /I "%O%" == "y" (
        CLS
        ECHO Reboot Initiated, Rebooting In 10 Seconds.
        TIMEOUT 5 > NUL 2>&1
        shutdown /r /t 10 /soft /c "Hyper-V-Toggle Reboot Procedure"
        ECHO  Rebooting in progress...
        ECHO.
        ECHO  Press Enter To Exit Hyper-V-Toggle.
        ECHO.
        PAUSE
        EXIT /B %ERRORLEVEL%
    )
    ELSE (
        CLS
        ECHO You Chose Not To Reboot Now, Reboot Later To Apply Changes.
        TIMEOUT 5 > NUL 2>&1
        ECHO  Going Back To The Main Menu...
        ECHO.
        ECHO  Press Enter To Go Back To The Main Menu.
        ECHO.
        PAUSE
        GOTO MENU
)

:: End Of File
:EOF
EXIT /B %ERRORLEVEL%
