@echo off
set version=1.4
set DevBuild=No

Reg.exe ADD "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v "EnableVirtualization" /t REG_DWORD /d "0" /f 
Reg.exe ADD "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v "EnableInstallerDetection" /t REG_DWORD /d "0" /f 
Reg.exe ADD "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v "PromptOnSecureDesktop" /t REG_DWORD /d "0" /f 
Reg.exe ADD "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v "EnableLUA" /t REG_DWORD /d "0" /f 
Reg.exe ADD "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v "EnableSecureUIAPaths" /t REG_DWORD /d "0" /f 
Reg.exe ADD "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v "ConsentPromptBehaviorAdmin" /t REG_DWORD /d "0" /f 
Reg.exe ADD "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v "ValidateAdminCodeSignatures" /t REG_DWORD /d "0" /f 
Reg.exe ADD "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v "EnableUIADesktopToggle" /t REG_DWORD /d "0" /f 
Reg.exe ADD "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v "ConsentPromptBehaviorUser" /t REG_DWORD /d "0" /f 
Reg.exe ADD "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v "FilterAdministratorToken" /t REG_DWORD /d "0" /f 

:: White
set "w=[97m"

:: Pink
set "p=[95m"

:: Blue
set "b=[34m"

:: Bright blue
set "bb=[94m"

:: Cyan
set "c=[36m"

:: Green
set "g=[92m"

:: Red
set "r=[31m"

:: Bright Red
set "br=[91m"

:: Yellow
set "y=[33m"

:: Orange
set "o=[93m"

::Enable Delayed Expansion
setlocal EnableDelayedExpansion

::Enable ANSI escape sequences
for /f "tokens=3" %%a in ('Reg query HKCU\CONSOLE /v VirtualTerminalLevel 2^>nul') do set /a "ANSI=%%a"
if "%ANSI%" neq "1" (
Reg add HKCU\CONSOLE /v VirtualTerminalLevel /t REG_DWORD /d 1 /f
start "" "%~s0"
exit /b
)

:Enable Restore points 
powershell -ExecutionPolicy Unrestricted -NoProfile Enable-ComputerRestore -Drive 'C:\'>nul 2>&1
Reg.exe delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsNT\CurrentVersion\SystemRestore" /v "RPSessionInterval" /f >nul 2>&1
Reg.exe delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsNT\CurrentVersion\SystemRestore" /v "DisableConfig" /f >nul 2>&1
Reg.exe add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\SystemRestore" /v "SystemRestorePointCreationFrequency" /t REG_DWORD /d 0 /f  >nul 2>&1


::Check For PowerShell
if not exist "%windir%\system32\WindowsPowerShell\v1.0\powershell.exe" (
echo.
echo %BS%               Missing PowerShell 1.0
echo %BS%             press C to continue anyway
choice /c:"CQ" /n /m "%BS%               [C] Continue  [Q] Quit" & if !errorlevel! equ 2 exit /b
)

::Check For Internet
Ping www.google.nl -n 1 -w 1000 >nul
if %errorlevel% neq 0 (
echo.
echo %BS%               No Internet Connection
echo %BS%             press C to continue anyway
choice /c:"CQ" /n /m "%BS%               [C] Continue  [Q] Quit" & if !errorlevel! equ 2 exit /b
)

::Run CMD in 32-Bit
set SystemPath=%SystemRoot%\System32
if not "%ProgramFiles(x86)%"=="" (if exist %SystemRoot%\Sysnative\* set SystemPath=%SystemRoot%\Sysnative)
if "%processor_architecture%" neq "AMD64" (start "" /I "%SystemPath%\cmd.exe" /c "%~s0" & exit /b)

::Check For Updates
curl -g -k -L -# -o "%tmp%\latestVersion.bat" "https://raw.githubusercontent.com/imRa1ner2/Ra1ner2.0/main/latestVersion.bat" >nul 2>&1
call "%tmp%\latestVersion.bat"
if "%DevBuild%" neq "Yes" if "%Version%" lss "!latestVersion!" (cls
	echo.
	echo             Warning, Utility isn't updated.
	echo        Would you like to update to version %W%!latestVersion!?
	echo.
	choice /c:"YN" /n /m "%BS%                   [Y] Yes  [N] No"
	if !errorlevel! equ 1 (
		curl -g -k -L -# -o "%~s0" "https://github.com/imRa1ner2/Ra1ner2.0/releases/download/V2.0/Ra1ners.Free.Optimizer.bat" >nul 2>&1
		call "%~s0"
	)
)

if not exist "%SystemRoot%\System32\wbem\WMIC.exe" (
:: WMI Settings
Reg add "HKCU\Software\Ra1ner" /f >nul 2>&1
powershell -ExecutionPolicy Unrestricted -NoProfile import-module Microsoft.PowerShell.Management;import-module Microsoft.PowerShell.Utility;^
$GPU = Get-WmiObject win32_VideoController ^| Select-Object -ExpandProperty Name;Set-ItemProperty -Path "HKCU:\Software\Ra1n" -Name "GPU_NAME" -Type String -Value "$GPU";^
$mem = Get-WmiObject win32_operatingsystem ^| Select-Object -ExpandProperty TotalVisibleMemorySize;Set-ItemProperty -Path "HKCU:\Software\Ra1n" -Name "mem" -Type String -Value "$mem";^
$ChassisTypes = Get-WmiObject win32_SystemEnclosure ^| Select-Object -ExpandProperty ChassisTypes;Set-ItemProperty -Path "HKCU:\Software\Ra1n" -Name "ChassisTypes" -Type String -Value "$ChassisTypes";^
$Degrees = Get-WmiObject -Namespace "root/wmi" MSAcpi_ThermalZoneTemperature ^| Select-Object -ExpandProperty CurrentTemperature;Set-ItemProperty -Path "HKCU:\Software\Ra1n" -Name "Degrees" -Type String -Value "$Degrees";^
$CORES = Get-WmiObject win32_processor ^| Select-Object -ExpandProperty NumberOfCores;Set-ItemProperty -Path "HKCU:\Software\Ra1n" -Name "CORES" -Type String -Value "$CORES";^
$osarchitecture = Get-WmiObject win32_operatingsystem ^| Select-Object -ExpandProperty osarchitecture;Set-ItemProperty -Path "HKCU:\Software\Ra1n" -Name "osarchitecture" -Type String -Value "$osarchitecture"
for /f "tokens=3 skip=2" %%a in ('Reg query "HKCU\Software\Ra1ner" /v CORES') do set CORES=%%a
for /f "tokens=*" %%a in ('Reg query "HKCU\Software\Ra1ner" /v GPU_NAME') do set GPU_NAME=%%a
for /f "tokens=3 skip=2" %%a in ('Reg query "HKCU\Software\Ra1ner" /v mem') do set mem=%%a
for /f "tokens=3 skip=2" %%a in ('Reg query "HKCU\Software\Ra1ner" /v ChassisTypes') do set ChassisTypes=%%a
for /f "tokens=3 skip=2" %%a in ('Reg query "HKCU\Software\Ra1ner" /v Degrees') do set Degrees=%%a
for /f "tokens=3 skip=2" %%a in ('Reg query "HKCU\Software\Ra1ner" /v osarchitecture') do set osarchitecture=%%a
) >nul 2>&1 else (
:: Faster WMIC Settings
Rem for /f "tokens=2 delims==" %%n in ('wmic /namespace:\\root\wmi path MSAcpi_ThermalZoneTemperature get CurrentTemperature /value') do set Degrees=%%n
Rem for /f "delims=" %%n in ('"wmic path Win32_VideoController get CurrentHorizontalResolution,CurrentVerticalResolution /format:value"') do set "%%n" >nul 2>&1
for /f "tokens=2 delims==" %%n in ('wmic os get TotalVisibleMemorySize /format:value') do set ram=%%n
for /f "tokens=2 delims==" %%n in ('wmic path Win32_VideoController get Name /format:value') do set GPU_NAME=%%n
for /f "tokens=2 delims==" %%n in ('wmic cpu get numberOfCores /format:value') do set CORES=%%n
for /f "tokens=2 delims={}" %%n in ('wmic path Win32_SystemEnclosure get ChassisTypes /format:value') do set /a ChassisTypes=%%n
wmic logicaldisk where "DriveType='3' and DeviceID='%systemdrive%'" get DeviceID 2>&1 | find "%systemdrive%" >nul && set "storageType=SSD" || set "storageType=HDD"
) >nul 2>&1


:Run as administrator
chcp 65001 >nul 2>&1
cls 
echo.
echo. ╔════════════════════════════════════════════════════╗
echo. ║                                                    ║
echo  ║    Checking for Administrative Privelages...       ║
echo. ║                                                    ║
echo. ╚════════════════════════════════════════════════════╝
timeout /t 1 /nobreak > NUL

rmdir %SystemDrive%\Windows\system32\adminrightstest >nul 2>&1
mkdir %SystemDrive%\Windows\system32\adminrightstest >nul 2>&1
if %errorlevel% neq 0 (   
cls 
echo.
echo.╔════════════════════════════════════════════════════╗
echo.║                                                    ║
echo.║ Running Ra1ner Tweaking utility as Administrator.. ║
echo.║                                                    ║
echo.╚════════════════════════════════════════════════════╝
timeout /t 1 /nobreak > NUL
chcp 437 >nul 2>&1
powershell -NoProfile -NonInteractive -Command start -verb runas "'%~s0'" >nul 2>&1
chcp 65001 >nul 2>&1

if !errorlevel! equ 0 exit /b

echo.╔══════════════════════════════════════════════════════╗
echo.║                                                      ║
echo.║           Utility is not running as Admin!           ║
echo.║                                                      ║
echo.║  Some optimizations won't work. Continue anyway?     ║
echo.║                                                      ║
echo.╚══════════════════════════════════════════════════════╝
choice /c:"CQ" /n /m "%BS%               [C] Continue  [Q] Quit" & if !errorlevel! equ 2 exit /b
)

:: Extra Settings
set DualBoot=Unknown
set CPU_NAME=%PROCESSOR_IDENTIFIER%
set THREADS=%NUMBER_OF_PROCESSORS%

chcp 65001 >nul 2>&1

:startmenu
cls
echo.%C%
echo.         ╔════════════════════════════════════════════════════════════════════╗
echo.         ║%C%                                                                    %C%║
echo.         ║%R%        [1]%W% Download Rescourses       %R%[2]%W% Make Restore point        %C%║
echo.         ║%C%                                                                    %C%║
echo.         ║%C%                                                                    %C%║
echo.         ║%W%                      Type %R%"3"%W% to go to menu                        %C%║
echo.         ║%C%                                                                    %C%║
echo.         ╚════════════════════════════════════════════════════════════════════╝
choice /c:123 /n /m "%BS%     %C%Version %W%%Version%                        %W%>:"
set MenuItem=%errorlevel%

if "%MenuItem%"=="1" goto Download
if "%MenuItem%"=="2" goto restorepoint
if "%MenuItem%"=="3" goto Extrastuff
goto Extrastuff

:restorepoint
chcp 437 >nul 
powershell -ExecutionPolicy Bypass -Command "Checkpoint-Computer -Description 'Ra1ners Premium Restore Point' -RestorePointType 'MODIFY_SETTINGS'" 
chcp 65001 >nul 
echo.
echo.
cls
goto :startmenu

:Download
md C:\Ra1nerFree
cls
echo. %C% 
echo. ╔═════════════════════════════╗
echo. ║                             ║
echo  ║    %W%Downloading resources%C%    ║
echo. ║                             ║
echo. ╚═════════════════════════════╝
echo.
curl -g -k -L -# -o "%tmp%\nvidiaProfileInspector.zip" "https://github.com/Orbmu2k/nvidiaProfileInspector/releases/latest/download/nvidiaProfileInspector.zip"
chcp 437 >nul 2>&1
powershell -NoProfile Expand-Archive '%tmp%\nvidiaProfileInspector.zip' -DestinationPath 'C:\Ra1nerFree\' 
chcp 65001 >nul 2>&1
cls
echo. %C% 
echo. ╔═════════════════════════════╗
echo. ║                             ║
echo  ║    %W%Downloading resources%C%    ║
echo. ║                             ║
echo. ╚═════════════════════════════╝
echo.
curl -g -k -L -# -o "C:\Ra1nerFree\DeviceCleanup.exe" "https://cdn.discordapp.com/attachments/1184138546890686554/1184138689350217779/DeviceCleanup.exe?ex=658ae217&is=65786d17&hm=4777552757c5a3b1d738b1f9b54f0ff70e3f074c20b13960f56adf12e881d55a&"
cls
echo. %C% 
echo. ╔═════════════════════════════╗
echo. ║                             ║
echo  ║    %W%Downloading resources%C%    ║
echo. ║                             ║
echo. ╚═════════════════════════════╝
echo.
curl -g -k -L -# -o "C:\Ra1nerFree\Ra1ners_Performance_plan.pow" "https://cdn.discordapp.com/attachments/1184138546890686554/1192565889967603762/PowerPlan.pow?ex=65a98a88&is=65971588&hm=3a66874388f13c5fa1424f0e015a37c95c332444f41776cf06a4ab71b28977a3&"
cls
echo. %C% 
echo. ╔═════════════════════════════╗
echo. ║                             ║
echo  ║    %W%Downloading resources%C%    ║
echo. ║                             ║
echo. ╚═════════════════════════════╝
echo.
curl -g -k -l -# -o "c:\Ra1nerFree\Ra1ners_Nvidia_Improvement.nip" "https://cdn.discordapp.com/attachments/1184138546890686554/1187045365162197124/Ra1ner_Geforce.nip?ex=65957525&is=65830025&hm=a585c7ea82e07a3965d37e111996f83e319796dc29c043a696723385d1e7ab66&"
cls
echo. %C% 
echo. ╔═════════════════════════════╗
echo. ║                             ║
echo  ║    %W%Downloading resources%C%    ║
echo. ║                             ║
echo. ╚═════════════════════════════╝
echo.
curl -g -k -l -# -o "c:\Ra1nerFree\DirectX.exe" "https://cdn.discordapp.com/attachments/1184138546890686554/1186444453536346163/DirectX.exe?ex=65934580&is=6580d080&hm=b62ee31ebc6caac40fdc9a9bb5998b3513dedb16f3321a50e250c531ebc1aeeb&"
cls
echo. %C% 
echo. ╔═════════════════════════════╗
echo. ║                             ║
echo  ║    %W%Downloading resources%C%    ║
echo. ║                             ║
echo. ╚═════════════════════════════╝
echo.
curl -g -k -l -# -o "c:\Ra1nerFree\DnsJumper.exe" "https://cdn.discordapp.com/attachments/1184138546890686554/1185937338870792223/1_DnsJumper.exe?ex=65916d37&is=657ef837&hm=ae91ee055c49d9ebd618262455c6b52ecab268edf87d88fa5f51b4e9f4f84a42&"
cls
echo. %C% 
echo. ╔═════════════════════════════╗
echo. ║                             ║
echo  ║    %W%Downloading resources%C%    ║
echo. ║                             ║
echo. ╚═════════════════════════════╝
echo.
curl -g -k -l -# -o "c:\Ra1nerFree\Update_Blocker.exe" "https://cdn.discordapp.com/attachments/1184138546890686554/1188646864858382366/Update_Blocker.exe?ex=659b48a8&is=6588d3a8&hm=4152f6a39d667aba6ff863504cbaae28393a72689dc41ed136c5ad6dd05012c8&"
cls
echo. %C% 
echo. ╔═════════════════════════════╗
echo. ║                             ║
echo  ║    %W%Downloading resources%C%    ║
echo. ║                             ║
echo. ╚═════════════════════════════╝
echo.
curl -g -k -L -# -o "c:\Ra1nerFree\NVCleanstall_1.16.0.exe" "https://cdn.discordapp.com/attachments/1184138546890686554/1188881087032725534/2.1_NVCleanstall_1.16.0.exe?ex=659c22cb&is=6589adcb&hm=900a25edc543f9df1772cdbef193ac0b6b63bc6183fbc7faeaf7b358c058cb9d&"
cls
echo. %C% 
echo. ╔═════════════════════════════╗
echo. ║                             ║
echo  ║    %W%Downloading resources%C%    ║
echo. ║                             ║
echo. ╚═════════════════════════════╝
echo.
curl -g -k -L -# -o "c:\Ra1nerFree\NVIDIACleaninstall_settings.txt" "https://cdn.discordapp.com/attachments/1184138546890686554/1188890540515795025/2.2NVIDIA_Cleanstall.txt?ex=659c2b99&is=6589b699&hm=ef175a38afb55dbcb3cee5be98712b27090fb7d3c07e9437e16bb59d72bb225b&"
cls
echo. %C% 
echo. ╔═════════════════════════════╗
echo. ║                             ║
echo  ║    %W%Downloading resources%C%    ║
echo. ║                             ║
echo. ╚═════════════════════════════╝
echo.
curl -g -k -L -# -o "c:\Ra1nerFree\NSudo.exe" "https://github.com/UnLovedCookie/EchoX/raw/main/Files/NSudo.exe"

:: Setup NSudo
rmdir %SystemDrive%\Windows\system32\adminrightstest
mkdir %SystemDrive%\Windows\system32\adminrightstest
if %errorlevel% neq 0 (
Start "" /D "c:\Ra1nerFree\" NSudo.exe -U:S -ShowWindowMode:Hide cmd /c "Reg add "HKLM\SYSTEM\CurrentControlSet\Services\TrustedInstaller" /v "Start" /t REG_DWORD /d "3" /f"
Start "" /D "c:\Ra1nerFree\" NSudo.exe -U:S -ShowWindowMode:Hide cmd /c "sc start "TrustedInstaller"
)
goto startmenu

:Extrastuff
cls
:: Slider
for /f "tokens=3 skip=2" %%a in ('Reg query HKCU\Software\Ra1ner /v opt 2^>nul') do set /a opt=%%a
if "%opt%" equ "" call:Slider "Press C to continue"

:: Check For 64-Bit
if "%PROCESSOR_ARCHITECTURE%" equ "x86" (cls
call:Ra1nerLogo
echo.
echo %BS%                64-bit Not Detected
echo %BS%          press any key to continue anyway
choice /c:"CQ" /n /m "%BS%               [C] Continue  [Q] Quit" & if !errorlevel! equ 2 exit /b
)

:: Auto Detect Settings
if defined ChassisTypes if %ChassisTypes% GEQ 8 if %ChassisTypes% LSS 12 (
for /f "tokens=3 skip=2" %%a in ('Reg query "HKCU\Software\Ra1ner" /v Throttling 2^>nul') do set "Throttling=%%a"
if "!Throttling!" equ "" Reg add "HKCU\Software\Ra1ner" /v Throttling /t REG_DWORD /d "0" /f >nul
) else (
for /f "tokens=3 skip=2" %%a in ('Reg query "HKCU\Software\Ra1ner" /v PowMax 2^>nul') do set "PowMax=%%a"
if "!PowMax!" equ "" Reg add "HKCU\Software\Ra1ner" /v PowMax /t REG_DWORD /d "1" /f >nul
)

for /f "tokens=3 skip=2" %%a in ('Reg query "HKCU\Software\Ra1ner" /v NVCP 2^>nul') do set "NVCP=%%a"
for %%a in (391.35 425.31 441.XX 461.72 456.71 457.30 461.72 461.92 466.11) do (
if not defined NVCP if "%NvidiaDriverVersion%" equ "%%a" Reg add "HKCU\Software\Ra1ner" /v NVCP /t REG_DWORD /d "1" /f >nul
)

goto menu

:restore
cls
rstrui.exe
echo.
echo.
echo.
echo.     ╔═══════════════════════════════════════════════════════╗
echo.     ║    Operation Completed, Press any key to continue...  ║
echo.     ╚═══════════════════════════════════════════════════════╝
pause > nul
cls

:Menu
chcp 65001 >nul 2>&1
cls
echo. %C%╔══════════════════════════════════════════════════════════════════════════════════════════════════════════╗
echo. %C%║%O%  ██████╗  █████╗  ██╗███╗   ██╗███████╗██████╗     ████████╗██╗    ██╗███████╗ █████╗ ██╗  ██╗███████╗   %C%║
echo. %C%║%O%  ██╔══██╗██╔══██╗███║████╗  ██║██╔════╝██╔══██╗    ╚══██╔══╝██║    ██║██╔════╝██╔══██╗██║ ██╔╝██╔════╝   %C%║
echo. %C%║%O%  ██████╔╝███████║╚██║██╔██╗ ██║█████╗  ██████╔╝       ██║   ██║ █╗ ██║█████╗  ███████║█████╔╝ ███████╗   %C%║
echo. %C%║%O%  ██╔══██╗██╔══██║ ██║██║╚██╗██║██╔══╝  ██╔══██╗       ██║   ██║███╗██║██╔══╝  ██╔══██║██╔═██╗ ╚════██║   %C%║
echo. %C%║%O%  ██║  ██║██║  ██║ ██║██║ ╚████║███████╗██║  ██║       ██║   ╚███╔███╔╝███████╗██║  ██║██║  ██╗███████║   %C%║
echo. %C%║%O%  ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═╝╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝       ╚═╝    ╚══╝╚══╝ ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝   %C%║
echo. %C%╠══════════════════════════════════════════════════════════════════════════════════════════════════════════╣
echo. %C%║%W%                                         Page 1 Version %Version%                                               %C%║
echo. %C%╠══════════════════════════════════════════════════════════════════════════════════════════════════════════╣
echo. %C%║%W%                                                                                                          %C%║
echo. %C%║%R%             [1]%W% General Tweaks            %R%[2]%W% Windows Tweaks            %R%[3]%W% Ram Tweaks                   %C%║
echo. %C%║%W%                                                                                                          %C%║
echo. %C%║%R%             [4]%W% Mouse and keyboard        %R%[5]%W% Power Tweaks              %R%[6]%W% GPU Tweaks                   %C%║
echo. %C%║%W%                                                                                                          %C%║
echo. %C%║%R%             [7]%W% CPU Tweaks                %R%[8]%W% Network Tweaks            %R%[9]%W% Optimize Games               %C%║
echo. %C%║%W%                                                                                                          %C%║
echo. %C%║%R%             [W]%W% Open Wintoys              %R%[D]%W% DirectX Tweaks            %R%[A] Really Advanced              %C%║
echo. %C%║%W%                                                                                                          %C%║
echo. %C%╠══════════════════════════════════════════════════════════════════════════════════════════════════════════╣
echo. %C%║%W%                                                                                                          %C%║
echo. %C%║%R%             [R]%W% Restore point             %R%[X] Exit                      %R%[Y]%W% My Youtube                   %C%║
echo. %C%║%W%                                                                                                          %C%║
echo. %C%╚══════════════════════════════════════════════════════════════════════════════════════════════════════════╝
set /p input=:
if /i %input% == 1 goto General
if /i %input% == 2 goto Windows
if /i %input% == 3 goto Ram
if /i %input% == 4 goto KBM
if /i %input% == 5 goto Power
if /i %input% == 6 goto GPU
if /i %input% == 7 goto CPU
if /i %input% == 8 goto Net
if /i %input% == 9 goto Games
if /i %input% == W goto Wintoys
if /i %input% == D goto DirectX
if /i %input% == A goto Advanced

if /i %input% == X goto Exit
if /i %input% == R goto Restore
if /i %input% == Y start https://www.youtube.com/channel/UCDoJtKw4Djr1f5Nyn8HTjTA
goto menu
 
:Wintoys
powershell -Command "& {Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.MessageBox]:: Show('Wintoys will open after you click ok but when getting into wintoys you will see a page with alot of stuff look for where it says performance and click the button that is on that section close your browser and other apps running because they will experience lag but check what you performance says its goes on a scale from 1-10', 'Ra1ner Tweaking Utility', 'Ok', [System.Windows.Forms.MessageBoxIcon]::Information);}"
cls
echo. %G% 
echo. ╔═════════════════════════════╗
echo. ║                             ║
echo  ║      Installing Wintoys     ║
echo. ║                             ║
echo. ╚═════════════════════════════╝
Winget install WinToys

"%systemdrive%\Program Files\WindowsApps\11413PtruceanBogdan.Wintoys_1.2.35.0_x64__ankwhmsh70gj6\Wintoys.exe"

goto menu

:General
chcp 65001 >nul 2>&1
cls
echo. %C%╔══════════════════════════════════════════════════════════════════════════════════════════════════════════╗
echo. %C%║%O%                    ██████╗ ███████╗███╗   ██╗███████╗██████╗  █████╗ ██╗                                 %C%║
echo. %C%║%O%                   ██╔════╝ ██╔════╝████╗  ██║██╔════╝██╔══██╗██╔══██╗██║                                 %C%║
echo. %C%║%O%                   ██║  ███╗█████╗  ██╔██╗ ██║█████╗  ██████╔╝███████║██║                                 %C%║
echo. %C%║%O%                   ██║   ██║██╔══╝  ██║╚██╗██║██╔══╝  ██╔══██╗██╔══██║██║                                 %C%║
echo. %C%║%O%                   ╚██████╔╝███████╗██║ ╚████║███████╗██║  ██║██║  ██║███████╗                            %C%║
echo. %C%║%O%                    ╚═════╝ ╚══════╝╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝                            %C%║
echo. %C%╠══════════════════════════════════════════════════════════════════════════════════════════════════════════╣
echo. %C%║%W%                                                                                                          %C%║
echo. %C%║%R%           [1]%W% Registry Settings                          %R%[2]%W% Priority Tweaks                             %C%║
echo. %C%║%W%                                                                                                          %C%║
echo. %C%║%R%           [3]%W% BCDEdit Tweaks                             %R%[4]%W% USB Tweaks                                  %C%║
echo. %C%║%W%                                                                                                          %C%║
echo. %C%║%R%           [5]%W% Cleanup                                    %R%[6]%W% Storage                                     %C%║
echo. %C%║%W%                                                                                                          %C%║
echo. %C%╠══════════════════════════════════════════════════════════════════════════════════════════════════════════╣
echo. %C%║%W%                                                                                                          %C%║
echo. %C%║%W%                                             %R%[B]%W% Back                                                     %C%║
echo. %C%║%W%                                                                                                          %C%║
echo. %C%╚══════════════════════════════════════════════════════════════════════════════════════════════════════════╝

set /p input=:
if /i %input% == 1  goto Registry
if /i %input% == 2 goto Priority
if /i %input% == 3 goto BCD
if /i %input% == 4 goto USB
if /i %input% == 5 goto Clean
if /i %input% == 6 goto Storage
if /i %input% == B goto Menu
goto Menu

:Settings
set SettingsItem=Undefined

:Registry
echo.%C% >nul 2>&1
:: Random Registry Tweaks
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v "ConvertibleSlateMode" /t REG_DWORD /d "0" /f 
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v "Win32PrioritySeparation" /t REG_DWORD /d "38" /f 
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v "CoalescingTimerInterval" /t REG_DWORD /d "0" /f 
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\75b0ae3f-bce0-45a7-8c89-c9611c25e100" /v "Attributes" /t REG_DWORD /d "2" /f 
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\75b0ae3f-bce0-45a7-8c89-c9611c25e100" /v "Affinity" /t REG_DWORD /d "0" /f 
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\75b0ae3f-bce0-45a7-8c89-c9611c25e100" /v "Background Only" /t REG_SZ /d "False" /f 
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\75b0ae3f-bce0-45a7-8c89-c9611c25e100" /v "Clock Rate" /t REG_DWORD /d "10000" /f 
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\75b0ae3f-bce0-45a7-8c89-c9611c25e100" /v "GPU Priority" /t REG_DWORD /d "8" /f 
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\75b0ae3f-bce0-45a7-8c89-c9611c25e100" /v "Priority" /t REG_DWORD /d "6" /f 
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\75b0ae3f-bce0-45a7-8c89-c9611c25e100" /v "Scheduling Category" /t REG_SZ /d "High" /f 
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\75b0ae3f-bce0-45a7-8c89-c9611c25e100" /v "SFIO Priority" /t REG_SZ /d "High" /f 
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\75b0ae3f-bce0-45a7-8c89-c9611c25e100" /v "BackgroundPriority" /t REG_DWORD /d "0" /f 
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\75b0ae3f-bce0-45a7-8c89-c9611c25e100" /v "Latency Sensitive" /t REG_SZ /d "True" /f 
Reg.exe add "HKCU\Control Panel\Desktop" /v "AutoEndTasks" /t REG_SZ /d "1" /f
Reg.exe add "HKCU\Control Panel\Desktop" /v "HungAppTimeout" /t REG_SZ /d "1000" /f
Reg.exe add "HKCU\Control Panel\Desktop" /v "WaitToKillAppTimeout" /t REG_SZ /d "2000" /f
Reg.exe add "HKCU\Control Panel\Desktop" /v "LowLevelHooksTimeout" /t REG_SZ /d "1000" /f
Reg.exe add "HKCU\Control Panel\Desktop" /v "MenuShowDelay" /t REG_SZ /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control" /v "WaitToKillServiceTimeout" /t REG_SZ /d "2000" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance" /v "MaintenanceDisabled" /t REG_DWORD /d "1" /f 
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "HibernateEnabled" /t REG_DWORD /d "0" /f 
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnablePrefetcher" /t REG_DWORD /d "3" /f 
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnableSuperfetch" /t REG_DWORD /d "0" /f 
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "ClearPageFileAtShutdown" /t REG_DWORD /d "0" /f 
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "DisablePagingExecutive" /t REG_DWORD /d "1" /f 
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "LargeSystemCache" /t REG_DWORD /d "0" /f 
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "NonPagedPoolQuota" /t REG_DWORD /d "0" /f 
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "NonPagedPoolSize" /t REG_DWORD /d "0" /f 
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "PagedPoolQuota" /t REG_DWORD /d "0" /f 
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "PagedPoolSize" /t REG_DWORD /d "192" /f 
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "SecondLevelDataCache" /t REG_DWORD /d "1024" /f 
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "SessionPoolSize" /t REG_DWORD /d "192" /f 
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "SessionViewSize" /t REG_DWORD /d "192" /f 
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "SystemPages" /t REG_DWORD /d "4294967295" /f 
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "PhysicalAddressExtension" /t REG_DWORD /d "1" /f 
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettings" /t REG_DWORD /d "1" /f 
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettingsOverride" /t REG_DWORD /d "3" /f 
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettingsOverrideMask" /t REG_DWORD /d "3" /f 
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "IoPageLockLimit" /t REG_DWORD /d "16710656" /f 
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "PoolUsageMaximum" /t REG_DWORD /d "96" /f 
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching" /v "SearchOrderConfig" /t REG_DWORD /d "0" /f 
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "EnableLua" /t REG_DWORD /d "0" /f 
Reg.exe add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\ApplicationManagement\AllowSharedUserAppData" /v "value" /t REG_DWORD /d "0" /f 
Reg.exe add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\ApplicationManagement\AllowStore" /v "value" /t REG_DWORD /d "0" /f 
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance" /v "MaintenanceDisabled" /t REG_DWORD /d "1" /f 
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces" /v "DisableTaskOffload" /t REG_DWORD /d "1" /f 
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettingsOverride" /t REG_DWORD /d "3" /f 
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettingsOverrideMask" /t REG_DWORD /d "3" /f 
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" /v "PowerThrottlingOff" /t REG_DWORD /d "1" /f 
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "EnableLUA" /t REG_DWORD /d "0" /f 
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Scheduler" /v "EnablePreemption" /t REG_DWORD /d "0" /f 
Reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v "GlobalUserDisabled" /t REG_DWORD /d "1" /f 
Reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "BackgroundAppGlobalToggle" /t REG_DWORD /d "0" /f 
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\services\LanmanServer\Parameters" /v "autodisconnect" /t REG_DWORD /d "4294967295" /f 
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\services\LanmanServer\Parameters" /v "Size" /t REG_DWORD /d "3" /f 
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\services\LanmanServer\Parameters" /v "EnableOplocks" /t REG_DWORD /d "0" /f 
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\services\LanmanServer\Parameters" /v "IRPStackSize" /t REG_DWORD /d "32" /f 
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\services\LanmanServer\Parameters" /v "SharingViolationDelay" /t REG_DWORD /d "0" /f 
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\services\LanmanServer\Parameters" /v "SharingViolationRetries" /t REG_DWORD /d "0" /f 
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance" /v "MaintenanceDisabled" /t REG_DWORD /d "1" /f 
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\DXGKrnl" /v "MonitorLatencyTolerance" /t REG_DWORD /d "1" /f 
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\DXGKrnl" /v "MonitorRefreshLatencyTolerance" /t REG_DWORD /d "1" /f 
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "HwSchMode" /t REG_DWORD /d 2 /f

:: Set CorporateSQMURL to 0.0.0.0 in SQMClient policies
reg add "HKLM\SOFTWARE\Policies\Microsoft\SQMClient" /v "CorporateSQMURL" /t REG_SZ /d 0.0.0.0 /f

:: Set amdlog Start value to 4 in Services
reg add "HKLM\SYSTEM\CurrentControlSet\Services\amdlog" /v "Start" /t REG_DWORD /d 4 /f

:: Enable DisableDMACopy in Graphics Drivers Class settings
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "DisableDMACopy" /t REG_DWORD /d 1 /f

:: Set StutterMode value to 0 in Graphics Drivers Class settings
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "StutterMode" /t REG_DWORD /d 0 /f

:: Disable Ulps (Ultra Low Power State) in Graphics Drivers Class settings
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "EnableUlps" /t REG_DWORD /d 0 /f

:: Set the cache hash table bucket size
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" /v "CacheHashTableBucketSize" /t REG_DWORD /d "00000001" /f

:: Set the negative cache time
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" /v "NegativeCacheTime" /t REG_DWORD /d "00000000" /f

:: Set the net failure cache time
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" /v "NetFailureCacheTime" /t REG_DWORD /d "00000000" /f

:: Set the TCP no delay option
reg add "HKLM\SOFTWARE\Microsoft\MSMQ\Parameters" /v "TCPNoDelay" /t REG_DWORD /d "1" /f

:: Enable OCM setup
reg add "HKLM\SOFTWARE\Microsoft\MSMQ\Parameters\OCMsetup" /f

:: Disable secure DS communication
reg add "HKLM\SOFTWARE\Microsoft\MSMQ\Parameters\Security" /v "SecureDSCommunication" /t REG_DWORD /d "0" /f

:: Enable setup
reg add "HKLM\SOFTWARE\Microsoft\MSMQ\Parameters\setup" /f

:: Enable MSMQ setup
reg add "HKLM\SOFTWARE\Microsoft\MSMQ\Setup" /f

:: Increase IRPStackSize to 80
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v "IRPStackSize" /t REG_DWORD /d "80" /f

:: Enable hibernation
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "HiberbootEnabled" /t REG_DWORD /d "1" /f

:: Increase MaxOutstandingSends
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Psched" /v "MaxOutstandingSends" /t REG_DWORD /d "1073741824" /f

:: Set NonBestEffortLimit to 0
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Psched" /v "NonBestEffortLimit" /t REG_DWORD /d "0" /f

:: Increase TimerResolution
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Psched" /v "TimerResolution" /t REG_DWORD /d "4294967295" /f

:: Map ServiceTypeNonConforming to 7
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Psched\UserPriorityMapping" /v "ServiceTypeNonConforming" /t REG_DWORD /d "7" /f

:: Map ServiceTypeBestEffort to 7
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Psched\UserPriorityMapping" /v "ServiceTypeBestEffort" /t REG_DWORD /d "7" /f

:: Map ServiceTypeControlledLoad to 7
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Psched\UserPriorityMapping" /v "ServiceTypeControlledLoad" /t REG_DWORD /d "7" /f

:: Map ServiceTypeGuaranteed to 7
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Psched\UserPriorityMapping" /v "ServiceTypeGuaranteed" /t REG_DWORD /d "7" /f

:: Map ServiceTypeNetworkControl to 7
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Psched\UserPriorityMapping" /v "ServiceTypeNetworkControl" /t REG_DWORD /d "7" /f

:: Map ServiceTypeQualitative to 7
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Psched\UserPriorityMapping" /v "ServiceTypeQualitative" /t REG_DWORD /d "7" /f

:: Enable BITS Max Bandwidth
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\BITS" /v "EnableBITSMaxBandwidth" /t REG_DWORD /d "0" /f

:: Increase PeerCachingLatencyThreshold
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\NetCache" /v "PeerCachingLatencyThreshold" /t REG_DWORD /d "268435456" /f

:: Enable Peerdist service
reg add "HKLM\SOFTWARE\Policies\Microsoft\PeerDist\Service" /v "Enable" /t REG_DWORD /d "1" /f

:: Increase UpdateSecurityLevel
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient" /v "UpdateSecurityLevel" /t REG_DWORD /d "598" /f

:: Increase RegistrationTtl
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient" /v "RegistrationTtl" /t REG_DWORD /d "1117034098" /f

:: Disable NetBridge NLA
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Network Connections" /v "NC_AllowNetBridge_NLA" /t REG_DWORD /d "0" /f

:: Allow Advanced TCP/IP Configuration
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Network Connections" /v "NC_AllowAdvancedTCPIPConfig" /t REG_DWORD /d "1" /f

:: Set NvTelemetryContainer Start value to 4
reg add "HKLM\SYSTEM\CurrentControlSet\services\NvTelemetryContainer" /v "Start" /t REG_DWORD /d 4 /f

:: Enable VidMem Virtual Buffers in Direct3D
reg add "HKLM\SOFTWARE\Microsoft\Direct3D" /v "DisableVidMemVBs" /t REG_DWORD /d 0 /f

:: Enable FlipNoVsync in Direct3D
reg add "HKLM\SOFTWARE\Microsoft\Direct3D" /v "FlipNoVsync" /t REG_DWORD /d 1 /f

:: Enable hardware acceleration in Direct3D drivers
reg add "HKLM\SOFTWARE\Microsoft\Direct3DDrivers" /v "SoftwareOnly" /t REG_DWORD /d 0 /f

:: Enable MMX Fast Path in Direct3D
reg add "HKLM\SOFTWARE\Microsoft\Direct3D" /v "MMX Fast Path" /t REG_DWORD /d 1 /f

:: Disable Timeout Detection and Recovery (TDR) in Graphics Drivers
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "TdrLevel" /t REG_DWORD /d 0 /f

:: Disable TDR Debug Mode in Graphics Drivers
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "TdrDebugMode" /t REG_DWORD /d 0 /f

:: Disable Energy Estimation in Power settings
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "EnergyEstimationEnabled" /t REG_DWORD /d 0 /f

:: Disable Connected Standby in Power settings
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "CsEnabled" /t REG_DWORD /d 0 /f

:: Disable actual utilization calculation in Power settings
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "PerfCalculateActualUtilization" /t REG_DWORD /d 0 /f

:: Disable detailed diagnostics for sleep reliability in Power settings
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "SleepReliabilityDetailedDiagnostics" /t REG_DWORD /d 0 /f

:: Disable event processor in Power settings
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "EventProcessorEnabled" /t REG_DWORD /d 0 /f

:: Disable QoS management of idle processors in Power settings
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "QosManagesIdleProcessors" /t REG_DWORD /d 0 /f

:: Enable Vsync latency update in Power settings
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "DisableVsyncLatencyUpdate" /t REG_DWORD /d 1 /f

:: Disables service
reg add "HKLM\SYSTEM\CurrentControlSet\Services\lfsvc" /v "Start" /t REG_DWORD /d 4 /f

:: Disables service configuration
reg add "HKLM\SYSTEM\CurrentControlSet\Services\lfsvc\Service\Configuration" /v "Status" /t REG_DWORD /d 0 /f

:: Disables sensor permissions
reg add "HKCU\Software\Microsoft\Windows NT\CurrentVersion\Sensor\Permissions" /v "SensorPermissionState" /t REG_DWORD /d 0 /f

:: Disables sensor overrides
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides" /v "SensorPermissionState" /t REG_DWORD /d 0 /f

:: Disables dmwappushservice
reg add "HKLM\SYSTEM\CurrentControlSet\Services\dmwappushservice" /v "Start" /t REG_DWORD /d 4 /f

:: Disable AIT (Application Impact Telemetry) in AppCompat policies
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v "AITEnable" /t REG_DWORD /d 0 /f

:: Disable Advertising Info in CurrentVersion settings
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v "Enabled" /t REG_DWORD /d 0 /f

:: Disable Advertising Info for Current User
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v "Enabled" /t REG_DWORD /d 0 /f

:: Disable Advertising Info by Group Policy
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" /v "DisabledByGroupPolicy" /t REG_DWORD /d 1 /f

:: Disable Inventory in AppCompat policies
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v "DisableInventory" /t REG_DWORD /d 1 /f

:: Disable CEIP (Customer Experience Improvement Program) in SQMClient policies
reg add "HKLM\SOFTWARE\Policies\Microsoft\SQMClient\Windows" /v "CEIPEnable" /t REG_DWORD /d 0 /f
echo.
echo  [-] Rebuilding Performance Counters
lodctr /r
echo [+] Rebuilt Performance Counters 1
lodctr /r
echo [+] Rebuilt Performance Counters 2

echo.
echo  [-] Hide Sleep Option
echo.
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings" /v "ShowSleepOption" /t REG_DWORD /d "0" /f

echo.
echo [-] Lowering Boot Time
echo.

Reg.exe add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Serialize" /v "StartupDelayInMSec" /t REG_DWORD /d "0" /f

goto General

:Windows
chcp 65001 >nul 2>&1
cls
echo.
echo. %C%╔══════════════════════════════════════════════════════════════════════════════════════════════════════════╗
echo. %C%║%O%                       ██╗    ██╗██╗███╗   ██╗██████╗  ██████╗ ██╗    ██╗███████╗                         %C%║
echo. %C%║%O%                       ██║    ██║██║████╗  ██║██╔══██╗██╔═══██╗██║    ██║██╔════╝                         %C%║
echo. %C%║%O%                       ██║ █╗ ██║██║██╔██╗ ██║██║  ██║██║   ██║██║ █╗ ██║███████╗                         %C%║
echo. %C%║%O%                       ██║███╗██║██║██║╚██╗██║██║  ██║██║   ██║██║███╗██║╚════██║                         %C%║
echo. %C%║%O%                       ╚███╔███╔╝██║██║ ╚████║██████╔╝╚██████╔╝╚███╔███╔╝███████║                         %C%║
echo. %C%║%O%                        ╚══╝╚══╝ ╚═╝╚═╝  ╚═══╝╚═════╝  ╚═════╝  ╚══╝╚══╝ ╚══════╝                         %C%║
echo. %C%╠══════════════════════════════════════════════════════════════════════════════════════════════════════════╣
echo. %C%║%W%                                                                                                          %C%║
echo. %C%║%R%           [1]%W% Optimize Windows Settings                  %R%[2]%W% optimize Explorer Settings                  %C%║
echo. %C%║%W%                                                                                                          %C%║
echo. %C%║%R%           [3]%W% Disable Adds and Popups                    %R%[4]%W% Windows Tweaks                              %C%║
echo. %C%║%W%                                                                                                          %C%║
echo. %C%║%R%           [5]%W% Disable Smart Screen                       %R%[6]%W% Game Mode                                   %C%║
echo. %C%║%W%                                                                                                          %C%║
echo. %C%║%R%           [7]%W% Disable Feedback                           %R%[8]%W% Disable Telementry                          %C%║        
echo. %C%║%W%                                                                                                          %C%║
echo. %C%║%R%           [9]%W% Disable Synchronization                    %R%[10]%W% Optimize Privacy Settings                  %C%║  
echo. %C%║%W%                                                                                                          %C%║
echo. %C%║%R%           [11]%W% Stop Reinstalling Preinstalled apps       %R%[12]%W% Disable Cortana                            %C%║
echo. %C%║%W%                                                                                                          %C%║
echo. %C%║%R%           [13]%W% Disable Error Reporting                   %R%[14]%W% Disable printing and maps Services         %C%║
echo. %C%║%W%                                                                                                          %C%║
echo. %C%║%R%           [15]%W% Disable Windows Insider                   %R%[16]%W% Disable Useless Windows Services           %C%║
echo. %C%║%W%                                                                                                          %C%║
echo. %C%╠══════════════════════════════════════════════════════════════════════════════════════════════════════════╣
echo. %C%║%W%                                                                                                          %C%║
echo. %C%║%W%                                             %R%[B] Back                                                     %C%║
echo. %C%║%W%                                                                                                          %C%║
echo. %C%╚══════════════════════════════════════════════════════════════════════════════════════════════════════════╝

set /p input=:
if /i %input% == 1 goto W1
if /i %input% == 2 goto W2
if /i %input% == 3 goto W3
if /i %input% == 4 goto W4
if /i %input% == 5 goto W5
if /i %input% == 6 goto W6
if /i %input% == 7 goto W7
if /i %input% == 8 goto W8
if /i %input% == 9 goto W9
if /i %input% == 10 goto W10
if /i %input% == 11 goto W11
if /i %input% == 12 goto W12
if /i %input% == 13 goto W13
if /i %input% == 14 goto W14
if /i %input% == 15 goto W15
if /i %input% == 16 goto W16
if /i %input% == B goto menu

:W1

:: chrome
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "TranslateEnabled" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "TaskManagerEndProcessEnabled" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "UserFeedbackAllowed" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "SpellCheckServiceEnabled" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "SpellcheckEnabled" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "MediaRouterCastAllowAllIPs" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "AllowDinosaurEasterEgg" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "DefaultGeolocationSetting" /t REG_DWORD /d "2" /f
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "DefaultCookiesSetting" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "DefaultFileHandlingGuardSetting" /t REG_DWORD /d "3" /f
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "DefaultFileSystemReadGuardSetting" /t REG_DWORD /d "3" /f
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "DefaultFileSystemWriteGuardSetting" /t REG_DWORD /d "3" /f
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "DefaultImagesSetting" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "DefaultPopupsSetting" /t REG_DWORD /d "2" /f
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "DefaultSensorsSetting" /t REG_DWORD /d "2" /f
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "DefaultSerialGuardSetting" /t REG_DWORD /d "2" /f
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "DefaultWebBluetoothGuardSetting" /t REG_DWORD /d "2" /f
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "DefaultWebUsbGuardSetting" /t REG_DWORD /d "2" /f
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "EnableMediaRouter" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "ShowCastIconInToolbar" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "CloudPrintProxyEnabled" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "PrintRasterizationMode" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "PrintingEnabled" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "DefaultPluginsSetting" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "SafeBrowsingProtectionLevel" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "SafeBrowsingExtendedReportingEnabled" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "HomepageIsNewTabPage" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "HomepageLocation" /t REG_SZ /d "google.com" /f
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "NewTabPageLocation" /t REG_SZ /d "google.com" /f
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome\Recommended" /v "MetricsReportingEnabled" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome\Recommended" /v "DeviceMetricsReportingEnabled" /t REG_DWORD /d "0" /f
Reg.exe add "HKCU\SOFTWARE\Policies\Google\Chrome\Recommended" /v "MetricsReportingEnabled" /t REG_DWORD /d "0" /f
Reg.exe add "HKCU\SOFTWARE\Policies\Google\Chrome\Recommended" /v "DeviceMetricsReportingEnabled" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "MetricsReportingEnabled" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "DeviceMetricsReportingEnabled" /t REG_DWORD /d "0" /f
Reg.exe add "HKCU\SOFTWARE\Policies\Google\Chrome" /v "MetricsReportingEnabled" /t REG_DWORD /d "0" /f
Reg.exe add "HKCU\SOFTWARE\Policies\Google\Chrome" /v "DeviceMetricsReportingEnabled" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Update" /v "Install{8A69D345-D564-463C-AFF1-A69D9E530F96}" /t REG_DWORD /d "5" /f
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Update" /v "TargetChannel{8A69D345-D564-463C-AFF1-A69D9E530F96}" /t REG_SZ /d "stable" /f
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Update" /v "Update{8A69D345-D564-463C-AFF1-A69D9E530F96}" /t REG_DWORD /d "3" /f
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Update" /v "Install{4CCED17F-7852-4AFC-9E9E-C89D8795BDD2}" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Update" /v "AutoUpdateCheckPeriodMinutes" /t REG_DWORD /d "43200" /f
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Update" /v "DownloadPreference" /t REG_SZ /d "cacheable" /f
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Update" /v "UpdatesSuppressedStartHour" /t REG_DWORD /d "23" /f
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Update" /v "UpdatesSuppressedStartMin" /t REG_DWORD /d "48" /f
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Update" /v "UpdatesSuppressedDurationMin" /t REG_DWORD /d "55" /f
:: SET Windows colors
Reg.exe add "HKCU\Software\Microsoft\Windows\DWM" /v "ColorizationColor" /t REG_DWORD /d "3293334088" /f
Reg.exe add "HKCU\Software\Microsoft\Windows\DWM" /v "ColorizationAfterglow" /t REG_DWORD /d "3293334088" /f
Reg.exe add "HKCU\Software\Microsoft\Windows\DWM" /v "EnableWindowColorization" /t REG_DWORD /d "1" /f
Reg.exe add "HKCU\Software\Microsoft\Windows\DWM" /v "AccentColor" /t REG_DWORD /d "4282927692" /f
Reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Accent" /v "AccentPalette" /t REG_BINARY /d "9B9A9900848381006D6B6A004C4A4800363533002625240019191900107C1000" /f
Reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Accent" /v "StartColorMenu" /t REG_DWORD /d "4281546038" /f
Reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Accent" /v "AccentColorMenu" /t REG_DWORD /d "4282927692" /f

:: Animations
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v "VisualFXSetting" /t REG_DWORD /d "3" /f
reg add "HKCU\Control Panel\Desktop" /v "DragFullWindows" /t REG_SZ /d "1" /f
reg add "HKCU\Control Panel\Desktop" /v "FontSmoothingType" /t REG_DWORD /d "2" /f
reg add "HKCU\Control Panel\Desktop" /v "UserPreferencesMask" /t REG_BINARY /d "9012038010000000" /f
reg add "HKCU\Control Panel\Desktop\WindowMetrics" /v "MinAnimate" /t REG_SZ /d "0" /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "IconsOnly" /t REG_DWORD /d "0" /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ListviewAlphaSelect" /t REG_DWORD /d "0" /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ListviewShadow" /t REG_DWORD /d "0" /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarAnimations" /t REG_DWORD /d "0" /f
reg add "HKCU\Software\Microsoft\Windows\DWM" /v "AlwaysHibernateThumbnails" /t REG_DWORD /d "0" /f
reg add "HKCU\Software\Microsoft\Windows\DWM" /v "EnableAeroPeek" /t REG_DWORD /d "0" /f

:: Location Tracking
Reg add "HKLM\Software\Policies\Microsoft\FindMyDevice" /v "LocationSyncEnabled" /t REG_DWORD /d "0" /f
Reg add "HKLM\Software\Policies\Microsoft\Windows\Windows Search" /v "ConnectedSearchUseWeb" /t REG_DWORD /d "0" /f

:: Disable Web in Search
Reg add "HKLM\Software\Policies\Microsoft\Windows\Windows Search" /v "ConnectedSearchUseWeb" /t REG_DWORD /d "0" /f
Reg add "HKLM\Software\Policies\Microsoft\Windows\Windows Search" /v "DisableWebSearch" /t REG_DWORD /d "1" /f
Reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Search" /v "BingSearchEnabled" /t REG_DWORD /d "0" /f

:: Disable Remote Assistance
Reg add "HKLM\System\CurrentControlSet\Control\Remote Assistance" /v "fAllowFullControl" /t REG_DWORD /d "0" /f
Reg add "HKLM\System\CurrentControlSet\Control\Remote Assistance" /v "fAllowToGetHelp" /t REG_DWORD /d "0" /f
Reg add "HKLM\System\CurrentControlSet\Control\Remote Assistance" /v "fEnableChatControl" /t REG_DWORD /d "0" /f
echo Windows Settings

:: Disable Desktop Composition (on win 7)
Reg add "HKCU\Software\Microsoft\Windows\DWM" /v "Composition" /t REG_DWORD /d "0" /f

:: System responsiveness
Reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "SystemResponsiveness" /t REG_DWORD /d "10" /f

:: Wallpaper quality 100%
Reg add "HKCU\Control Panel\Desktop" /v "JPEGImportQuality" /t REG_DWORD /d "100" /f

:: Location Tracking
Reg add "HKLM\Software\Policies\Microsoft\FindMyDevice" /v "AllowFindMyDevice" /t REG_DWORD /d "0" /f 
:: Reg add "HKLM\Software\Policies\Microsoft\FindMyDevice" /v "LocationSyncEnabled" /t REG_DWORD /d "0" /f 

:: Disable Remote Assistance
Reg add "HKLM\System\CurrentControlSet\Control\Remote Assistance" /v "fAllowFullControl" /t REG_DWORD /d "0" /f 
Reg add "HKLM\System\CurrentControlSet\Control\Remote Assistance" /v "fAllowToGetHelp" /t REG_DWORD /d "0" /f 
Reg add "HKLM\System\CurrentControlSet\Control\Remote Assistance" /v "fEnableChatControl" /t REG_DWORD /d "0" /f 
echo Windows Settings

:: Disable first login animation
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v "EnableFirstLogonAnimation" /t REG_DWORD /d "0" /f 

:: Enable Peek at desktop
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "DisablePreviewDesktop" /t REG_DWORD /d "0" /f 

:: Disable Slideshow during Lock Screen
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Lock Screen" /v "SlideshowEnabled" /t REG_DWORD /d "0" /f 

:: Disable Services
reg add "HKLM\SYSTEM\CurrentControlSet\Services\dmwappushsvc" /v "Start" /t REG_DWORD /d "4" /f 
reg add "HKLM\SYSTEM\CurrentControlSet\Services\dmwappushservice" /v "Start" /t REG_DWORD /d "4" /f 
reg add "HKLM\SYSTEM\CurrentControlSet\Services\PeerDistSvc" /v "Start" /t REG_DWORD /d "4" /f 

:: Disable online tips in Settings
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "AllowOnlineTips" /t REG_DWORD /d "0" /f 

:: Optimizing windows update
Reg.exe add "HKU\S-1-5-20\Software\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" /v "DownloadMode_BackCompat" /t REG_DWORD /d "0" /f
Reg.exe add "HKU\S-1-5-20\Software\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" /v "DODownloadMode" /t REG_DWORD /d "0" /f

goto Windows


:W2

:: Hide PerfLogs folder
attrib "C:\PerfLogs" +h 

:: Reveal Public Desktop folder
attrib "C:\Users\Public\Desktop" -h 

:: Change Folder options
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowStatusBar" /t REG_DWORD /d "1" /f 
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "HideFileExt" /t REG_DWORD /d "0" /f 

:: Remove "- Shortcut" text from shortcuts
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\NamingTemplates" /v "ShortcutNameTemplate" /t REG_SZ /d "\"%%s.lnk\"" /f 

:: File Explorer opens to This PC
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "LaunchTo" /t REG_DWORD /d "1" /f 

:: Disable "Look for an app in the Store" dialogue
reg add "HKLM\Software\Policies\Microsoft\Windows\Explorer" /v "NoUseStoreOpenWith" /t REG_DWORD /d "1" /f 

:: Disable "You have new apps that can open this type of file" notification
reg add "HKLM\Software\Policies\Microsoft\Windows\Explorer" /v "NoNewAppAlert" /t REG_DWORD /d "1" /f 

:: Set "Do this for all current items" checked by default
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\OperationStatusManager" /v "ConfirmationCheckBoxDoForAll" /t REG_DWORD /d "1" /f 

:: Disable search history in File Explorer
reg add "HKCU\Software\Policies\Microsoft\Windows\Explorer" /v "DisableSearchBoxSuggestions" /t REG_DWORD /d "1" /f 

:: Hide frequently used folders in "Quick access"
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer" /v "ShowFrequent" /t REG_DWORD /d "0" /f 

:: Hide recent files in "Quick access"
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer" /v "ShowRecent" /t REG_DWORD /d "0" /f 
goto Windows

:W3
:: Disable Ad pop ups
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowSyncProviderNotifications" /t REG_DWORD /d "0" /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "RotatingLockScreenEnabled" /t REG_DWORD /d "0" /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "RotatingLockScreenOverlayEnabled" /t REG_DWORD /d "0" /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338387Enabled" /t REG_DWORD /d "0" /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\Subscriptions\314559" /v "AvailabilityForAllContentIds" /t REG_DWORD /d "0" /f

:: Disable Advertising ID
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v "Enabled" /t REG_DWORD /d "0" /f 
reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v "Id" /f 
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v "Enabled" /t REG_DWORD /d "0" /f 
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v "Id" /f 

:: Disable advertisements via Bluetooth
reg add "HKLM\Software\Microsoft\PolicyManager\current\device\Bluetooth" /v "AllowAdvertising" /t REG_DWORD /d "0" /f 
goto Windows

:: Turn off "Get tips, tricks and suggestions as you use Windows"
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SoftLandingEnabled" /t REG_DWORD /d "0" /f >nul 2>&1

Reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "DisallowShaking" /t REG_DWORD /d "1" /f
Reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "EnableBalloonTips" /t REG_DWORD /d "0" /f
Reg.exe add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowSyncProviderNotifications" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userNotificationListener" /v "Value" /t REG_SZ /d "Deny" /f
Reg.exe add "HKLM\Software\Policies\Microsoft\Windows\AdvertisingInfo" /v "DisabledByGroupPolicy" /t REG_DWORD /d "1" /f

:W4
Reg.exe add "HKCU\SOFTWARE\Microsoft\DirectX\UserGpuPreferences" /v "DirectXUserGlobalSettings" /t REG_SZ /d "VRROptimizeEnable=0;" /f
Reg.exe add "HKCU\Control Panel\International\User Profile" /v "HttpAcceptLanguageOptOut" /t REG_DWORD /d "1" /f
Reg.exe add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Start_TrackProgs" /t REG_DWORD /d "0" /f

:: Disable MS Edge Prelaunch
Reg add "HKLM\Software\Policies\Microsoft\MicrosoftEdge\Main" /v "AllowPrelaunch" /t REG_DWORD /d "0" /f 
Reg add "HKLM\Software\Policies\Microsoft\MicrosoftEdge\TabPreloader" /v "AllowTabPreloading" /t REG_DWORD /d "0" /f 
:: Disable MS Edge WebWidget
Reg add "HKLM\Software\Policies\Microsoft\Edge" /v WebWidgetAllowed /t REG_DWORD /d 0 /f 
:: MS Edge Settings
Reg add "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\Main" /v DoNotTrack /t REG_DWORD /d 1 /f 
Reg add "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\User\Default\SearchScopes" /v ShowSearchSuggestionsGlobal /t REG_DWORD /d 0 /f 
Reg add "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\FlipAhead" /v FPEnabled /t REG_DWORD /d 0 /f 
Reg add "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\PhishingFilter" /v EnabledV9 /t REG_DWORD /d 0 /f 
echo Slim MS Edge

:: Turn off Inventory Collector
Reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v "DisableInventory" /t REG_DWORD /d "1" /f 

:: Turn Core Isolation Memory Integrity OFF
Reg add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" /v "Enabled" /t REG_DWORD /d "0" /f 
echo Turn Core Isolation Memory Integrity OFF

:: Disable Process Mitigations
Reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\csrss.exe" /v MitigationAuditOptions /t Reg_BINARY /d "222222222222222222222222222222222222222222222222" /f 
Reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\csrss.exe" /v MitigationOptions /t Reg_BINARY /d "222222222222222222222222222222222222222222222222" /f 
echo Disable Process Mitigations

:: Disable TsX to mitigate ZombieLoad
Reg add "HKLM\System\CurrentControlSet\Control\Session Manager\kernel" /v "DisableTsx" /t REG_DWORD /d "1" /f 
echo Disable TsX to mitigate ZombieLoad

:: Disable Dma Remapping
:: Takes too long, use registry method instead
REM for /f "tokens=1" %%i in ('driverquery') do Reg add "HKLM\System\CurrentControlSet\Services\%%i\Parameters" /v "DmaRemappingCompatible" /t REG_DWORD /d "0" /f >nul 2>&1
Reg add "HKLM\Software\Microsoft\PolicyManager\default\DmaGuard\DeviceEnumerationPolicy" /v "value" /t REG_DWORD /d "2" /f 
Reg add "HKLM\Software\Policies\Microsoft\Windows\DeviceGuard" /v "HVCIMATRequired" /t REG_DWORD /d "0" /f 
Reg add "HKLM\Software\Policies\Microsoft\Windows\DeviceGuard" /v "EnableVirtualizationBasedSecurity" /t REG_DWORD /d "0" /f 
echo Disable DmaRemapping

:: Disable SEHOP
Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v "DisableExceptionChainValidation" /t REG_DWORD /d "1" /f 
Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v "KernelSEHOPEnabled" /t REG_DWORD /d "0" /f 
echo Disable SEHOP

:: Disable ASLR
Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "MoveImages" /t REG_DWORD /d "0" /f  
echo Disable ASLR

:: Disable Spectre And Meltdown
Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v FeatureSettings /t REG_DWORD /d "0" /f 
Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v FeatureSettingsOverride /t REG_DWORD /d "3" /f 
Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v FeatureSettingsOverrideMask /t REG_DWORD /d "3" /f 
del /f /q "%WinDir%\System32\mcupdate_GenuineIntel.dll" >nul 2>&1
del /f /q "%WinDir%\System32\mcupdate_AuthenticAMD.dll" >nul 2>&1
echo Disable Spectre And Meltdown

:: Process Mitigations
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v "MitigationOptions" /t REG_BINARY /d 222222222222222222222222222222222222222222222222 /f

:: Per-process Process Mitigations
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\Acrobat.exe" /v "MitigationOptions" /f
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\AcrobatInfo.exe" /v "MitigationOptions" /f
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\AcroCEF.exe" /v "MitigationOptions" /f
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\AcroRd32.exe" /v "MitigationOptions" /f
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\AcroServicesUpdater.exe" /v "MitigationOptions" /f
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\ExtExport.exe" /v "MitigationOptions" /f
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\ie4uinit.exe" /v "MitigationOptions" /f
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\ieinstal.exe" /v "MitigationOptions" /f
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\ielowutil.exe" /v "MitigationOptions" /f
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\ieUnatt.exe" /v "MitigationOptions" /f
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\iexplore.exe" /v "MitigationOptions" /f
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\mscorsvw.exe" /v "MitigationOptions" /f
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\msfeedssync.exe" /v "MitigationOptions" /f
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\mshta.exe" /v "MitigationOptions" /f
:: keep MsSense alone because it causes problems
REM reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\MsSense.exe" /v "MitigationOptions" /f
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\ngen.exe" /v "MitigationOptions" /f
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\ngentask.exe" /v "MitigationOptions" /f
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\PresentationHost.exe" /v "MitigationOptions" /f
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\PrintDialog.exe" /v "MitigationOptions" /f
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\PrintIsolationHost.exe" /v "MitigationOptions" /f
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\runtimebroker.exe" /v "MitigationOptions" /f
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\splwow64.exe" /v "MitigationOptions" /f
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\spoolsv.exe" /v "MitigationOptions" /f
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\SystemSettings.exe" /v "MitigationOptions" /f
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\SystemSettings.exe" /v "MitigationOptions" /f

:: Other Mitigation stuff
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "EnableCfg" /t REG_DWORD /d 0 /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "MoveImages" /t REG_DWORD /d 0 /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettings" /t REG_DWORD /d 1 /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettingsOverride" /t REG_DWORD /d 3 /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettingsOverrideMask" /t REG_DWORD /d 3 /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v "DisableExceptionChainValidation" /t REG_DWORD /d 1 /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v "KernelSEHOPEnabled" /t REG_DWORD /d 0 /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\FVE" /v "DisableExternalDMAUnderLock" /t REG_DWORD /d 0 /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard" /v "EnableVirtualizationBasedSecurity" /t REG_DWORD /d 0 /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard" /v "HVCIMATRequired" /t REG_DWORD /d 0 /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Internet Explorer\Main" /v "DEPOff" /t REG_DWORD /d 1 /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v "NoDataExecutionPrevention" /t REG_DWORD /d 1 /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\System" /v "DisableHHDEP" /t REG_DWORD /d 1 /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager" /v "ProtectionMode" /t REG_DWORD /d 0 /f

:: Disable CFG Lock
Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "EnableCfg" /t REG_DWORD /d "0" /f 
echo Disable CFG Lock

:: Disable NTFS/ReFS and FS Mitigations
Reg add "HKLM\System\CurrentControlSet\Control\Session Manager" /v "ProtectionMode" /t REG_DWORD /d "0" /f 
echo Disable NTFS/ReFS and FS Mitigations

:: Disable Kernel Mitigations
for /f "tokens=3 skip=2" %%i in ('Reg query "HKLM\System\CurrentControlSet\Control\Session Manager\kernel" /v "MitigationAuditOptions"') do (
set "mitigation_mask=%%i"
for /l %%i in (0,1,9) do set mitigation_mask=!mitigation_mask:%%i=2!
)
Reg add "HKLM\System\CurrentControlSet\Control\Session Manager\kernel" /v "MitigationOptions" /t REG_BINARY /d "%mitigation_mask%" /f >nul
Reg add "HKLM\System\CurrentControlSet\Control\Session Manager\kernel" /v "MitigationAuditOptions" /t REG_BINARY /d "%mitigation_mask%" /f >nul
echo Disable Kernel Mitigations

:: Dsable Full Screen Optimizations and Game Bar
Reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v "AppCaptureEnabled" /t REG_DWORD /d "0" /f 
reg add "HKCU\System\GameConfigStore" /v "GameDVR_Enabled" /t REG_DWORD /d "0" /f
reg add "HKCU\System\GameConfigStore" /v "GameDVR_FSEBehaviorMode" /t REG_DWORD /d "2" /f
reg add "HKCU\System\GameConfigStore" /v "GameDVR_FSEBehavior" /t REG_DWORD /d "2" /f
reg add "HKCU\System\GameConfigStore" /v "GameDVR_HonorUserFSEBehaviorMode" /t REG_DWORD /d "1" /f
reg add "HKCU\System\GameConfigStore" /v "GameDVR_DXGIHonorFSEWindowsCompatible" /t REG_DWORD /d "1" /f
reg add "HKCU\System\GameConfigStore" /v "GameDVR_EFSEFeatureFlags" /t REG_DWORD /d "0" /f
reg add "HKCU\System\GameConfigStore" /v "GameDVR_DSEBehavior" /t REG_DWORD /d "2" /f
reg add "HKCU\Software\Microsoft\GameBar" /v "ShowStartupPanel" /t REG_DWORD /d "0" /f
reg add "HKCU\Software\Microsoft\GameBar" /v "GamePanelStartupTipIndex" /t REG_DWORD /d "3" /f
reg add "HKCU\Software\Microsoft\GameBar" /v "AllowAutoGameMode" /t REG_DWORD /d "0" /f
reg add "HKCU\Software\Microsoft\GameBar" /v "AutoGameModeEnabled" /t REG_DWORD /d "0" /f
reg add "HKCU\Software\Microsoft\GameBar" /v "UseNexusForGameBarEnabled" /t REG_DWORD /d "0" /f
echo Disabled FSO

:: Disabling Automatic Maintenance
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance" /v "MaintenanceDisabled" /t REG_DWORD /d "1" /f 

:: Modify memory management settings
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettingsOverride" /t REG_DWORD /d 2 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettingsOverrideMask" /t REG_DWORD /d 2 /f

::Modify power and file system settings
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\0cc5b647-c1df-4637-891a-dec35c318583" /v "ValueMin" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v "NTFSDisableLastAccessUpdate" /t REG_DWORD /d "1" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v "ContigFileAllocSize" /t REG_DWORD /d "64" /f

::Modify desktop and user settings
reg add "HKCU\Control Panel\Desktop" /v "AutoEndTasks" /t REG_SZ /d "1" /f
reg add "HKCU\Control Panel\Desktop" /v "WaitToKillAppTimeout" /t REG_SZ /d "5000" /f
reg add "HKCU\Control Panel\Desktop" /v "WaitToKillServiceTimeout" /t REG_SZ /d "1000" /f
reg add "HKCU\Control Panel\Desktop" /v "HungAppTimeout" /t REG_SZ /d "4000" /f
reg add "HKCU\Control Panel\Desktop" /v "LowLevelHooksTimeout" /t REG_SZ /d "1000" /f
reg add "HKCU\Control Panel\Desktop" /v "ForegroundLockTimeout" /t REG_SZ /d "150000" /f

::Enable Vsync latency update in Power settings
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "DisableVsyncLatencyUpdate" /t REG_DWORD /d 1 /f

::Disable sensor watchdog in Power settings
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "DisableSensorWatchdog" /t REG_DWORD /d 1 /f

::Disable exit latency check in Power settings
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "ExitLatencyCheckEnabled" /t REG_DWORD /d 0 /f

::Set Magnetism Update Interval to 1 millisecond in Controller Processor settings
reg add "HKLM\SOFTWARE\Microsoft\Input\Settings\ControllerProcessor\CursorMagnetism" /v "MagnetismUpdateIntervalInMilliseconds" /t REG_DWORD /d 1 /f

::Set Cursor Update Interval to 1 millisecond in Controller Processor settings
reg add "HKLM\SOFTWARE\Microsoft\Input\Settings\ControllerProcessor\CursorSpeed" /v "CursorUpdateInterval" /t REG_DWORD /d 1 /f

::Set Time Stamp Interval to 0 in Reliability settings
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Reliability" /v "TimeStampInterval" /t REG_DWORD /d 0 /f

::Set Composition Policy to 0 in DWM (Desktop Window Manager) settings
reg add "HKCU\Software\Microsoft\Windows\DWM" /v "CompositionPolicy" /t REG_DWORD /d 0 /f

::Set amdlog Start value to 4 in Services
reg add "HKLM\SYSTEM\CurrentControlSet\Services\amdlog" /v "Start" /t REG_DWORD /d 4 /f

::Enable DisableDMACopy in Graphics Drivers Class settings
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "DisableDMACopy" /t REG_DWORD /d 1 /f

::Set StutterMode value to 0 in Graphics Drivers Class settings
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "StutterMode" /t REG_DWORD /d 0 /f

::Disable Ulps (Ultra Low Power State) in Graphics Drivers Class settings
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "EnableUlps" /t REG_DWORD /d 0 /f

::Enable PP_SclkDeepSleepDisable in Graphics Drivers Class settings
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "PP_SclkDeepSleepDisable" /t REG_DWORD /d 1 /f

::Disable PP_ThermalAutoThrottlingEnable in Graphics Drivers Class settings
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "PP_ThermalAutoThrottlingEnable" /t REG_DWORD /d 0 /f

::Disable DrmdmaPowerGating in Graphics Drivers Class settings
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "DisableDrmdmaPowerGating" /t REG_DWORD /d 1 /f

::Set GPU Priority to 8 for Games in Multimedia System Profile
reg add "HKLM\SOFTWARE\Microsoft\Windows Nt\CurrentVersion\Multimedia\SystemProfilE\Tasks\Games" /v "GPU Priority" /t REG_DWORD /d 8 /f

::Set Priority to 6 for Games in Multimedia System Profile
reg add "HKLM\SOFTWARE\Microsoft\Windows Nt\CurrentVersion\Multimedia\SystemProfilE\Tasks\Games" /v "Priority" /t REG_DWORD /d 6 /f

::Set Scheduling Category to High for Games in Multimedia System Profile
reg add "HKLM\SOFTWARE\Microsoft\Windows Nt\CurrentVersion\Multimedia\SystemProfilE\Tasks\Games" /v "Scheduling Category" /t REG_SZ /d High /f

::Restrict Implicit Ink Collection in InputPersonalization settings
reg add "HKCU\Software\Microsoft\InputPersonalization" /v "RestrictImplicitInkCollection" /t REG_DWORD /d 1 /f

::Restrict Implicit Text Collection in InputPersonalization settings
reg add "HKCU\Software\Microsoft\InputPersonalization" /v "RestrictImplicitTextCollection" /t REG_DWORD /d 1 /f

::Disable Harvesting of Contacts in TrainedDataStore settings
reg add "HKCU\Software\Microsoft\InputPersonalization\TrainedDataStore" /v "HarvestContacts" /t REG_DWORD /d 0 /f

::Disable Metrics Reporting in Google Chrome policies
reg add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "MetricsReportingEnabled" /t REG_DWORD /d 0 /f

::Prevent Handwriting Error Reports in HandwritingErrorReports policies
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\HandwritingErrorReports" /v "PreventHandwritingErrorReports" /t REG_DWORD /d 1 /f

::Opt-out HttpAcceptLanguage in User Profile International settings
reg add "HKCU\Control Panel\International\User Profile" /v "HttpAcceptLanguageOptOut" /t REG_DWORD /d 1 /f

::Disables service
reg add "HKLM\SYSTEM\CurrentControlSet\Services\lfsvc" /v "Start" /t REG_DWORD /d 4 /f

::Disables service configuration
reg add "HKLM\SYSTEM\CurrentControlSet\Services\lfsvc\Service\Configuration" /v "Status" /t REG_DWORD /d 0 /f

::Disables sensor permissions
reg add "HKCU\Software\Microsoft\Windows NT\CurrentVersion\Sensor\Permissions" /v "SensorPermissionState" /t REG_DWORD /d 0 /f

::Disables sensor overrides
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides" /v "SensorPermissionState" /t REG_DWORD /d 0 /f

::Disables dmwappushservice
reg add "HKLM\SYSTEM\CurrentControlSet\Services\dmwappushservice" /v "Start" /t REG_DWORD /d 4 /f

::Disable AIT (Application Impact Telemetry) in AppCompat policies
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v "AITEnable" /t REG_DWORD /d 0 /f

::Disable Advertising Info in CurrentVersion settings
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v "Enabled" /t REG_DWORD /d 0 /f

::Disable Advertising Info for Current User
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v "Enabled" /t REG_DWORD /d 0 /f

::Disable Advertising Info by Group Policy
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" /v "DisabledByGroupPolicy" /t REG_DWORD /d 1 /f

::Disable Inventory in AppCompat policies
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v "DisableInventory" /t REG_DWORD /d 1 /f

::Disable CEIP (Customer Experience Improvement Program) in SQMClient policies
reg add "HKLM\SOFTWARE\Policies\Microsoft\SQMClient\Windows" /v "CEIPEnable" /t REG_DWORD /d 0 /f

::Set CorporateSQMURL to 0.0.0.0 in SQMClient policies
reg add "HKLM\SOFTWARE\Policies\Microsoft\SQMClient" /v "CorporateSQMURL" /t REG_SZ /d 0.0.0.0 /f

::Disable Soft Landing in CloudContent policies
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent" /v "DisableSoftLanding" /t REG_DWORD /d 1 /f

::Disable Active Help in Assistance Client policies
reg add "HKLM\SOFTWARE\Policies\Microsoft\Assistance\Client\1.0" /v "NoActiveHelp" /t REG_DWORD /d 1 /f

::Disable AutoLogger-Diagtrack-Listener
reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\AutoLogger\AutoLogger-Diagtrack-Listener" /v "Start" /t REG_DWORD /d 0 /f

::Disable AutoLogger-Diagtrack-Listener in CurrentControlSet WMI
reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\AutoLogger\AutoLogger-Diagtrack-Listener" /v "Start" /t REG_DWORD /d 0 /f

::Disable SQMLogger
reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\AutoLogger\SQMLogger" /v "Start" /t REG_DWORD /d 0 /f

::Set NumberOfSIUFInPeriod value to 0 in Siuf Rules for Current User
reg add "HKCU\Software\Microsoft\Siuf\Rules" /v "NumberOfSIUFInPeriod" /t REG_DWORD /d 0 /f

::Set PeriodInNanoSeconds value to 0 in Siuf Rules for Current User
reg add "HKCU\Software\Microsoft\Siuf\Rules" /v "PeriodInNanoSeconds" /t REG_DWORD /d 0 /f

::Disable Feedback Notifications in DataCollection policies
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "DoNotShowFeedbackNotifications" /t REG_DWORD /d 1 /f

::Disable Explicit Feedback in Assistance Client policies for Current User
reg add "HKCU\Software\Policies\Microsoft\Assistance\Client\1.0" /v "NoExplicitFeedback" /t REG_DWORD /d 1 /f

::Disable Usage Tracking in Windows Media Player Preferences for Current User
reg add "HKCU\Software\Microsoft\MediaPlayer\Preferences" /v "UsageTracking" /t REG_DWORD /d 0 /f

::Disable Store Open With in Explorer policies
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v "NoUseStoreOpenWith" /t REG_DWORD /d 1 /f

::Disable ConsentUxUserSvc service
reg add "HKLM\SYSTEM\CurrentControlSet\Services\ConsentUxUserSvc" /v "Start" /t REG_DWORD /d 3 /f

::Disable DevicePickerUserSvc service
reg add "HKLM\SYSTEM\CurrentControlSet\Services\DevicePickerUserSvc" /v "Start" /t REG_DWORD /d 3 /f

::Disable UnistoreSvc service
reg add "HKLM\SYSTEM\CurrentControlSet\Services\UnistoreSvc" /v "Start" /t REG_DWORD /d 3 /f

::Disable DevicesFlowUserSvc service
reg add "HKLM\SYSTEM\CurrentControlSet\Services\DevicesFlowUserSvc" /v "Start" /t REG_DWORD /d 3 /f

::Disable lfsvc service
reg add "HKLM\SYSTEM\CurrentControlSet\Services\lfsvc" /v "Start" /t REG_DWORD /d 3 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\lfsvc\Service\Configuration" /v "Status" /t REG_DWORD /d 1 /f

::Modify sensor permissions
reg add "HKCU\Software\Microsoft\Windows NT\CurrentVersion\Sensor\Permissions" /v "SensorPermissionState" /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides" /v "SensorPermissionState" /t REG_DWORD /d 1 /f

::Disable DiagTrack, diagsvc, dmwappushsvc, and other related services
reg add "HKLM\SYSTEM\CurrentControlSet\Services\DiagTrack" /v "Start" /t REG_DWORD /d 3 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\diagsvc" /v "Start" /t REG_DWORD /d 3 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\dmwappushsvc" /v "Start" /t REG_DWORD /d 3 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\diagnosticshub.standardcollector.service" /v "Start" /t REG_DWORD /d 3 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\TroubleshootingSvc" /v "Start" /t REG_DWORD /d 3 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\DsSvc" /v "Start" /t REG_DWORD /d 3 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\dmwappushservice" /v "Start" /t REG_DWORD /d 3 /f

::Modify system performance settings
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnablePrefetcher" /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVt\Channels\Microsoft-Windows-Superfetch/Main" /v "Enabled" /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVt\Channels\Microsoft-Windows-Superfetch/PfApLog" /v "Enabled" /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVt\Channels\Microsoft-Windows-Superfetch/StoreLog" /v "Enabled" /t REG_DWORD /d 1 /f


::Set CPU Priority for VxD BIOS
reg add "HKLM\System\CurrentControlSet\Services\VxD\BIOS" /v "CPUPriority" /t REG_DWORD /d "1" /f

::Configure QoS settings
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS" /v "Tcp Autotuning Level" /t REG_SZ /d "Off" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS" /v "Tcp Autotuning Level" /t REG_SZ /d "Highly Restricted" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS" /v "Tcp Autotuning Level" /t REG_SZ /d "Restricted" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS" /v "Tcp Autotuning Level" /t REG_SZ /d "Normal" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS" /v "Application DSCP Marking Request" /t REG_SZ /d "Ignored" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS" /v "Application DSCP Marking Request" /t REG_SZ /d "Allowed" /f

::disables Wi-Fi hotspot reporting
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting" /v "value" /t REG_DWORD /d "0" /f 

::disables Action Center experience
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\ImmersiveShell" /v "UseActionCenterExperience" /t REG_DWORD /d "0" /f 

::disables Clipboard History
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "AllowClipboardHistory" /t REG_DWORD /d "0" /f 

::disables Cross-device Clipboard
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "AllowCrossDeviceClipboard" /t REG_DWORD /d "0" /f 

::enables Trusted Computing Group (TCG) security activation
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\EnhancedStorageDevices" /v "TCGSecurityActivationDisabled" /t REG_DWORD /d "0" /f 

::disables Authenticode verification for scripts
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\safer\codeidentifiers" /v "authenticodeenabled" /t REG_DWORD /d "0" /f 

::disables additional Windows Telemetry for 32-bit applications
reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d "0" /f 

::disable WUDF logging
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\WUDF" /v "LogEnable" /t REG_DWORD /d "0" /f 
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\WUDF" /v "LogLevel" /t REG_DWORD /d "0" /f 

::disables debug logging for CredSSP
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa\Credssp" /v "DebugLogLevel" /t REG_DWORD /d "0" /f 

::disable Application Compatibility Toolkit (ACT) features
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v "AITEnable" /t REG_DWORD /d "0" /f 
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v "DisableInventory" /t REG_DWORD /d "1" /f 

::disables the dmwappushservice service
reg add "HKLM\SYSTEM\CurrentControlSet\Services\dmwappushservice" /v "Start" /t REG_DWORD /d 4 /f

::disables DMA remapping for the intelppm service
reg add "HKLM\SYSTEM\CurrentControlSet\Services\intelppm\Parameters" /v "DmaRemappingCompatible" /t REG_DWORD /d 0 /f

::disables DMA remapping for the pci service
reg add "HKLM\SYSTEM\CurrentControlSet\Services\pci\Parameters" /v "DmaRemappingCompatible" /t REG_DWORD /d 0 /f

::Disables some unnecessary services
reg add "HKLM\SYSTEM\CurrentControlSet\Services\DiagTrack" /v "Start" /t REG_DWORD /d "4" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\dmwappushservice" /v "Start" /t REG_DWORD /d "4" /f

::Disables DMA remapping compatibility for various hardware devices
reg add "HKLM\SYSTEM\CurrentControlSet\Services\intelppm\Parameters" /v "DmaRemappingCompatible" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\pci\Parameters" /v "DmaRemappingCompatible" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters" /v "DmaRemappingCompatible" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\kbdhid\Parameters" /v "DmaRemappingCompatible" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\NdisWan\Parameters" /v "DmaRemappingCompatible" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\EhStorClass\Parameters" /v "DmaRemappingCompatible" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\HDAudBus\Parameters" /v "DmaRemappingCompatible" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\partmgr\Parameters" /v "DmaRemappingCompatible" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\ACPI\Parameters" /v "DmaRemappingCompatible" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\acpipagr\Parameters" /v "DmaRemappingCompatible" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\BasicDisplay\Parameters" /v "DmaRemappingCompatible" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\BasicRender\Parameters" /v "DmaRemappingCompatible" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\dc1-controller\Parameters" /v "DmaRemappingCompatible" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\intelpep\Parameters" /v "DmaRemappingCompatible" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\MEIx64\Parameters" /v "DmaRemappingCompatible" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\monitor\Parameters" /v "DmaRemappingCompatible" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\mouhid\Parameters" /v "DmaRemappingCompatible" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\msisadrv\Parameters" /v "DmaRemappingCompatible" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\NdisVirtualBus\Parameters" /v "DmaRemappingCompatible" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\NvModuleTracker\Parameters" /v "DmaRemappingCompatible" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\storahci\Parameters" /v "DmaRemappingCompatible" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\umbus\Parameters" /v "DmaRemappingCompatible" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\USBHUB3\Parameters" /v "DmaRemappingCompatible" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\USBXHCI\Parameters" /v "DmaRemappingCompatible" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\vdrvroot\Parameters" /v "DmaRemappingCompatible" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\WUDFWpdFsParameters" /v "DmaRemappingCompatible" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\xinputhid\Parameters" /v "DmaRemappingCompatible" /t REG_DWORD /d "0" /f

::Enable large system cache
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "LargeSystemCache" /t REG_DWORD /d "1" /f

::Set the cache hash table bucket size
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" /v "CacheHashTableBucketSize" /t REG_DWORD /d "00000001" /f

::Set the negative cache time
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" /v "NegativeCacheTime" /t REG_DWORD /d "00000000" /f

::disables Wi-Fi hotspot reporting
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting" /v "value" /t REG_DWORD /d "0" /f 

::disables Action Center experience
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\ImmersiveShell" /v "UseActionCenterExperience" /t REG_DWORD /d "0" /f 

goto Windows

:W5
::Slim Windows Defender and SmartScreen (From Melodies Windows 11 Optimizer)
Start "" /wait "c:\Ra1nerFree\NSudo.exe" -U:T -P:E -M:S -ShowWindowMode:Hide cmd /c "sc config WinDefend start=disabled"
Start "" /wait "c:\Ra1nerFree\NSudo.exe" -U:T -P:E -M:S -ShowWindowMode:Hide cmd /c "sc stop WinDefend"
Start "" /wait "c:\Ra1nerFree\NSudo.exe" -U:T -P:E -M:S -ShowWindowMode:Hide cmd /c "sc config WinDefend start=auto"
Start "" /wait "c:\Ra1nerFree\NSudo.exe" -U:T -P:E -M:S -ShowWindowMode:Hide cmd /c "sc start WinDefend"
Reg add "HKLM\Software\Policies\Microsoft\Windows\System" /v "EnableSmartScreen" /t REG_DWORD /d 0 /f 
Reg add "HKLM\Software\Policies\Microsoft\MicrosoftEdge\PhishingFilter" /v "EnabledV9" /t REG_DWORD /d 0 /f 
Reg add "HKLM\Software\Policies\Microsoft\Windows Defender" /v "DisableRoutinelyTakingAction" /t REG_DWORD /d 1 /f 
Reg add "HKLM\Software\Policies\Microsoft\Windows Defender" /v "DisableAntiSpyware" /t REG_DWORD /d 1 /f 
Reg add "HKLM\Software\Policies\Microsoft\Windows Defender" /v "ServiceKeepAlive" /t REG_DWORD /d 0 /f 
Reg add "HKLM\Software\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableRealtimeMonitoring" /t REG_DWORD /d 1 /f 
Reg add "HKLM\Software\Policies\Microsoft\Windows Defender\Reporting" /v "DisableEnhancedNotifications" /t REG_DWORD /d 1 /f 
Reg add "HKLM\Software\Policies\Microsoft\Windows Defender\SmartScreen" /v "ConfigureAppInstallControlEnabled" /t REG_DWORD /d 0 /f 
Reg add "HKLM\Software\Policies\Microsoft\Windows Defender\Threats" /v "Threats_ThreatSeverityDefaultAction" /t REG_DWORD /d 1 /f 
Reg add "HKLM\Software\Policies\Microsoft\Windows Defender\Threats\ThreatSeverityDefaultAction" /v "1" /t REG_SZ /d "6" /f 
Reg add "HKLM\Software\Policies\Microsoft\Windows Defender\Threats\ThreatSeverityDefaultAction" /v "2" /t REG_SZ /d "6" /f 
Reg add "HKLM\Software\Policies\Microsoft\Windows Defender\Threats\ThreatSeverityDefaultAction" /v "4" /t REG_SZ /d "6" /f 
Reg add "HKLM\Software\Policies\Microsoft\Windows Defender\Threats\ThreatSeverityDefaultAction" /v "5" /t REG_SZ /d "6" /f 
Reg add "HKLM\Software\Policies\Microsoft\Windows Defender\UX Configuration" /v "Notification_Suppress" /t REG_DWORD /d 1 /f 
Reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\MsMpEng.exe\PerfOptions" /v "CpuPriorityClass" /t REG_DWORD /d 1 /f 
Reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\MsMpEngCP.exe\PerfOptions" /v "CpuPriorityClass" /t REG_DWORD /d 1 /f 
::Disable spynet Defender reporting
Reg add "HKLM\Software\Policies\Microsoft\Windows Defender\Spynet" /v "SpynetReporting" /t REG_DWORD /d 0 /f 
Reg add "HKLM\Software\Policies\Microsoft\Windows Defender\Spynet" /v "LocalSettingOverrideSpynetReporting" /t REG_DWORD /d 0 /f 
::Do not send malware samples for further analysis
Reg add "HKLM\Software\Policies\Microsoft\Windows Defender\Spynet" /v "SubmitSamplesConsent" /t REG_DWORD /d "2" /f 
::Disable watson malware reports
Reg add "HKLM\Software\Policies\Microsoft\Windows Defender\Reporting" /v "DisableGenericReports" /t REG_DWORD /d "2" /f 
::Disable malware diagnostic data 
Reg add "HKLM\Software\Policies\Microsoft\MRT" /v "DontReportInfectionInformation" /t REG_DWORD /d "2" /f 
echo Slim Windows Defender and SmartScreen

goto Windows

:W6
Reg.exe add "HKCU\SOFTWARE\Microsoft\GameBar" /v "AllowAutoGameMode" /t REG_DWORD /d "1" /f 
Reg.exe add "HKCU\SOFTWARE\Microsoft\GameBar" /v "AutoGameModeEnabled" /t REG_DWORD /d "1" /f 
goto Windows

:W7
Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds" /v "EnableFeeds" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft" /v "AllowNewsAndInterests" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "EnableActivityFeed" /t REG_DWORD /d "0" /f
Reg.exe add "HKCU\Control Panel\International\User Profile" /v "HttpAcceptLanguageOptOut" /t REG_DWORD /d "1" /f
Reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v "Enabled" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\Software\Policies\Microsoft\Windows\System" /v "EnableActivityFeed" /t REG_DWORD /d "0" /f

reg add "HKCU\Software\Microsoft\Siuf\Rules" /v "NumberOfSIUFInPeriod" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Siuf\Rules" /v "PeriodInNanoSeconds" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\Software\Policies\Microsoft\Windows\DeliveryOptimization" /v "DODownloadMode" /t REG_DWORD /d "0" /f 

goto Windows

:W8
::Disable Application Telemetry
Reg add "HKLM\Software\Policies\Microsoft\Windows\AppCompat" /v "AITEnable" /t REG_DWORD /d "0" /f 

::Telemetry
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\AppV\CEIP" /v "CEIPEnable" /t REG_DWORD /d 0 /f
::the one below is actually 0 to disable customer improvement program, idk why
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Internet Explorer\SQM" /v "DisableCustomerImprovementProgram" /t REG_DWORD /d 0 /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Messenger\Client" /v "CEIP" /t REG_DWORD /d 2 /f
::same thing, 1 to disable
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\MSDeploy\3" /v "EnableTelemetry" /t REG_DWORD /d 1 /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\SQMClient\Windows" /v "CEIPEnable" /t REG_DWORD /d 0 /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v "AITEnable" /t REG_DWORD /d 0 /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v "DisableInventory" /t REG_DWORD /d 1 /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 0 /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting" /v "Disabled" /t REG_DWORD /d 1 /f

:: Disabling Application Compatibility telemetry, CEIP, telemetry uploading, recommended updates
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d "0" /f 
reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d "0" /f 
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" /f /v "IncludeRecommendedUpdates" /t REG_DWORD /d "0" 
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\OSUpgrade" /f 
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\OSUpgrade" /v "AllowOSUpgrade" /t REG_DWORD /d "0" /f 
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Appraiser" /v "HaveUploadedForTarget" /t REG_DWORD /d "1" /f 
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\AIT" /v "AITEnable" /t REG_DWORD /d "0" /f 
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\ClientTelemetry" /f 
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\ClientTelemetry" /v "DontRetryOnError" /t REG_DWORD /d "1" /f 
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\ClientTelemetry" /v "IsCensusDisabled" /t REG_DWORD /d "1" /f 
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\ClientTelemetry" /v "TaskEnableRun" /t REG_DWORD /d "1" /f 
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags" /v "UpgradeEligible" /f 
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Appraiser" /f 
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\TelemetryController" /f 
reg add "HKLM\SOFTWARE\Microsoft\SQMClient\IE" /v "CEIPEnable" /t REG_DWORD /d "0" /f 
reg add "HKLM\SOFTWARE\Microsoft\SQMClient\IE" /v "SqmLoggerRunning" /t REG_DWORD /d "0" /f 
reg add "HKLM\SOFTWARE\Microsoft\SQMClient\Reliability" /v "CEIPEnable" /t REG_DWORD /d "0" /f 
reg add "HKLM\SOFTWARE\Microsoft\SQMClient\Reliability" /v "SqmLoggerRunning" /t REG_DWORD /d "0" /f 
reg add "HKLM\SOFTWARE\Microsoft\SQMClient\Windows" /v "DisableOptinExperience" /t REG_DWORD /d "1" /f 
reg add "HKLM\SOFTWARE\Microsoft\SQMClient\Windows" /v "CEIPEnable" /t REG_DWORD /d "0" /f 
reg add "HKLM\SOFTWARE\Microsoft\SQMClient\Windows" /v "SqmLoggerRunning" /t REG_DWORD /d "0" /f 
sc.exe config DiagTrack start= disabled 
sc.exe stop DiagTrack 
reg delete "HKLM\SYSTEM\ControlSet001\Control\WMI\AutoLogger\AutoLogger-Diagtrack-Listener" /f 
reg delete "HKLM\SYSTEM\ControlSet002\Control\WMI\AutoLogger\AutoLogger-Diagtrack-Listener" /f 
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\WMI\AutoLogger\AutoLogger-Diagtrack-Listener" /f 
reg delete "HKLM\SYSTEM\ControlSet001\Control\WMI\AutoLogger\Diagtrack-Listener" /f 
reg delete "HKLM\SYSTEM\ControlSet002\Control\WMI\AutoLogger\Diagtrack-Listener" /f 
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\WMI\AutoLogger\Diagtrack-Listener" /f 
reg delete "HKLM\SYSTEM\ControlSet001\Control\WMI\AutoLogger\SQMLogger" /f 
reg delete "HKLM\SYSTEM\ControlSet002\Control\WMI\AutoLogger\SQMLogger" /f 
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\WMI\AutoLogger\SQMLogger" /f 
reg add "HKLM\SYSTEM\ControlSet001\Control\WMI\Autologger\AutoLogger-Diagtrack-Listener" /v "Start" /t REG_DWORD /d "0" /f 
reg add "HKLM\SYSTEM\ControlSet002\Control\WMI\Autologger\AutoLogger-Diagtrack-Listener" /v "Start" /t REG_DWORD /d "0" /f 
reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\AutoLogger-Diagtrack-Listener" /v "Start" /t REG_DWORD /d "0" /f 
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack" /f 
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack" /v "DiagTrackAuthorization" /t REG_DWORD /d "0" /f 
:: Disabling Office Telemetry
reg add "HKCU\Software\Microsoft\Office\Common\ClientTelemetry" /v "DisableTelemetry" /t REG_DWORD /d "1" /f 
reg add "HKCU\Software\Microsoft\Office\16.0\Common" /v "sendcustomerdata" /t REG_DWORD /d "0" /f 
reg add "HKCU\Software\Microsoft\Office\16.0\Common\Feedback" /v "enabled" /t REG_DWORD /d "0" /f 
reg add "HKCU\Software\Microsoft\Office\16.0\Common\Feedback" /v "includescreenshot" /t REG_DWORD /d "0" /f 
reg add "HKCU\Software\Microsoft\Office\16.0\Outlook\Options\Mail" /v "EnableLogging" /t REG_DWORD /d "0" /f 
reg add "HKCU\Software\Microsoft\Office\16.0\Word\Options" /v "EnableLogging" /t REG_DWORD /d "0" /f 
reg add "HKCU\Software\Microsoft\Office\Common\ClientTelemetry" /v "SendTelemetry" /t REG_DWORD /d "3" /f 
reg add "HKCU\Software\Microsoft\Office\16.0\Common" /v "qmenable" /t REG_DWORD /d "0" /f 
reg add "HKCU\Software\Microsoft\Office\16.0\Common" /v "updatereliabilitydata" /t REG_DWORD /d "0" /f 
reg add "HKCU\Software\Microsoft\Office\16.0\Common\General" /v "shownfirstrunoptin" /t REG_DWORD /d "1" /f 
reg add "HKCU\Software\Microsoft\Office\16.0\Common\General" /v "skydrivesigninoption" /t REG_DWORD /d "0" /f 
reg add "HKCU\Software\Microsoft\Office\16.0\Common\ptwatson" /v "ptwoptin" /t REG_DWORD /d "0" /f 
reg add "HKCU\Software\Microsoft\Office\16.0\Firstrun" /v "disablemovie" /t REG_DWORD /d "1" /f 
reg add "HKCU\Software\Microsoft\Office\16.0\OSM" /v "Enablelogging" /t REG_DWORD /d "0" /f 
reg add "HKCU\Software\Microsoft\Office\16.0\OSM" /v "EnableUpload" /t REG_DWORD /d "0" /f 
reg add "HKCU\Software\Microsoft\Office\16.0\OSM" /v "EnableFileObfuscation" /t REG_DWORD /d "1" /f 
reg add "HKCU\Software\Microsoft\Office\16.0\OSM\preventedapplications" /v "accesssolution" /t REG_DWORD /d "1" /f 
reg add "HKCU\Software\Microsoft\Office\16.0\OSM\preventedapplications" /v "olksolution" /t REG_DWORD /d "1" /f 
reg add "HKCU\Software\Microsoft\Office\16.0\OSM\preventedapplications" /v "onenotesolution" /t REG_DWORD /d "1" /f 
reg add "HKCU\Software\Microsoft\Office\16.0\OSM\preventedapplications" /v "pptsolution" /t REG_DWORD /d "1" /f 
reg add "HKCU\Software\Microsoft\Office\16.0\OSM\preventedapplications" /v "projectsolution" /t REG_DWORD /d "1" /f 
reg add "HKCU\Software\Microsoft\Office\16.0\OSM\preventedapplications" /v "publishersolution" /t REG_DWORD /d "1" /f 
reg add "HKCU\Software\Microsoft\Office\16.0\OSM\preventedapplications" /v "visiosolution" /t REG_DWORD /d "1" /f 
reg add "HKCU\Software\Microsoft\Office\16.0\OSM\preventedapplications" /v "wdsolution" /t REG_DWORD /d "1" /f 
reg add "HKCU\Software\Microsoft\Office\16.0\OSM\preventedapplications" /v "xlsolution" /t REG_DWORD /d "1" /f 
reg add "HKCU\Software\Microsoft\Office\16.0\OSM\preventedsolutiontypes" /v "agave" /t REG_DWORD /d "1" /f 
reg add "HKCU\Software\Microsoft\Office\16.0\OSM\preventedsolutiontypes" /v "appaddins" /t REG_DWORD /d "1" /f 
reg add "HKCU\Software\Microsoft\Office\16.0\OSM\preventedsolutiontypes" /v "comaddins" /t REG_DWORD /d "1" /f 
reg add "HKCU\Software\Microsoft\Office\16.0\OSM\preventedsolutiontypes" /v "documentfiles" /t REG_DWORD /d "1" /f 
reg add "HKCU\Software\Microsoft\Office\16.0\OSM\preventedsolutiontypes" /v "templatefiles" /t REG_DWORD /d "1" /f 

goto Windows

:W9
Reg.exe add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Accessibility" /v "Enabled" /t REG_DWORD /d "0" /f 
Reg.exe add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync\Groups\AppSync" /v "Enabled" /t REG_DWORD /d "0" /f 
Reg.exe add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync\Groups\BrowserSettings" /v "Enabled" /t REG_DWORD /d "0" /f 
Reg.exe add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Credentials" /v "Enabled" /t REG_DWORD /d "0" /f 
Reg.exe add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync\Groups\DesktopTheme" /v "Enabled" /t REG_DWORD /d "0" /f 
Reg.exe add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Language" /v "Enabled" /t REG_DWORD /d "0" /f 
Reg.exe add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync\Groups\PackageState" /v "Enabled" /t REG_DWORD /d "0" /f 
Reg.exe add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Personalization" /v "Enabled" /t REG_DWORD /d "0" /f 
Reg.exe add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync\Groups\StartLayout" /v "Enabled" /t REG_DWORD /d "0" /f 
Reg.exe add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Windows" /v "Enabled" /t REG_DWORD /d "0" /f 

::Disable Settings Sync
Reg add "HKLM\Software\Policies\Microsoft\Windows\SettingSync" /v "DisableSettingSync" /t REG_DWORD /d "2" /f 
Reg add "HKLM\Software\Policies\Microsoft\Windows\SettingSync" /v "DisableSettingSyncUserOverride" /t REG_DWORD /d "1" /f 
Reg add "HKLM\Software\Policies\Microsoft\Windows\SettingSync" /v "DisableSyncOnPaidNetwork" /t REG_DWORD /d "1" /f 
Reg add "HKLM\Software\Policies\Microsoft\Windows\OneDrive" /v "DisableFileSyncNGSC" /t REG_DWORD /d "1" /f 

goto Windows

:W10

::Security/Hardening 
::Restrict Enumeration of Anonymous SAM Accounts
::https://www.stigviewer.com/stig/windows_10/2021-03-10/finding/V-220929
Reg add "HKLM\System\CurrentControlSet\Control\Lsa" /v "RestrictAnonymous" /t REG_DWORD /d "1" /f 
::https://www.stigviewer.com/stig/windows_10/2021-03-10/finding/V-220930
Reg add "HKLM\System\CurrentControlSet\Control\Lsa" /v "RestrictAnonymousSAM" /t REG_DWORD /d "1" /f 
::Disable NetBIOS, can be exploited and is highly vulnerable. (From Zeta)
sc config lmhosts start=disabled 
sc stop lmhosts 
::NetBios is disabled. If it manages to become enabled, protect against NBT-NS poisoning attacks
Reg add "HKLM\System\CurrentControlSet\Services\NetBT\Parameters" /v "NodeType" /t REG_DWORD /d "2" /f 
::https://cyware.com/news/what-is-smb-vulnerability-and-how-it-was-exploited-to-launch-the-wannacry-ransomware-attack-c5a97c48
sc stop LanmanWorkstation 
sc config LanmanWorkstation start=disabled 
::LanmanWorkstation is disabled. If it manages to become enabled, protect against other attacks
::https://www.stigviewer.com/stig/windows_10/2021-03-10/finding/V-220932
Reg add "HKLM\System\CurrentControlSet\Services\LanManServer\Parameters" /v "RestrictNullSessAccess" /t REG_DWORD /d "1" /f 
::Disable SMB Compression (Possible SMBGhost Vulnerability workaround)
Reg add "HKLM\System\CurrentControlSet\Services\LanManServer\Parameters" /v "DisableCompression" /t REG_DWORD /d "1" /f 
::Harden lsass
Reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\lsass.exe" /v "AuditLevel" /t REG_DWORD /d "8" /f 
Reg add "HKLM\Software\Policies\Microsoft\Windows\CredentialsDelegation" /v "AllowProtectedCreds" /t REG_DWORD /d "1" /f 
Reg add "HKLM\System\CurrentControlSet\Control\Lsa" /v "DisableRestrictedAdminOutboundCreds" /t REG_DWORD /d "1" /f 
Reg add "HKLM\System\CurrentControlSet\Control\Lsa" /v "DisableRestrictedAdmin" /t REG_DWORD /d "0" /f 
Reg add "HKLM\System\CurrentControlSet\Control\Lsa" /v "RunAsPPL" /t REG_DWORD /d "1" /f 
Reg add "HKLM\System\CurrentControlSet\Control\SecurityProviders\WDigest" /v "Negotiate" /t REG_DWORD /d "0" /f 
Reg add "HKLM\System\CurrentControlSet\Control\SecurityProviders\WDigest" /v "UseLogonCredential" /t REG_DWORD /d "0" /f 

:: Turn off Microsoft Edge page prediction
reg add "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\FlipAhead" /v "FPEnabled" /t REG_DWORD /d "0" /f 
:: Send Do Not Track requests in Microsoft Edge
reg add "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\Main" /v "DoNotTrack" /t REG_DWORD /d "1" /f 
:: Do not optimize taskbar web search results for screen readers
reg add "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\Main" /v "OptimizeWindowsSearchResultsForScreenReaders" /t REG_DWORD /d "0" /f 
:: Do not show search and sites suggestions as I type
reg add "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\Main" /v "ShowSearchSuggestionsGlobal" /t REG_DWORD /d "0" /f 
:: Do not save form entries
reg add "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\Main" /v "Use FormSuggest" /t REG_SZ /d "no" /f 
:: Do not use Windows Defender SmartScreen in Microsoft Edge
reg add "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\PhishingFilter" /v "EnabledV9" /t REG_DWORD /d "0" /f 
:: Do not let sites save protected media licenses on my device
reg add "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\Privacy" /v "EnableEncryptedMediaExtensions" /t REG_DWORD /d "0" /f 
:: Turn Off Cortana in Microsoft Edge
reg add "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\ServiceUI" /v "EnableCortana" /t REG_DWORD /d "0" /f 
:: Do not show search history
reg add "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\ServiceUI\ShowSearchHistory" /ve /t REG_DWORD /d "0" /f 

::Disable Anti Malware
reg add "HKLM\SYSTEM\CurrentControlSet\Services\WinDefend" /v "Start" /t REG_DWORD /d "4" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\SecurityHealthService" /v "Start" /t REG_DWORD /d "4" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\WdNisSvc" /v "Start" /t REG_DWORD /d "4" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Sense" /v "Start" /t REG_DWORD /d "4" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\wscsvc" /v "Start" /t REG_DWORD /d "4" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v "DisableAntiSpyware" /t REG_DWORD /d "1" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v "DisableRoutinelyTakingAction" /t REG_DWORD /d "1" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v "ServiceKeepAlive" /t REG_DWORD /d "0" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableBehaviorMonitoring" /t REG_DWORD /d "1" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableIOAVProtection" /t REG_DWORD /d "1" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableOnAccessProtection" /t REG_DWORD /d "1" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableRealtimeMonitoring" /t REG_DWORD /d "1" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Reporting" /v "DisableEnhancedNotifications" /t REG_DWORD /d "1" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Notifications" /v "DisableNotifications" /t REG_DWORD /d "1" /f
reg add "HKCU\Software\Policies\Microsoft\Windows\CurrentVersion\PushNotifications" /v "NoToastApplicationNotification" /t REG_DWORD /d "1" /f
reg add "HKCU\Software\Policies\Microsoft\Windows\CurrentVersion\PushNotifications" /v "NoToastApplicationNotificationOnLockScreen" /t REG_DWORD /d "1" /f

:: Turn off share apps across devices
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\CDP" /v "EnableRemoteLaunchToast" /t REG_DWORD /d "0" /f 
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\CDP" /v "RomeSdkChannelUserAuthzPolicy" /t REG_DWORD /d "0" /f 

:: TURN OFF Let websites provide locally relevant content by accessing my language list
Reg.exe add "HKCU\Control Panel\International\User Profile" /v "HttpAcceptLanguageOptOut" /t REG_DWORD /d "1" /f
:: TURN OFF Let Windows track app launches to improve Start and search results
Reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Start_TrackProgs" /t REG_DWORD /d "0" /f
Reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\StartPage" /v "StartMenu_Start_Time" /t REG_BINARY /d "0DB474C61FFDD601" /f
:: TURN OFF Getting to know you
Reg.exe add "HKCU\Software\Microsoft\Personalization\Settings" /v "AcceptedPrivacyPolicy" /t REG_DWORD /d "0" /f
Reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Language" /v "Enabled" /t REG_DWORD /d "0" /f
Reg.exe add "HKCU\Software\Microsoft\InputPersonalization\TrainedDataStore" /v "HarvestContacts" /t REG_DWORD /d "0" /f
Reg.exe add "HKCU\Software\Microsoft\IME\15.0\IMETC" /v "Enable Punctuation Input" /t REG_SZ /d "0x00000001" /f
Reg.exe add "HKCU\Software\Microsoft\IME\15.0\IMETC" /v "Enable Inline Candidate Swtch" /t REG_SZ /d "0x00000001" /f
Reg.exe add "HKCU\Software\Microsoft\IME\15.0\IMETC" /v "Enable Warning Beep Feedback" /t REG_SZ /d "0x00000001" /f
Reg.exe add "HKCU\Software\Microsoft\IME\15.0\IMETC" /v "Left Shift Usage" /t REG_SZ /d "0x00000000" /f
Reg.exe add "HKCU\Software\Microsoft\IME\15.0\IMETC" /v "Right Shift Usage" /t REG_SZ /d "0x00000001" /f
Reg.exe add "HKCU\Software\Microsoft\IME\15.0\IMETC" /v "Default Input Mode" /t REG_SZ /d "0x00000000" /f
Reg.exe add "HKCU\Software\Microsoft\IME\15.0\IMETC" /v "UI Font Setting" /t REG_SZ /d "0x00000000" /f
Reg.exe add "HKCU\Software\Microsoft\IME\15.0\IMETC" /v "Output Big5 Only" /t REG_SZ /d "0x00000000" /f
Reg.exe add "HKCU\Software\Microsoft\IME\15.0\IMETC" /v "Include Extension A Characters" /t REG_SZ /d "0x00000000" /f
Reg.exe add "HKCU\Software\Microsoft\IME\15.0\IMETC" /v "Include Extension B Characters" /t REG_SZ /d "0x00000000" /f
Reg.exe add "HKCU\Software\Microsoft\IME\15.0\IMETC" /v "Allow CNS Input Sequence" /t REG_SZ /d "0x00000000" /f
Reg.exe add "HKCU\Software\Microsoft\IME\15.0\IMETC" /v "Include HKSCS Characters" /t REG_SZ /d "0x00000000" /f
Reg.exe add "HKCU\Software\Microsoft\IME\15.0\IMETC" /v "Show Ballon UI" /t REG_SZ /d "0x00000001" /f
Reg.exe add "HKCU\Software\Microsoft\IME\15.0\IMETC" /v "Show Phrase Input Ballon UI" /t REG_SZ /d "0x00000001" /f
Reg.exe add "HKCU\Software\Microsoft\IME\15.0\IMETC" /v "Phrase Editor Main Sort Type" /t REG_SZ /d "0x00000000" /f
Reg.exe add "HKCU\Software\Microsoft\IME\15.0\IMETC" /v "Phrase Editor Self Learn Sort Type" /t REG_SZ /d "0x00000000" /f
Reg.exe add "HKCU\Software\Microsoft\IME\15.0\IMETC" /v "UI language" /t REG_SZ /d "0xffffffff" /f
Reg.exe add "HKCU\Software\Microsoft\IME\15.0\IMETC" /v "Plugin Lexicon" /t REG_BINARY /d "00000000000000000000000000000000" /f
Reg.exe add "HKCU\Software\Microsoft\IME\15.0\IMETC" /v "Enable Intelligent Auto Input Switch" /t REG_SZ /d "0x00000000" /f
Reg.exe add "HKCU\Software\Microsoft\IME\15.0\IMETC" /v "Enable Auto Input Switch" /t REG_SZ /d "0x00000000" /f
Reg.exe add "HKCU\Software\Microsoft\IME\15.0\IMETC" /v "Enable Sentence-Final Conversion" /t REG_SZ /d "0x00000001" /f
Reg.exe add "HKCU\Software\Microsoft\IME\15.0\IMETC" /v "Enable Punctuation Auto Finalize" /t REG_SZ /d "0x00000000" /f
Reg.exe add "HKCU\Software\Microsoft\IME\15.0\IMETC" /v "Enable Input Status Feedback" /t REG_SZ /d "0x00000001" /f
Reg.exe add "HKCU\Software\Microsoft\IME\15.0\IMETC" /v "Leading Key Setting" /t REG_SZ /d "0x00000000" /f
Reg.exe add "HKCU\Software\Microsoft\IME\15.0\IMETC" /v "Enable Fuzzy Input" /t REG_SZ /d "0x00000000" /f
Reg.exe add "HKCU\Software\Microsoft\IME\15.0\IMETC" /v "Enable Z Key as Wildcard" /t REG_SZ /d "0x00000001" /f
Reg.exe add "HKCU\Software\Microsoft\IME\15.0\IMETC" /v "Use ESC to Finalize" /t REG_SZ /d "0x00000000" /f
Reg.exe add "HKCU\Software\Microsoft\IME\15.0\IMETC" /v "Enable New Phrase Learning" /t REG_SZ /d "0x00000001" /f
Reg.exe add "HKCU\Software\Microsoft\IME\15.0\IMETC" /v "Enable Personal Regulating" /t REG_SZ /d "0x00000001" /f
Reg.exe add "HKCU\Software\Microsoft\IME\15.0\IMETC" /v "Fixed Candidate Order.New Phonetic" /t REG_SZ /d "0x00000000" /f
Reg.exe add "HKCU\Software\Microsoft\IME\15.0\IMETC" /v "Fixed Candidate Order.New Changjie" /t REG_SZ /d "0x00000000" /f
Reg.exe add "HKCU\Software\Microsoft\IME\15.0\IMETC" /v "Fixed Candidate Order.New Quick" /t REG_SZ /d "0x00000000" /f
Reg.exe add "HKCU\Software\Microsoft\IME\15.0\IMETC" /v "Fixed Candidate Order.Cantonese" /t REG_SZ /d "0x00000000" /f
Reg.exe add "HKCU\Software\Microsoft\IME\15.0\IMETC" /v "Enable User Defined Phrases" /t REG_SZ /d "0x00000001" /f
Reg.exe add "HKCU\Software\Microsoft\IME\15.0\IMETC" /v "Prompt Associate Phrase.Phonetic" /t REG_SZ /d "0x00000001" /f
Reg.exe add "HKCU\Software\Microsoft\IME\15.0\IMETC" /v "Prompt Associate Phrase.Changjie" /t REG_SZ /d "0x00000001" /f
Reg.exe add "HKCU\Software\Microsoft\IME\15.0\IMETC" /v "Prompt Associate Phrase.Quick" /t REG_SZ /d "0x00000001" /f
Reg.exe add "HKCU\Software\Microsoft\IME\15.0\IMETC" /v "Prompt Associate Phrase.Intelligent" /t REG_SZ /d "0x00000000" /f
Reg.exe add "HKCU\Software\Microsoft\IME\15.0\IMETC" /v "Enable Simplified Chinese Output" /t REG_SZ /d "0x00000000" /f
Reg.exe add "HKCU\Software\Microsoft\IME\15.0\IMETC" /v "Enable Toneless Input" /t REG_SZ /d "0x00000000" /f
Reg.exe add "HKCU\Software\Microsoft\IME\15.0\IMETC" /v "Enable Toneless Key" /t REG_SZ /d "0x00000000" /f
Reg.exe add "HKCU\Software\Microsoft\IME\15.0\IMETC" /v "Enable PhraseInput Key" /t REG_SZ /d "0x00000001" /f
Reg.exe add "HKCU\Software\Microsoft\IME\15.0\IMETC" /v "SIP Prediction" /t REG_SZ /d "0x00000001" /f
Reg.exe add "HKCU\Software\Microsoft\IME\15.0\IMETC" /v "Toneless Key Setting" /t REG_SZ /d "0x00000000" /f
Reg.exe add "HKCU\Software\Microsoft\IME\15.0\IMETC" /v "Inline Candidate Switch Key Setting" /t REG_SZ /d "0x00000001" /f
Reg.exe add "HKCU\Software\Microsoft\IME\15.0\IMETC" /v "PhraseInput Key Setting" /t REG_SZ /d "0x00000001" /f
Reg.exe add "HKCU\Software\Microsoft\IME\15.0\IMETC" /v "Keyboard Layout Setting.New Phonetic" /t REG_SZ /d "0x00020010" /f
Reg.exe add "HKCU\Software\Microsoft\IME\15.0\IMETC" /v "Keyboard Layout Setting.Phonetic" /t REG_SZ /d "0x00020010" /f
Reg.exe add "HKCU\Software\Microsoft\IME\15.0\IMETC" /v "Reading Indication Setting.New Phonetic" /t REG_SZ /d "0x00000000" /f
Reg.exe add "HKCU\Software\Microsoft\IME\15.0\IMETC" /v "ConfigMigrated.New Phonetic" /t REG_SZ /d "0x00000001" /f
Reg.exe add "HKCU\Software\Microsoft\IME\15.0\IMETC" /v "EUDC Filename.Phonetic" /t REG_SZ /d "TCEUDCPH.TBL" /f
Reg.exe add "HKCU\Software\Microsoft\IME\15.0\IMETC" /v "EUDC Filename.ChangJie" /t REG_SZ /d "TCEUDCCJ.TBL" /f
Reg.exe add "HKCU\Software\Microsoft\IME\15.0\IMETC" /v "EUDC Filename.Quick" /t REG_SZ /d "TCEUDCCJ.TBL" /f
Reg.exe add "HKCU\Software\Microsoft\IME\15.0\IMETC" /v "EUDC Filename.Cantonese" /t REG_SZ /d "TCEUDCCT.TBL" /f
Reg.exe add "HKCU\Software\Microsoft\IME\15.0\IMETC" /v "EUDR Filename.Phonetic" /t REG_SZ /d "TCEUDRPH.TBL" /f
Reg.exe add "HKCU\Software\Microsoft\IME\15.0\IMETC" /v "EUDR Filename.ChangJie" /t REG_SZ /d "TCEUDRCJ.TBL" /f

goto Windows

:W11

reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "OemPreInstalledAppsEnabled" /t REG_DWORD /d "0" /f 
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "PreInstalledAppsEnabled" /t REG_DWORD /d "0" /f 
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "PreInstalledAppsEverEnabled" /t REG_DWORD /d "0" /f 

goto Windows

:W12
Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "AllowCortana" /t REG_DWORD /d "0" /f 
Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "AllowCloudSearch" /t REG_DWORD /d "0" /f 
Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "AllowCortanaAboveLock" /t REG_DWORD /d "0" /f 
Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "AllowSearchToUseLocation" /t REG_DWORD /d "0" /f 
Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "ConnectedSearchUseWeb" /t REG_DWORD /d "0" /f 
Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "ConnectedSearchUseWebOverMeteredConnections" /t REG_DWORD /d "0" /f 
Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "DisableWebSearch" /t REG_DWORD /d "0" /f 
reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "BingSearchEnabled" /t REG_DWORD /d "0" /f 
reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "AllowSearchToUseLocation" /t REG_DWORD /d "0" /f 
reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "CortanaConsent" /t REG_DWORD /d "0" /f 
reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\Windows Search" /v "CortanaConsent" /t REG_DWORD /d "0" /f 
reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE" /v "DisableVoice" /t REG_DWORD /d "1" /f 

goto Windows

:W13

:: Disable Windows Error Reporting
Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting" /v "Disabled" /t REG_DWORD /d "1" /f 
Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting" /v "DoReport" /t REG_DWORD /d "0" /f 
Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting" /v "LoggingDisabled" /t REG_DWORD /d "1" /f 
Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\PCHealth\ErrorReporting" /v "DoReport" /t REG_DWORD /d "0" /f 
reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting" /v "Disabled" /t REG_DWORD /d "1" /f 
reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting" /v "DontSendAdditionalData" /t REG_DWORD /d "1" /f 
reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting" /v "DontShowUI" /t REG_DWORD /d "1" /f
reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting" /v "LoggingDisabled" /t REG_DWORD /d "1" /f 
reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting" /v "MachineID" /t REG_SZ /d "0" /f
reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting\WMR" /v "Disable" /t REG_DWORD /d "1" /f
reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting\Consent" /v "DefaultConsent" /t REG_DWORD /d "0" /f
reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting\Consent" /v "NewUserDefaultConsent" /t REG_DWORD /d "0" /f

goto Windows

:W14
:: Pause Maps Updates/Downloads
Reg add "HKLM\Software\Policies\Microsoft\Windows\Maps" /v "AutoDownloadAndUpdateMapData" /t REG_DWORD /d "0" /f 
Reg add "HKLM\Software\Policies\Microsoft\Windows\Maps" /v "AllowUntriggeredNetworkTrafficOnSettingsPage" /t REG_DWORD /d "0" /f 

net stop spooler

goto Windows

:W15

:: Hide Insider Page
reg add "HKLM\SOFTWARE\Microsoft\WindowsSelfHost\UI\Visibility" /v "HideInsiderPage" /t REG_DWORD /d "1" /f

:: Disabling Windows Insider Experiments
Reg.exe add "HKLM\SOFTWARE\Microsoft\PolicyManager\current\device\System" /v "AllowExperimentation" /t REG_DWORD /d "0" /f 
Reg.exe add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\System\AllowExperimentation" /v "value" /t REG_DWORD /d "0" /f

goto Windows

:W16
:: Services Tweaks
reg add "HKLM\SYSTEM\CurrentControlSet\Services\AarSvc" /v "Start" /t REG_DWORD /d "4" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\AJRouter" /v "Start" /t REG_DWORD /d "4" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\ALG" /v "Start" /t REG_DWORD /d "4" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\AppIDSvc" /v "Start" /t REG_DWORD /d "4" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Appinfo" /v "Start" /t REG_DWORD /d "3" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\AppMgmt" /v "Start" /t REG_DWORD /d "4" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\AppReadiness" /v "Start" /t REG_DWORD /d "4" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\AppVClient" /v "Start" /t REG_DWORD /d "4" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\AssignedAccessManagerSvc" /v "Start" /t REG_DWORD /d "4" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\AudioEndpointBuilder" /v "Start" /t REG_DWORD /d "2" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Audiosrv" /v "Start" /t REG_DWORD /d "2" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\autotimesvc" /v "Start" /t REG_DWORD /d "4" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\AxInstSV" /v "Start" /t REG_DWORD /d "4" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\BcastDVRUserService" /v "Start" /t REG_DWORD /d "4" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\BFE" /v "Start" /t REG_DWORD /d "2" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\BITS" /v "Start" /t REG_DWORD /d "3" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\BluetoothUserService" /v "Start" /t REG_DWORD /d "4" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\BrokerInfrastructure" /v "Start" /t REG_DWORD /d "2" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\BTAGService" /v "Start" /t REG_DWORD /d "4" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\BthAvctpSvc" /v "Start" /t REG_DWORD /d "4" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\bthserv" /v "Start" /t REG_DWORD /d "4" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\camsvc" /v "Start" /t REG_DWORD /d "3" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\CaptureService" /v "Start" /t REG_DWORD /d "4" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\cbdhsvc" /v "Start" /t REG_DWORD /d "4" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\CDPSvc" /v "Start" /t REG_DWORD /d "2" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\CDPUserSvc" /v "Start" /t REG_DWORD /d "2" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\CertPropSvc" /v "Start" /t REG_DWORD /d "4" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\ClipSVC" /v "Start" /t REG_DWORD /d "3" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\COMSysApp" /v "Start" /t REG_DWORD /d "4" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\ConsentUxUserSvc" /v "Start" /t REG_DWORD /d "4" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\CoreMessagingRegistrar" /v "Start" /t REG_DWORD /d "2" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\CredentialEnrollmentManagerUserSvc" /v "Start" /t REG_DWORD /d "4" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\CryptSvc" /v "Start" /t REG_DWORD /d "2" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\CscService" /v "Start" /t REG_DWORD /d "4" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\DcomLaunch" /v "Start" /t REG_DWORD /d "2" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\defragsvc" /v "Start" /t REG_DWORD /d "4" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\DeviceAssociationBrokerSvc" /v "Start" /t REG_DWORD /d "4" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\DeviceAssociationService" /v "Start" /t REG_DWORD /d "3" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\DeviceInstall" /v "Start" /t REG_DWORD /d "3" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\DevicePickerUserSvc" /v "Start" /t REG_DWORD /d "4" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\DevicesFlowUserSvc" /v "Start" /t REG_DWORD /d "3" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\DevQueryBroker" /v "Start" /t REG_DWORD /d "4" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Dhcp" /v "Start" /t REG_DWORD /d "2" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\diagnosticshub.standardcollector.service" /v "Start" /t REG_DWORD /d "4" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\diagsvc" /v "Start" /t REG_DWORD /d "4" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\DispBrokerDesktopSvc" /v "Start" /t REG_DWORD /d "4" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\DisplayEnhancementService" /v "Start" /t REG_DWORD /d "4" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\DmEnrollmentSvc" /v "Start" /t REG_DWORD /d "4" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\dmwappushservice" /v "Start" /t REG_DWORD /d "4" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Dnscache" /v "Start" /t REG_DWORD /d "2" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\DoSvc" /v "Start" /t REG_DWORD /d "4" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\dot3svc" /v "Start" /t REG_DWORD /d "3" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\DPS" /v "Start" /t REG_DWORD /d "4" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\DsmSvc" /v "Start" /t REG_DWORD /d "4" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\DsSvc" /v "Start" /t REG_DWORD /d "4" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\DusmSvc" /v "Start" /t REG_DWORD /d "4" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Eaphost" /v "Start" /t REG_DWORD /d "3" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\EFS" /v "Start" /t REG_DWORD /d "4" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\embeddedmode" /v "Start" /t REG_DWORD /d "4" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\EntAppSvc" /v "Start" /t REG_DWORD /d "4" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\EventLog" /v "Start" /t REG_DWORD /d "2" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\EventSystem" /v "Start" /t REG_DWORD /d "2" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\fdPHost" /v "Start" /t REG_DWORD /d "4" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\FDResPub" /v "Start" /t REG_DWORD /d "4" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\fhsvc" /v "Start" /t REG_DWORD /d "4" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\FontCache" /v "Start" /t REG_DWORD /d "4" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\FontCache3.0.0.0" /v "Start" /t REG_DWORD /d "4" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\FrameServer" /v "Start" /t REG_DWORD /d "4" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\gpsvc" /v "Start" /t REG_DWORD /d "2" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\GraphicsPerfSvc" /v "Start" /t REG_DWORD /d "4" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\hidserv" /v "Start" /t REG_DWORD /d "3" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\HvHost" /v "Start" /t REG_DWORD /d "4" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\icssvc" /v "Start" /t REG_DWORD /d "3" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\IKEEXT" /v "Start" /t REG_DWORD /d "4" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\InstallService" /v "Start" /t REG_DWORD /d "3" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\iphlpsvc" /v "Start" /t REG_DWORD /d "2" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\IpxlatCfgSvc" /v "Start" /t REG_DWORD /d "4" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\KeyIso" /v "Start" /t REG_DWORD /d "3" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\KtmRm" /v "Start" /t REG_DWORD /d "4" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer" /v "Start" /t REG_DWORD /d "4" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanWorkstation" /v "Start" /t REG_DWORD /d "4" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\lfsvc" /v "Start" /t REG_DWORD /d "4" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LicenseManager" /v "Start" /t REG_DWORD /d "3" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\lltdsvc" /v "Start" /t REG_DWORD /d "4" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\lmhosts" /v "Start" /t REG_DWORD /d "4" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LSM" /v "Start" /t REG_DWORD /d "2" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LxpSvc" /v "Start" /t REG_DWORD /d "4" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\MapsBroker" /v "Start" /t REG_DWORD /d "4" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\MessagingService" /v "Start" /t REG_DWORD /d "4" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\mpssvc" /v "Start" /t REG_DWORD /d "2" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\MSDTC" /v "Start" /t REG_DWORD /d "4" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\MSiSCSI" /v "Start" /t REG_DWORD /d "4" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\msiserver" /v "Start" /t REG_DWORD /d "3" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\NaturalAuthentication" /v "Start" /t REG_DWORD /d "4" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\NcaSvc" /v "Start" /t REG_DWORD /d "4" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\NcbService" /v "Start" /t REG_DWORD /d "3" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\NcdAutoSetup" /v "Start" /t REG_DWORD /d "4" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Netlogon" /v "Start" /t REG_DWORD /d "4" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Netman" /v "Start" /t REG_DWORD /d "3" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\netprofm" /v "Start" /t REG_DWORD /d "3" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\NetSetupSvc" /v "Start" /t REG_DWORD /d "3" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\NetTcpPortSharing" /v "Start" /t REG_DWORD /d "4" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\wuauserv" /v "Start" /t REG_DWORD /d "3" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\W32Time" /v "Start" /t REG_DWORD /d "4" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\WinRM" /v "Start" /t REG_DWORD /d "4" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\SDRSVC" /v "Start" /t REG_DWORD /d "4" /f   
reg add "HKLM\SYSTEM\CurrentControlSet\Services\WbioSrvc" /v "Start" /t REG_DWORD /d "4" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Wecsvc" /v "Start" /t REG_DWORD /d "4" /f
net pause DiagTrack >nul 2>&1
net pause DialogBlockingService
net pause MsKeyboardFilter
net pause NetMsmqActivator 
net pause PcaSvc 
net pause SEMgrSvc 
net pause ShellHWDetection
net pause shpamsvc 
net pause SysMain
net pause Themes 
net pause TrkWks 
net pause tzautoupdate 
net pause uhssvc
net pause W3SVC
net pause OneSyncSvc
net pause WdiSystemHost 
net pause WdiServiceHost 
net pause SCardSvr 
net pause ScDeviceEnum 
net pause SCPolicySvc
net pause SensorDataService 
net pause SensrSvc 
net pause Beep
net pause cdfs 
net pause cdrom 
net pause cnghwassist 
net pause GpuEnergyDrv 
net pause Telemetry 
net pause VerifierExt
sc stop DoSvc 
sc config DoSvc start= disabled 
sc stop DPS  
sc config DPS start= disabled 
sc stop dmwappushservice 
sc config dmwappushservice start= disabled 
sc stop MapsBroker 
sc config MapsBroker start= disabled 
sc stop lfsvc 
sc config lfsvc start= disabled 
sc stop CscService 
sc config CscService start= disabled 
sc stop SEMgrSvc 
sc config SEMgrSvc start= disabled 
sc stop PhoneSvc 
sc config PhoneSvc start= disabled 
sc stop RemoteRegistry 
sc config RemoteRegistry start= disabled 
sc stop RetailDemo 
sc config RetailDemo start= disabled 
sc stop SysMain 
sc config SysMain start= disabled 
sc stop WalletService 
sc config WalletService start= disabled 
sc stop W32Time 
sc config W32Time start= disabled 
sc stop XboxGipSvc 
sc config XboxGipSvc start= disabled 
sc stop xbgm 
sc config xbgm start= disabled 
sc stop XblAuthManager 
sc config XblAuthManager start= disabled 
sc stop XblGameSave 
sc config XblGameSave start= disabled 
sc stop XboxNetApiSvc 
sc config XboxNetApiSvc start= disabled

:: Microsoft tasks
schtasks /Change /TN "Microsoft\Windows\AppID\SmartScreenSpecific" /Disable
schtasks /Change /TN "Microsoft\Windows\AppID\VerifiedPublisherCertStoreCheck" /Disable
schtasks /Change /TN "Microsoft\Windows\Application Experience\AitAgent" /Disable
schtasks /Change /TN "Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" /Disable
schtasks /Change /TN "Microsoft\Windows\Application Experience\ProgramDataUpdater" /Disable
schtasks /Change /TN "Microsoft\Windows\Application Experience\StartupAppTask" /Disable
schtasks /Change /TN "Microsoft\Windows\ApplicationData\AppUriVerifierDaily" /Disable
schtasks /Change /TN "Microsoft\Windows\ApplicationData\AppUriVerifierInstall" /Disable
schtasks /Change /TN "Microsoft\Windows\ApplicationData\DsSvcCleanup" /Disable
schtasks /Change /TN "Microsoft\Windows\Autochk\Proxy" /Disable
schtasks /Change /TN "Microsoft\Windows\CloudExperienceHost\CreateObjectTask" /Disable
schtasks /Change /TN "Microsoft\Windows\Customer Experience Improvement Program\BthSQM" /Disable
schtasks /Change /TN "Microsoft\Windows\Customer Experience Improvement Program\Consolidator" /Disable
schtasks /Change /TN "Microsoft\Windows\Customer Experience Improvement Program\HypervisorFlightingTask" /Disable
schtasks /Change /TN "Microsoft\Windows\Customer Experience Improvement Program\KernelCeipTask" /Disable
schtasks /Change /TN "Microsoft\Windows\Customer Experience Improvement Program\Uploader" /Disable
schtasks /Change /TN "Microsoft\Windows\Customer Experience Improvement Program\UsbCeip" /Disable
schtasks /Change /TN "Microsoft\Windows\Device information\Device" /Disable
schtasks /Change /TN "Microsoft\Windows\Device Setup\Metadata Refresh" /Disable
schtasks /Change /TN "Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector" /Disable
schtasks /Change /TN "Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticResolver" /Disable
schtasks /Change /TN "Microsoft\Windows\DiskFootprint\Diagnostics" /Disable
schtasks /Change /TN "Microsoft\Windows\End Of Support\Notify1" /Disable
schtasks /Change /TN "Microsoft\Windows\End Of Support\Notify2" /Disable
schtasks /Change /TN "Microsoft\Windows\ErrorDetails\EnableErrorDetailsUpdate" /Disable
schtasks /Change /TN "Microsoft\Windows\ErrorDetails\ErrorDetailsUpdate" /Disable
schtasks /Change /TN "Microsoft\Windows\Feedback\Siuf\DmClient" /Disable
schtasks /Change /TN "Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload" /Disable
schtasks /Change /TN "Microsoft\Windows\FileHistory\File History (maintenance mode)" /Disable
schtasks /Change /TN "Microsoft\Windows\Flighting\OneSettings\RefreshCache" /Disable
schtasks /Change /TN "Microsoft\Windows\LanguageComponentsInstaller\Installation" /Disable
schtasks /Change /TN "Microsoft\Windows\LanguageComponentsInstaller\ReconcileLanguageResources" /Disable
schtasks /Change /TN "Microsoft\Windows\Location\Notifications" /Disable
schtasks /Change /TN "Microsoft\Windows\Maintenance\WinSAT" /Disable
schtasks /Change /TN "Microsoft\Windows\Media Center\ActivateWindowsSearch" /Disable
schtasks /Change /TN "Microsoft\Windows\Media Center\ConfigureInternetTimeService" /Disable
schtasks /Change /TN "Microsoft\Windows\Media Center\DispatchRecoveryTasks" /Disable
schtasks /Change /TN "Microsoft\Windows\Media Center\ehDRMInit" /Disable
schtasks /Change /TN "Microsoft\Windows\Media Center\InstallPlayReady" /Disable
schtasks /Change /TN "Microsoft\Windows\Media Center\mcupdate" /Disable
schtasks /Change /TN "Microsoft\Windows\Media Center\MediaCenterRecoveryTask" /Disable
schtasks /Change /TN "Microsoft\Windows\Media Center\ObjectStoreRecoveryTask" /Disable
schtasks /Change /TN "Microsoft\Windows\Media Center\OCURActivate" /Disable
schtasks /Change /TN "Microsoft\Windows\Media Center\OCURDiscovery" /Disable
schtasks /Change /TN "Microsoft\Windows\Media Center\PBDADiscovery" /Disable
schtasks /Change /TN "Microsoft\Windows\Media Center\PBDADiscoveryW1" /Disable
schtasks /Change /TN "Microsoft\Windows\Media Center\PBDADiscoveryW2" /Disable
schtasks /Change /TN "Microsoft\Windows\Media Center\PvrRecoveryTask" /Disable
schtasks /Change /TN "Microsoft\Windows\Media Center\PvrScheduleTask" /Disable
schtasks /Change /TN "Microsoft\Windows\Media Center\RegisterSearch" /Disable
schtasks /Change /TN "Microsoft\Windows\Media Center\ReindexSearchRoot" /Disable
schtasks /Change /TN "Microsoft\Windows\Media Center\SqlLiteRecoveryTask" /Disable
schtasks /Change /TN "Microsoft\Windows\Media Center\UpdateRecordPath" /Disable
schtasks /Change /TN "Microsoft\Windows\Mobile Broadband Accounts\MNO Metadata Parser" /Disable
schtasks /Change /TN "Microsoft\Windows\NetTrace\GatherNetworkInfo" /Disable
schtasks /Change /TN "Microsoft\Windows\NlaSvc\WiFiTask" /Disable
schtasks /Change /TN "Microsoft\Windows\PerfTrack\BackgroundConfigSurveyor" /Disable
schtasks /Change /TN "Microsoft\Windows\PI\Sqm-Tasks" /Disable
schtasks /Change /TN "Microsoft\Windows\Power Efficiency Diagnostics\AnalyzeSystem" /Disable
schtasks /Change /TN "Microsoft\Windows\PushToInstall\LoginCheck" /Disable
schtasks /Change /TN "Microsoft\Windows\PushToInstall\Registration" /Disable
schtasks /Change /TN "Microsoft\Windows\RemoteAssistance\RemoteAssistanceTask" /Disable
schtasks /Change /TN "Microsoft\Windows\RemovalTools\MRT_ERROR_HB" /Disable
schtasks /Change /TN "Microsoft\Windows\SettingSync\BackgroundUploadTask" /Disable
schtasks /Change /TN "Microsoft\Windows\SettingSync\BackupTask" /Disable
schtasks /Change /TN "Microsoft\Windows\SettingSync\NetworkStateChangeTask" /Disable
schtasks /Change /TN "Microsoft\Windows\Setup\gwx\launchtrayprocess" /Disable
schtasks /Change /TN "Microsoft\Windows\Setup\gwx\refreshgwxconfig" /Disable
schtasks /Change /TN "Microsoft\Windows\Setup\gwx\refreshgwxconfigandcontent" /Disable
schtasks /Change /TN "Microsoft\Windows\Setup\GWXTriggers\Logon-10s" /Disable
schtasks /Change /TN "Microsoft\Windows\Setup\GWXTriggers\Logon-5d" /Disable
schtasks /Change /TN "Microsoft\Windows\Setup\GWXTriggers\MachineUnlock-10s" /Disable
schtasks /Change /TN "Microsoft\Windows\Setup\GWXTriggers\MachineUnlock-5d" /Disable
schtasks /Change /TN "Microsoft\Windows\Setup\GWXTriggers\OutOfIdle-10s" /Disable
schtasks /Change /TN "Microsoft\Windows\Setup\GWXTriggers\OutOfIdle-5d" /Disable
schtasks /Change /TN "Microsoft\Windows\Setup\GWXTriggers\OutOfSleep-10s" /Disable
schtasks /Change /TN "Microsoft\Windows\Setup\GWXTriggers\OutOfSleep-5d" /Disable
schtasks /Change /TN "Microsoft\Windows\Setup\GWXTriggers\refreshgwxconfig-B" /Disable
schtasks /Change /TN "Microsoft\Windows\Setup\GWXTriggers\Telemetry-4xd" /Disable
schtasks /Change /TN "Microsoft\Windows\Setup\GWXTriggers\Time-10s" /Disable
schtasks /Change /TN "Microsoft\Windows\Setup\GWXTriggers\Time-5d" /Disable
schtasks /Change /TN "Microsoft\Windows\Shell\CreateObjectTask" /Disable
schtasks /Change /TN "Microsoft\Windows\Shell\FamilySafetyMonitor" /Disable
schtasks /Change /TN "Microsoft\Windows\Shell\FamilySafetyMonitorToastTask" /Disable
schtasks /Change /TN "Microsoft\Windows\Shell\FamilySafetyRefresh" /Disable
schtasks /Change /TN "Microsoft\Windows\Shell\FamilySafetyRefreshTask" /Disable
schtasks /Change /TN "Microsoft\Windows\Shell\FamilySafetyUpload" /Disable
schtasks /Change /TN "Microsoft\Windows\SideShow\SessionAgent" /Disable
schtasks /Change /TN "Microsoft\Windows\SideShow\SystemDataProviders" /Disable
schtasks /Change /TN "Microsoft\Windows\Speech\SpeechModelDownloadTask" /Disable
schtasks /Change /TN "Microsoft\Windows\UpdateOrchestrator\Reboot" /Disable
schtasks /Change /TN "Microsoft\Windows\UpdateOrchestrator\Schedule Scan" /Disable
schtasks /Change /TN "Microsoft\Windows\UpdateOrchestrator\Schedule Scan Static Task" /Disable
schtasks /Change /TN "Microsoft\Windows\UpdateOrchestrator\USO_Broker_Display" /Disable
schtasks /Change /TN "Microsoft\Windows\UpdateOrchestrator\USO_RebootDisplay" /Disable
schtasks /Change /TN "Microsoft\Windows\UpdateOrchestrator\USO_UxBroker" /Disable
schtasks /Change /TN "Microsoft\Windows\UpdateOrchestrator\USO_UxBroker_Display" /Disable
schtasks /Change /TN "Microsoft\Windows\UpdateOrchestrator\USO_UxBroker_ReadyToReboot" /Disable
schtasks /Change /TN "Microsoft\Windows\UpdateOrchestrator\USO_UxBroker_WnfDisplay" /Disable
schtasks /Change /TN "Microsoft\Windows\UpdateOrchestrator\USO_WnfDisplay" /Disable
schtasks /Change /TN "Microsoft\Windows\UPnP\UPnPHostConfig" /Disable
schtasks /Change /TN "Microsoft\Windows\User Profile Service\HiveUploadTask" /Disable
schtasks /Change /TN "Microsoft\Windows\WaaSMedic\PerformRemediation" /Disable
schtasks /Change /TN "Microsoft\Windows\Windows Defender\Windows Defender Scheduled Scan" /Disable
schtasks /Change /TN "Microsoft\Windows\Windows Error Reporting\QueueReporting" /Disable
schtasks /Change /TN "Microsoft\Windows\WindowsUpdate\Automatic App Update" /Disable
schtasks /Change /TN "Microsoft\Windows\WindowsUpdate\sih" /Disable
if not "%Win_Games%"=="Games_ON" (
schtasks /Change /TN "Microsoft\XblGameSave\XblGameSaveTask" /Disable
schtasks /Change /TN "Microsoft\XblGameSave\XblGameSaveTaskLogon" /Disable
)
schtasks /Change /TN "NvTmMon_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}" /Disable
schtasks /Change /TN "NvTmRep" /Disable
schtasks /Change /TN "NvTmRep_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}" /Disable
schtasks /Change /TN "NvTmRepCR1_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}" /Disable
schtasks /Change /TN "NvTmRepCR2_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}" /Disable
schtasks /Change /TN "NvTmRepCR3_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}" /Disable
schtasks /Change /TN "NvTmRepOnLogon_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}" /Disable
schtasks /Change /TN "\OneDrive Standalone Update Task-%User_SID%" /Disable
:: Office tasks
schtasks /Change /TN "Microsoft\Office\Office 15 Subscription Heartbeat" /Disable
schtasks /Change /TN "Microsoft\Office\Office Automatic Updates" /Disable
schtasks /Change /TN "Microsoft\Office\Office Automatic Updates 2.0" /Disable
schtasks /Change /TN "Microsoft\Office\Office ClickToRun Service Monitor" /Disable
schtasks /Change /TN "Microsoft\Office\Office Feature Updates" /Disable
schtasks /Change /TN "Microsoft\Office\Office Feature Updates Logon" /Disable
schtasks /Change /TN "Microsoft\Office\OfficeTelemetry\AgentLogOn2016" /Disable
schtasks /Change /TN "Microsoft\Office\OfficeTelemetry\OfficeTelemetryAgentLogOn2016" /Disable
schtasks /Change /TN "Microsoft\Office\OfficeTelemetryAgentFallBack" /Disable
schtasks /Change /TN "Microsoft\Office\OfficeTelemetry\AgentFallBack2016" /Disable
schtasks /Change /TN "Microsoft\Office\OfficeTelemetryAgentLogOn" /Disable
schtasks /Change /TN "Microsoft\Office\OfficeTelemetryAgentLogOn2016" /Disable
:: Finally delete bad tasks
schtasks /Delete /F /TN "Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser"
schtasks /Delete /F /TN "Microsoft\Windows\Application Experience\ProgramDataUpdater"
schtasks /Delete /F /TN "Microsoft\Windows\Application Experience\AitAgent"
schtasks /Delete /F /TN "Microsoft\Windows\PerfTrack\BackgroundConfigSurveyor"


goto Windows


:Ram
echo.%G% 
echo. ╔═══════════════════════════╗
echo. ║                           ║
echo  ║   RAM Optimization        ║
echo. ║                           ║   
echo. ╚═══════════════════════════╝
echo.%C%
:: Ram
:: Lower Ram Usage
reg add "HKLM\SYSTEM\CurrentControlSet\Control" /v "WaitToKillServiceTimeout" /t REG_SZ /d "2000" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Audio" /v "Affinity" /t REG_DWORD /d "0" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Audio" /v "Background Only" /t REG_SZ /d "True" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Audio" /v "Clock Rate" /t REG_DWORD /d "10000" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Audio" /v "GPU Priority" /t REG_DWORD /d "8" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Audio" /v "Priority" /t REG_DWORD /d "6" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Audio" /v "Scheduling Category" /t REG_SZ /d "Medium" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Audio" /v "SFIO Priority" /t REG_SZ /d "Normal" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Capture" /v "Affinity" /t REG_DWORD /d "0" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Capture" /v "Background Only" /t REG_SZ /d "True" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Capture" /v "Clock Rate" /t REG_DWORD /d "10000" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Capture" /v "GPU Priority" /t REG_DWORD /d "8" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Capture" /v "Priority" /t REG_DWORD /d "5" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Capture" /v "Scheduling Category" /t REG_SZ /d "Medium" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Capture" /v "SFIO Priority" /t REG_SZ /d "Normal" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\DisplayPostProcessing" /v "Affinity" /t REG_DWORD /d "0" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\DisplayPostProcessing" /v "Background Only" /t REG_SZ /d "True" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\DisplayPostProcessing" /v "BackgroundPriority" /t REG_DWORD /d "8" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\DisplayPostProcessing" /v "Clock Rate" /t REG_DWORD /d "10000" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\DisplayPostProcessing" /v "GPU Priority" /t REG_DWORD /d "8" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\DisplayPostProcessing" /v "Priority" /t REG_DWORD /d "8" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\DisplayPostProcessing" /v "Scheduling Category" /t REG_SZ /d "High" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\DisplayPostProcessing" /v "SFIO Priority" /t REG_SZ /d "Normal" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Distribution" /v "Affinity" /t REG_DWORD /d "0" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Distribution" /v "Background Only" /t REG_SZ /d "True" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Distribution" /v "Clock Rate" /t REG_DWORD /d "10000" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Distribution" /v "GPU Priority" /t REG_DWORD /d "8" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Distribution" /v "Priority" /t REG_DWORD /d "4" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Distribution" /v "Scheduling Category" /t REG_SZ /d "Medium" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Distribution" /v "SFIO Priority" /t REG_SZ /d "Normal" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Playback" /v "Affinity" /t REG_DWORD /d "0" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Playback" /v "Background Only" /t REG_SZ /d "False" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Playback" /v "BackgroundPriority" /t REG_DWORD /d "4" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Playback" /v "Clock Rate" /t REG_DWORD /d "10000" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Playback" /v "GPU Priority" /t REG_DWORD /d "8" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Playback" /v "Priority" /t REG_DWORD /d "3" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Playback" /v "Scheduling Category" /t REG_SZ /d "Medium" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Playback" /v "SFIO Priority" /t REG_SZ /d "Normal" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Pro Audio" /v "Affinity" /t REG_DWORD /d "0" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Pro Audio" /v "Background Only" /t REG_SZ /d "False" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Pro Audio" /v "Clock Rate" /t REG_DWORD /d "10000" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Pro Audio" /v "GPU Priority" /t REG_DWORD /d "8" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Pro Audio" /v "Priority" /t REG_DWORD /d "1" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Pro Audio" /v "Scheduling Category" /t REG_SZ /d "High" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Pro Audio" /v "SFIO Priority" /t REG_SZ /d "Normal" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Window Manager" /v "Affinity" /t REG_DWORD /d "0" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Window Manager" /v "Background Only" /t REG_SZ /d "True" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Window Manager" /v "Clock Rate" /t REG_DWORD /d "10000" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Window Manager" /v "GPU Priority" /t REG_DWORD /d "8" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Window Manager" /v "Priority" /t REG_DWORD /d "5" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Window Manager" /v "Scheduling Category" /t REG_SZ /d "Medium" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Window Manager" /v "SFIO Priority" /t REG_SZ /d "Normal" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching" /v "SearchOrderConfig" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v "HiberbootEnabled" /t REG_DWORD /d "0" /f
reg add "HKCU\System\GameConfigStore" /v "Win32_AutoGameModeDefaultProfile" /t REG_BINARY /d "01000100000000000000000000000000000000000000000000000000000000000000000000000000" /f
reg add "HKCU\System\GameConfigStore" /v "Win32_GameModeRelatedProcesses" /t REG_BINARY /d "010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" /f
reg add "HKCU\System\GameConfigStore" /v "GameDVR_HonorUserFSEBehaviorMode" /t REG_DWORD /d "0" /f
reg add "HKCU\System\GameConfigStore" /v "GameDVR_DXGIHonorFSEWindowsCompatible" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\943c8cb6-6f93-4227-ad87-e9a3feec08d1" /v "Attributes" /t REG_DWORD /d "2" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\2a737441-1930-4402-8d77-b2bebba308a3\d4e98f31-5ffe-4ce1-be31-1b38b384c009\DefaultPowerSchemeValues\381b4222-f694-41f0-9685-ff5bb260df2e" /v "ACSettingIndex" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\2a737441-1930-4402-8d77-b2bebba308a3\d4e98f31-5ffe-4ce1-be31-1b38b384c009\DefaultPowerSchemeValues\381b4222-f694-41f0-9685-ff5bb260df2e" /v "DCSettingIndex" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\2a737441-1930-4402-8d77-b2bebba308a3\d4e98f31-5ffe-4ce1-be31-1b38b384c009\DefaultPowerSchemeValues\8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c" /v "ACSettingIndex" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\3b04d4fd-1cc7-4f23-ab1c-d1337819c4bb\DefaultPowerSchemeValues\381b4222-f694-41f0-9685-ff5bb260df2e" /v "ACSettingIndex" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\3b04d4fd-1cc7-4f23-ab1c-d1337819c4bb\DefaultPowerSchemeValues\381b4222-f694-41f0-9685-ff5bb260df2e" /v "DCSettingIndex" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\3b04d4fd-1cc7-4f23-ab1c-d1337819c4bb\DefaultPowerSchemeValues\8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c" /v "ACSettingIndex" /t REG_DWORD /d "0" /f

:: Memory Managment Tweaks
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettingsOverride" /t REG_DWORD /d "3" /f 
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettingsOverrideMask" /t REG_DWORD /d "3" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "ClearPageFileAtShutdown" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "DisablePagingExecutive" /t REG_DWORD /d "1" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "LargeSystemCache" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "NonPagedPoolQuota" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "NonPagedPoolSize" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "PagedPoolQuota" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "PagedPoolSize" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "PagingFiles" /t REG_MULTI_SZ /d "c:\pagefile.sys 8000 8000" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "SecondLevelDataCache" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "SessionPoolSize" /t REG_DWORD /d "48" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "SessionViewSize" /t REG_DWORD /d "96" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "SystemPages" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "PhysicalAddressExtension" /t REG_DWORD /d "1" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettings" /t REG_DWORD /d "1" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "EnableCfg" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettingsOverride" /t REG_DWORD /d "3" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettingsOverrideMask" /t REG_DWORD /d "3" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "DisablePageCombining" /t REG_DWORD /d "1" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "MoveImages" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "IoPageLockLimit" /t REG_DWORD /d "134217728" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "PagefileUsage" /t REG_BINARY /d "0400000051270000d0340000276a0000b65700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "ExistingPageFiles" /t REG_MULTI_SZ /d "\??\C:\pagefile.sys" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "ClearPageFileAtShutdown" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "DisablePagingExecutive" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "NonPagedPoolQuota" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "NonPagedPoolSize" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "PagedPoolQuota" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "PagedPoolSize" /t REG_DWORD /d "192" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "SecondLevelDataCache" /t REG_DWORD /d "1024" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "SessionPoolSize" /t REG_DWORD /d "192" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "SessionViewSize" /t REG_DWORD /d "192" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "SystemPages" /t REG_DWORD /d "4294967295" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "PhysicalAddressExtension" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettings" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettingsOverride" /t REG_DWORD /d "3" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettingsOverrideMask" /t REG_DWORD /d "3" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "IoPageLockLimit" /t REG_DWORD /d "16710656" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "PoolUsageMaximum" /t REG_DWORD /d "96" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "Start" /t REG_DWORD /d "4" /f

reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\StoreParameters" /f

:: Set SvcSplitThreshold (revision)
for /f "skip=1" %%i in ('wmic os get TotalVisibleMemorySize') do if not defined TOTAL_MEMORY set "TOTAL_MEMORY=%%i" & set /a SVCHOST=%%i+1024000
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control" /v "SvcHostSplitThresholdInKB" /t REG_DWORD /d "!SVCHOST!" /f 
echo SvcSplitThreshold


:: Disable Prefetch
Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnablePrefetcher" /t REG_DWORD /d "0" /f 
Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnableSuperfetch" /t REG_DWORD /d "0" /f 
Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnableBoottrace" /t REG_DWORD /d "0" /f 
Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "BootId" /t REG_DWORD /d "92" /f
Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "BaseTime" /t REG_DWORD /d "672778600" /f
Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "SfTracingState" /t REG_DWORD /d "0" /f
echo Disable Prefetch

:: Background Apps
Reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v "GlobalUserDisabled" /t REG_DWORD /d "1" /f 
Reg add "HKLM\Software\Policies\Microsoft\Windows\AppPrivacy" /v "LetAppsRunInBackground" /t REG_DWORD /d "2" /f 
Reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "BackgroundAppGlobalToggle" /t REG_DWORD /d "0" /f 
echo Disable Background Apps

:: Free unused ram
Reg add "HKLM\System\CurrentControlSet\Control\Session Manager" /v "HeapDeCommitFreeBlockThreshold" /t REG_DWORD /d "262144" /f 
Reg.exe add "HKLM\SOFTWARE\Microsoft\DirectX" /v "MemoryAllocationPolicy" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\DirectX" /v "VramManagement" /t REG_DWORD /d "1" /f
Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "MemoryPriority" /t REG_DWORD /d "4" /f
echo Free unused ram

goto Menu

:clean
chcp 65001 >nul 2>&1
cls
echo.
echo.
echo.
echo. %C%╔══════════════════════════════════════════════════════════════════════════════════════════════════════════╗
echo. %C%║%O%                      ██████╗██╗     ███████╗ █████╗ ███╗   ██╗██╗   ██╗██████╗                           %C%║
echo. %C%║%O%                     ██╔════╝██║     ██╔════╝██╔══██╗████╗  ██║██║   ██║██╔══██╗                          %C%║
echo. %C%║%O%                     ██║     ██║     █████╗  ███████║██╔██╗ ██║██║   ██║██████╔╝                          %C%║
echo. %C%║%O%                     ██║     ██║     ██╔══╝  ██╔══██║██║╚██╗██║██║   ██║██╔═══╝                           %C%║
echo. %C%║%O%                     ╚██████╗███████╗███████╗██║  ██║██║ ╚████║╚██████╔╝██║                               %C%║
echo. %C%║%O%                      ╚═════╝╚══════╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚═╝                               %C%║ 
echo. %C%╠══════════════════════════════════════════════════════════════════════════════════════════════════════════╣
echo. %C%║%W%                                                                                                          %C%║
echo. %C%║%R%           [1]%W% Temp File CleanUp                          %R%[2]%W% Device Cleanup                              %C%║
echo. %C%║%W%                                                                                                          %C%║
echo. %C%║%R%           [3]%W% Debloat Apps                               %R%[4]%W% Remove One Drive                            %C%║
echo. %C%║%W%                                                                                                          %C%║
echo. %C%╠══════════════════════════════════════════════════════════════════════════════════════════════════════════╣
echo. %C%║%W%                                                                                                          %C%║
echo. %C%║%W%                                             %R%[B] Back                                                     %C%║
echo. %C%║%W%                                                                                                          %C%║
echo. %C%╚══════════════════════════════════════════════════════════════════════════════════════════════════════════╝

set /p input=:
if /i %input% == 1 Goto C1
if /i %input% == 2 Goto C2
if /i %input% == 3 Goto C3
if /i %input% == 4 Goto C4
if /i %input% == B goto General
goto General

:C1
:: Clean Temporary files
del /s /f /q %systemdrive%\*.tmp 
del /s /f /q %systemdrive%\*._mp 
del /s /f /q %systemdrive%\*.log 
del /s /f /q %systemdrive%\*.gid 
del /s /f /q %systemdrive%\*.chk 
del /s /f /q %systemdrive%\*.old 
del /s /f /q %systemdrive%\recycled\*.* 
del /s /f /q %systemdrive%\$Recycle.Bin\*.* 
del /s /f /q %windir%\*.bak 
del /s /f /q %windir%\prefetch\*.* 
del /s /f /q %LocalAppData%\Microsoft\Windows\Explorer\thumbcache_*.db 
del /s /f /q %LocalAppData%\Microsoft\Windows\Explorer\*.db 
del /f /q %SystemRoot%\Logs\CBS\CBS.log 
del /f /q %SystemRoot%\Logs\DISM\DISM.log 
del /s /f /q "%SystemDrive%\windows\history\*"
del /s /f /q "%SystemDrive%\windows\recent\*"
del /s /f /q "%SystemDrive%\windows\spool\printers\*" 
del /s /f /q "%SystemDrive%\Windows\Prefetch\*"
del /s /f /q c:\windows\temp\*.*
rd /s /q c:\windows\temp
md c:\windows\temp
del /s /f /q %temp%\*.*
rd /s /q %temp%
md %temp%
del /s /f /q c:\windows\tempor~1
del /s /f /q c:\windows\temp
del /s /f /q %userprofile%\Recent\*.*
del /s /f /q %USERPROFILE%\appdata\local\temp\*.*
del /Q C:\Users\%username%\AppData\Local\Microsoft\Windows\INetCache\IE\*.*
del /Q C:\Windows\Downloaded Program Files\*.*
del /Q C:\Users\%username%\AppData\Local\Temp\*.*
del /s /f /q %SystemRoot%\setupapi.log
del /s /f /q %SystemRoot%\Panther\*
del /s /f /q %SystemRoot%\inf\setupapi.app.log
del /s /f /q %SystemRoot%\inf\setupapi.dev.log
del /s /f /q %SystemRoot%\inf\setupapi.offline.log

::Delete reg files
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Applets\Regedit" /va /f
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Applets\Regedit" /va /f
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Applets\Regedit\Favorites" /va /f
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Applets\Regedit\Favorites" /va /f
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\ComDlg32\LastVisitedPidlMRU" /va /f
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\ComDlg32\LastVisitedPidlMRULegacy" /va /f
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Applets\Paint\Recent File List" /va /f
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Applets\Paint\Recent File List" /va /f
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Applets\Wordpad\Recent File List" /va /f
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Map Network Drive MRU" /va /f
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Map Network Drive MRU" /va /f
reg delete "HKCU\Software\Microsoft\Search Assistant\ACMru" /va /f
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\RecentDocs" /va /f
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\RecentDocs" /va /f
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\ComDlg32\OpenSaveMRU" /va /f
reg delete "HKCU\Software\Microsoft\MediaPlayer\Player\RecentFileList" /va /f
reg delete "HKCU\Software\Microsoft\MediaPlayer\Player\RecentURLList" /va /f
reg delete "HKLM\SOFTWARE\Microsoft\MediaPlayer\Player\RecentFileList" /va /f
reg delete "HKLM\SOFTWARE\Microsoft\MediaPlayer\Player\RecentURLList" /va /f
reg delete "HKCU\SOFTWARE\Microsoft\Direct3D\MostRecentApplication" /va /f
reg delete "HKLM\SOFTWARE\Microsoft\Direct3D\MostRecentApplication" /va /f
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\RunMRU" /va /f
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\TypedPaths" /va /f
goto Clean

:C2

powershell -Command "& {Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.MessageBox]::Show('After You close This down Device Cleanup.exe Will Open Just Click CLTR+A And Then Click Delete after that just close down the program', 'Ra1ner Tweaking Utility', 'Ok', [System.Windows.Forms.MessageBoxIcon]::Information);}"
C:\Ra1nerFree\DeviceCleanup.exe

goto Clean

:C3
echo [-] Removing Unnecessary Powershell Packages/Microsoft Apps
powershell.exe "Get-AppxPackage *Microsoft.3DBuilder* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *Microsoft.Appconnector* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *Microsoft.BingFinance* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *Microsoft.BingNews* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *Microsoft.BingSports* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *Microsoft.BingTranslator* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *Microsoft.BingWeather* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *Microsoft.FreshPaint* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *Microsoft.Getstarted* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *Microsoft.GetHelp* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *Microsoft.Messaging* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *Microsoft.Microsoft3DViewer* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *Microsoft.MicrosoftOfficeHub* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *Microsoft.MicrosoftPowerBIForWindows* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *Microsoft.MicrosoftSolitaireCollection* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *Microsoft.MicrosoftStickyNotes* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *Microsoft.MinecraftUWP* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *Microsoft.NetworkSpeedTest* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *Microsoft.WindowsPhone* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *Microsoft.CommsPhone* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *Microsoft.ConnectivityStore* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *Microsoft.Office.Sway* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *Microsoft.BingFoodAndDrink* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *Microsoft.BingTravel* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *Microsoft.BingHealthAndFitness* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *9E2F88E3.Twitter* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *PandoraMediaInc.29680B314EFC2* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *Flipboard.Flipboard* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *ShazamEntertainmentLtd.Shazam* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *king.com.CandyCrushSaga* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *king.com.CandyCrushSodaSaga* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *king.com.* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *ClearChannelRadioDigital.iHeartRadio* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *4DF9E0F8.Netflix* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *6Wunderkinder.Wunderlist* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *Drawboard.DrawboardPDF* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *22StokedOnIt.NotebookPro* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *2FE3CB00.PicsArt-PhotoStudio* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *41038Axilesoft.ACGMediaPlayer* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *5CB722CC.SeekersNotesMysteriesofDarkwood* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *7458BE2C.WorldofTanksBlitz* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *D52A8D61.FarmVille2CountryEscape | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *TuneIn.TuneInRadio* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *GAMELOFTSA.Asphalt8Airborne* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *TheNewYorkTimes.NYTCrossword* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *DB6EA5DB.CyberLinkMediaSuiteEssentials* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *Facebook.Facebook* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *flaregamesGmbH.RoyalRevolt2* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *Playtika.CaesarsSlotsFreeCasino* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *A278AB0D.MarchofEmpires* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *KeeperSecurityInc.Keeper* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *ThumbmunkeysLtd.PhototasticCollage* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *INGAG.XING* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *89006A2E.AutodeskSketchBook* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *D5EA27B7.Duolingo-LearnLanguagesforFree* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *46928bounde.EclipseManager* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *ActiproSoftwareLLC.562882FEEB49* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *DolbyLaboratories.DolbyAccess* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *A278AB0D.DisneyMagicKingdoms* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *WinZipComputing.WinZipUniversal* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *Microsoft.MSPaint* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *Microsoft.Office.OneNote* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *Microsoft.OneConnect* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *Microsoft.People* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *Microsoft.Print3D* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *Microsoft.SkypeApp* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *Microsoft.Wallet* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *Microsoft.WindowsAlarms* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *Microsoft.WindowsCamera* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *Microsoft.windowscommunicationsapps* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *Microsoft.WindowsFeedbackHub* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *Microsoft.WindowsMaps* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *Microsoft.WindowsSoundRecorder* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *Microsoft.XboxApp* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *Microsoft.Xbox.TCUI* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *Microsoft.ZuneMusic* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *Microsoft.ZuneVideo* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *828B5831.HiddenCityMysteryofShadows* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *king.com.BubbleWitch3Saga* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *Fitbit.FitbitCoach* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *Facebook.InstagramBeta* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *Facebook.317180B0BB486* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *Expedia.ExpediaHotelsFlightsCarsActivities* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *CAF9E577.Plex* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *AdobeSystemsIncorporated.PhotoshopElements2018* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *A278AB0D.DragonManiaLegends* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *A278AB0D.AsphaltStreetStormRacing* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *828B5831.TheSecretSociety-HiddenMystery* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *USATODAY.USATODAY* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *SiliconBendersLLC.Sketchable* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *Nordcurrent.CookingFever* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *NAVER.LINEwin8* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *microsoft.microsoftskydrive* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *Microsoft.AgeCastles* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *Microsoft.ScreenSketch* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *Microsoft.YourPhone* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *Microsoft.WebMediaExtensions* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *Microsoft.MixedReality.Portal* | Remove-AppxPackage"

:: Remove potential bloat for new users
powershell.exe "Get-AppxProvisionedPackage -Online | where Displayname -EQ *Microsoft.3DBuilder* | Remove-AppxProvisionedPackage -Online"
powershell.exe "Get-AppxProvisionedPackage -Online | where Displayname -EQ *Microsoft.Appconnector* | Remove-AppxProvisionedPackage -Online"
powershell.exe "Get-AppxProvisionedPackage -Online | where Displayname -EQ *Microsoft.BingFinance* | Remove-AppxProvisionedPackage -Online"
powershell.exe "Get-AppxProvisionedPackage -Online | where Displayname -EQ *Microsoft.BingNews* | Remove-AppxProvisionedPackage -Online"
powershell.exe "Get-AppxProvisionedPackage -Online | where Displayname -EQ *Microsoft.BingSports* | Remove-AppxProvisionedPackage -Online"
powershell.exe "Get-AppxProvisionedPackage -Online | where Displayname -EQ *Microsoft.BingTranslator* | Remove-AppxProvisionedPackage -Online"
powershell.exe "Get-AppxProvisionedPackage -Online | where Displayname -EQ *Microsoft.BingWeather* | Remove-AppxProvisionedPackage -Online"
powershell.exe "Get-AppxProvisionedPackage -Online | where Displayname -EQ *Microsoft.FreshPaint* | Remove-AppxProvisionedPackage -Online"
powershell.exe "Get-AppxProvisionedPackage -Online | where Displayname -EQ *Microsoft.Getstarted* | Remove-AppxProvisionedPackage -Online"
powershell.exe "Get-AppxProvisionedPackage -Online | where Displayname -EQ *Microsoft.GetHelp* | Remove-AppxProvisionedPackage -Online"
powershell.exe "Get-AppxProvisionedPackage -Online | where Displayname -EQ *Microsoft.Messaging* | Remove-AppxProvisionedPackage -Online"
powershell.exe "Get-AppxProvisionedPackage -Online | where Displayname -EQ *Microsoft.Microsoft3DViewer* | Remove-AppxProvisionedPackage -Online"
powershell.exe "Get-AppxProvisionedPackage -Online | where Displayname -EQ *Microsoft.MicrosoftOfficeHub* | Remove-AppxProvisionedPackage -Online"
powershell.exe "Get-AppxProvisionedPackage -Online | where Displayname -EQ *Microsoft.MicrosoftPowerBIForWindows* | Remove-AppxProvisionedPackage -Online"
powershell.exe "Get-AppxProvisionedPackage -Online | where Displayname -EQ *Microsoft.MicrosoftSolitaireCollection* | Remove-AppxProvisionedPackage -Online"
powershell.exe "Get-AppxProvisionedPackage -Online | where Displayname -EQ *Microsoft.MicrosoftStickyNotes* | Remove-AppxProvisionedPackage -Online"
powershell.exe "Get-AppxProvisionedPackage -Online | where Displayname -EQ *Microsoft.MinecraftUWP* | Remove-AppxProvisionedPackage -Online"
powershell.exe "Get-AppxProvisionedPackage -Online | where Displayname -EQ *Microsoft.NetworkSpeedTest* | Remove-AppxProvisionedPackage -Online"
powershell.exe "Get-AppxProvisionedPackage -Online | where Displayname -EQ *Microsoft.WindowsPhone* | Remove-AppxProvisionedPackage -Online"
powershell.exe "Get-AppxProvisionedPackage -Online | where Displayname -EQ *Microsoft.CommsPhone* | Remove-AppxProvisionedPackage -Online"
powershell.exe "Get-AppxProvisionedPackage -Online | where Displayname -EQ *Microsoft.ConnectivityStore* | Remove-AppxProvisionedPackage -Online"
powershell.exe "Get-AppxProvisionedPackage -Online | where Displayname -EQ *Microsoft.Office.Sway* | Remove-AppxProvisionedPackage -Online"
powershell.exe "Get-AppxProvisionedPackage -Online | where Displayname -EQ *Microsoft.BingFoodAndDrink* | Remove-AppxProvisionedPackage -Online"
powershell.exe "Get-AppxProvisionedPackage -Online | where Displayname -EQ *Microsoft.BingTravel* | Remove-AppxProvisionedPackage -Online"
powershell.exe "Get-AppxProvisionedPackage -Online | where Displayname -EQ *Microsoft.BingHealthAndFitness* | Remove-AppxProvisionedPackage -Online"
powershell.exe "Get-AppxProvisionedPackage -Online | where Displayname -EQ *9E2F88E3.Twitter* | Remove-AppxProvisionedPackage -Online"
powershell.exe "Get-AppxProvisionedPackage -Online | where Displayname -EQ *PandoraMediaInc.29680B314EFC2* | Remove-AppxProvisionedPackage -Online"
powershell.exe "Get-AppxProvisionedPackage -Online | where Displayname -EQ *Flipboard.Flipboard* | Remove-AppxProvisionedPackage -Online"
powershell.exe "Get-AppxProvisionedPackage -Online | where Displayname -EQ *king.com.CandyCrushSaga* | Remove-AppxProvisionedPackage -Online"
powershell.exe "Get-AppxProvisionedPackage -Online | where Displayname -EQ *king.com.CandyCrushSodaSaga* | Remove-AppxProvisionedPackage -Online"
powershell.exe "Get-AppxProvisionedPackage -Online | where Displayname -EQ *king.com.* | Remove-AppxProvisionedPackage -Online"
powershell.exe "Get-AppxProvisionedPackage -Online | where Displayname -EQ *ClearChannelRadioDigital.iHeartRadio* | Remove-AppxProvisionedPackage -Online"
powershell.exe "Get-AppxProvisionedPackage -Online | where Displayname -EQ *4DF9E0F8.Netflix* | Remove-AppxProvisionedPackage -Online"
powershell.exe "Get-AppxProvisionedPackage -Online | where Displayname -EQ *6Wunderkinder.Wunderlist* | Remove-AppxProvisionedPackage -Online"
powershell.exe "Get-AppxProvisionedPackage -Online | where Displayname -EQ *Drawboard.DrawboardPDF* | Remove-AppxProvisionedPackage -Online"
powershell.exe "Get-AppxProvisionedPackage -Online | where Displayname -EQ *22StokedOnIt.NotebookPro* | Remove-AppxProvisionedPackage -Online"
powershell.exe "Get-AppxProvisionedPackage -Online | where Displayname -EQ *2FE3CB00.PicsArt-PhotoStudio* | Remove-AppxProvisionedPackage -Online"
powershell.exe "Get-AppxProvisionedPackage -Online | where Displayname -EQ *41038Axilesoft.ACGMediaPlayer* | Remove-AppxProvisionedPackage -Online"
powershell.exe "Get-AppxProvisionedPackage -Online | where Displayname -EQ *5CB722CC.SeekersNotesMysteriesofDarkwood* | Remove-AppxProvisionedPackage -Online"
powershell.exe "Get-AppxProvisionedPackage -Online | where Displayname -EQ *7458BE2C.WorldofTanksBlitz* | Remove-AppxProvisionedPackage -Online"
powershell.exe "Get-AppxProvisionedPackage -Online | where Displayname -EQ *D52A8D61.FarmVille2CountryEscape | Remove-AppxProvisionedPackage -Online"
powershell.exe "Get-AppxProvisionedPackage -Online | where Displayname -EQ *TuneIn.TuneInRadio* | Remove-AppxProvisionedPackage -Online"
powershell.exe "Get-AppxProvisionedPackage -Online | where Displayname -EQ *GAMELOFTSA.Asphalt8Airborne* | Remove-AppxProvisionedPackage -Online"
powershell.exe "Get-AppxProvisionedPackage -Online | where Displayname -EQ *TheNewYorkTimes.NYTCrossword* | Remove-AppxProvisionedPackage -Online"
powershell.exe "Get-AppxProvisionedPackage -Online | where Displayname -EQ *DB6EA5DB.CyberLinkMediaSuiteEssentials* | Remove-AppxProvisionedPackage -Online"
powershell.exe "Get-AppxProvisionedPackage -Online | where Displayname -EQ *flaregamesGmbH.RoyalRevolt2* | Remove-AppxProvisionedPackage -Online"
powershell.exe "Get-AppxProvisionedPackage -Online | where Displayname -EQ *Playtika.CaesarsSlotsFreeCasino* | Remove-AppxProvisionedPackage -Online"
powershell.exe "Get-AppxProvisionedPackage -Online | where Displayname -EQ *A278AB0D.MarchofEmpires* | Remove-AppxProvisionedPackage -Online"
powershell.exe "Get-AppxProvisionedPackage -Online | where Displayname -EQ *KeeperSecurityInc.Keeper* | Remove-AppxProvisionedPackage -Online"
powershell.exe "Get-AppxProvisionedPackage -Online | where Displayname -EQ *ThumbmunkeysLtd.PhototasticCollage* | Remove-AppxProvisionedPackage -Online"
powershell.exe "Get-AppxProvisionedPackage -Online | where Displayname -EQ *INGAG.XING* | Remove-AppxProvisionedPackage -Online"
powershell.exe "Get-AppxProvisionedPackage -Online | where Displayname -EQ *89006A2E.AutodeskSketchBook* | Remove-AppxProvisionedPackage -Online"
powershell.exe "Get-AppxProvisionedPackage -Online | where Displayname -EQ *D5EA27B7.Duolingo-LearnLanguagesforFree* | Remove-AppxProvisionedPackage -Online"
powershell.exe "Get-AppxProvisionedPackage -Online | where Displayname -EQ *46928bounde.EclipseManager* | Remove-AppxProvisionedPackage -Online"
powershell.exe "Get-AppxProvisionedPackage -Online | where Displayname -EQ *ActiproSoftwareLLC.562882FEEB49* | Remove-AppxProvisionedPackage -Online"
powershell.exe "Get-AppxProvisionedPackage -Online | where Displayname -EQ *DolbyLaboratories.DolbyAccess* | Remove-AppxProvisionedPackage -Online"
powershell.exe "Get-AppxProvisionedPackage -Online | where Displayname -EQ *A278AB0D.DisneyMagicKingdoms* | Remove-AppxProvisionedPackage -Online"
powershell.exe "Get-AppxProvisionedPackage -Online | where Displayname -EQ *WinZipComputing.WinZipUniversal* | Remove-AppxProvisionedPackage -Online"
powershell.exe "Get-AppxProvisionedPackage -Online | where Displayname -EQ *Microsoft.MSPaint* | Remove-AppxProvisionedPackage -Online"
powershell.exe "Get-AppxProvisionedPackage -Online | where Displayname -EQ *Microsoft.Office.OneNote* | Remove-AppxProvisionedPackage -Online"
powershell.exe "Get-AppxProvisionedPackage -Online | where Displayname -EQ *Microsoft.OneConnect* | Remove-AppxProvisionedPackage -Online"
powershell.exe "Get-AppxProvisionedPackage -Online | where Displayname -EQ *Microsoft.People* | Remove-AppxProvisionedPackage -Online"
powershell.exe "Get-AppxProvisionedPackage -Online | where Displayname -EQ *Microsoft.Print3D* | Remove-AppxProvisionedPackage -Online"
powershell.exe "Get-AppxProvisionedPackage -Online | where Displayname -EQ *Microsoft.SkypeApp* | Remove-AppxProvisionedPackage -Online"
powershell.exe "Get-AppxProvisionedPackage -Online | where Displayname -EQ *Microsoft.Wallet* | Remove-AppxProvisionedPackage -Online"
powershell.exe "Get-AppxProvisionedPackage -Online | where Displayname -EQ *Microsoft.WindowsAlarms* | Remove-AppxProvisionedPackage -Online"
powershell.exe "Get-AppxProvisionedPackage -Online | where Displayname -EQ *Microsoft.WindowsCamera* | Remove-AppxProvisionedPackage -Online"
powershell.exe "Get-AppxProvisionedPackage -Online | where Displayname -EQ *Microsoft.windowscommunicationsapps* | Remove-AppxProvisionedPackage -Online"
powershell.exe "Get-AppxProvisionedPackage -Online | where Displayname -EQ *Microsoft.WindowsFeedbackHub* | Remove-AppxProvisionedPackage -Online"
powershell.exe "Get-AppxProvisionedPackage -Online | where Displayname -EQ *Microsoft.WindowsMaps* | Remove-AppxProvisionedPackage -Online"
powershell.exe "Get-AppxProvisionedPackage -Online | where Displayname -EQ *Microsoft.WindowsSoundRecorder* | Remove-AppxProvisionedPackage -Online"
powershell.exe "Get-AppxProvisionedPackage -Online | where Displayname -EQ *Microsoft.XboxApp* | Remove-AppxProvisionedPackage -Online"
powershell.exe "Get-AppxProvisionedPackage -Online | where Displayname -EQ *Microsoft.Xbox.TCUI* | Remove-AppxProvisionedPackage -Online"
powershell.exe "Get-AppxProvisionedPackage -Online | where Displayname -EQ *Microsoft.ZuneMusic* | Remove-AppxProvisionedPackage -Online"
powershell.exe "Get-AppxProvisionedPackage -Online | where Displayname -EQ *Microsoft.ZuneVideo* | Remove-AppxProvisionedPackage -Online"
powershell.exe "Get-AppxProvisionedPackage -Online | where Displayname -EQ *828B5831.HiddenCityMysteryofShadows* | Remove-AppxProvisionedPackage -Online"
powershell.exe "Get-AppxProvisionedPackage -Online | where Displayname -EQ *king.com.BubbleWitch3Saga* | Remove-AppxProvisionedPackage -Online"
powershell.exe "Get-AppxProvisionedPackage -Online | where Displayname -EQ *Fitbit.FitbitCoach* | Remove-AppxProvisionedPackage -Online"
powershell.exe "Get-AppxProvisionedPackage -Online | where Displayname -EQ *Facebook.InstagramBeta* | Remove-AppxProvisionedPackage -Online"
powershell.exe "Get-AppxProvisionedPackage -Online | where Displayname -EQ *Facebook.317180B0BB486* | Remove-AppxProvisionedPackage -Online"
powershell.exe "Get-AppxProvisionedPackage -Online | where Displayname -EQ *Expedia.ExpediaHotelsFlightsCarsActivities* | Remove-AppxProvisionedPackage -Online"
powershell.exe "Get-AppxProvisionedPackage -Online | where Displayname -EQ *CAF9E577.Plex* | Remove-AppxProvisionedPackage -Online"
powershell.exe "Get-AppxProvisionedPackage -Online | where Displayname -EQ *AdobeSystemsIncorporated.PhotoshopElements2018* | Remove-AppxProvisionedPackage -Online"
powershell.exe "Get-AppxProvisionedPackage -Online | where Displayname -EQ *A278AB0D.DragonManiaLegends* | Remove-AppxProvisionedPackage -Online"
powershell.exe "Get-AppxProvisionedPackage -Online | where Displayname -EQ *A278AB0D.AsphaltStreetStormRacing* | Remove-AppxProvisionedPackage -Online"
powershell.exe "Get-AppxProvisionedPackage -Online | where Displayname -EQ *828B5831.TheSecretSociety-HiddenMystery* | Remove-AppxProvisionedPackage -Online"
powershell.exe "Get-AppxProvisionedPackage -Online | where Displayname -EQ *USATODAY.USATODAY* | Remove-AppxProvisionedPackage -Online"
powershell.exe "Get-AppxProvisionedPackage -Online | where Displayname -EQ *SiliconBendersLLC.Sketchable* | Remove-AppxProvisionedPackage -Online"
powershell.exe "Get-AppxProvisionedPackage -Online | where Displayname -EQ *Nordcurrent.CookingFever* | Remove-AppxProvisionedPackage -Online"
powershell.exe "Get-AppxProvisionedPackage -Online | where Displayname -EQ *NAVER.LINEwin8* | Remove-AppxProvisionedPackage -Online"
powershell.exe "Get-AppxProvisionedPackage -Online | where Displayname -EQ *microsoft.microsoftskydrive* | Remove-AppxProvisionedPackage -Online"
powershell.exe "Get-AppxProvisionedPackage -Online | where Displayname -EQ *Microsoft.AgeCastles* | Remove-AppxProvisionedPackage -Online"
powershell.exe "Get-AppxProvisionedPackage -Online | where Displayname -EQ *Microsoft.ScreenSketch* | Remove-AppxProvisionedPackage -Online"
powershell.exe "Get-AppxProvisionedPackage -Online | where Displayname -EQ *Microsoft.YourPhone* | Remove-AppxProvisionedPackage -Online"
powershell.exe "Get-AppxProvisionedPackage -Online | where Displayname -EQ *Microsoft.WebMediaExtensions* | Remove-AppxProvisionedPackage -Online"
powershell.exe "Get-AppxProvisionedPackage -Online | where Displayname -EQ *Microsoft.MixedReality.Portal* | Remove-AppxProvisionedPackage -Online"

goto Clean
:C4
taskkill /f /im OneDrive.exe >nul
%SystemRoot%\SysWOW64\OneDriveSetup.exe /uninstall
%SystemRoot%\System32\OneDriveSetup.exe /uninstall

goto Clean

:KBM
echo [-] Disabling Toggle Keys
Reg.exe add "HKCU\Control Panel\Accessibility\ToggleKeys" /v "Flags" /t REG_SZ /d "58" /f
echo.

echo [-] Disabling Sticky Keys
Reg.exe add "HKCU\Control Panel\Accessibility\StickyKeys" /v "Flags" /t REG_SZ /d "26" /f
echo.

echo [-] Disabling Mouse Keys
Reg.exe add "HKCU\Control Panel\Accessibility\MouseKeys" /v "Flags" /t REG_SZ /d "0" /f
echo.

echo [-] Disabling Mouse Acceleration
Reg.exe add "HKCU\Control Panel\Mouse" /v "MouseSpeed" /t REG_SZ /d "0" /f
Reg.exe add "HKCU\Control Panel\Mouse" /v "MouseThreshold1" /t REG_SZ /d "0" /f
Reg.exe add "HKCU\Control Panel\Mouse" /v "MouseThreshold2" /t REG_SZ /d "0" /f
echo.

echo [-] Enabling 1:1 Pixel Mouse Movements
Reg.exe add "HKCU\Control Panel\Mouse" /v "MouseSensitivity" /t REG_SZ /d "10" /f
echo.

echo [-] Reducing Keyboard Repeat Delay
Reg.exe add "HKCU\Control Panel\Keyboard" /v "KeyboardDelay" /t REG_SZ /d "0" /f
echo.

echo [-] Increasing Keyboard Repeat Rate
Reg.exe add "HKCU\Control Panel\Keyboard" /v "KeyboardSpeed" /t REG_SZ /d "31" /f
echo.
echo. [-] Show text suggestions when typing on the physical keyboard (Privacy)
reg add "HKCU\Software\Microsoft\Input\Settings" /v "EnableHwkbTextPrediction" /t REG_DWORD /d "0" /f
echo.
echo. [-] Typing insights (Privacy)
reg add "HKCU\Software\Microsoft\Input\Settings" /v "InsightsEnabled" /t REG_DWORD /d "0" /f
echo.
echo. [-] Multilingual text suggestions (Privacy)
reg add "HKCU\Software\Microsoft\Input\Settings" /v "MultilingualEnabled" /t REG_DWORD /d "0" /f
echo.
echo. [-] Autocorrect misspelled words (Privacy)
reg add "HKCU\Software\Microsoft\TabletTip\1.7" /v "EnableAutocorrection" /t REG_DWORD /d "0" /f
echo.
echo. [-] Highlight misspelled words (Privacy)
reg add "HKCU\Software\Microsoft\TabletTip\1.7" /v "EnableSpellchecking" /t REG_DWORD /d "0" /f

echo. [-] Inking & Typing Personalization (Privacy)
reg add "HKCU\Software\Microsoft\InputPersonalization" /v "RestrictImplicitInkCollection" /t REG_DWORD /d "1" /f
reg add "HKCU\Software\Microsoft\InputPersonalization" /v "RestrictImplicitTextCollection " /t REG_DWORD /d "1" /f
reg add "HKCU\Software\Microsoft\InputPersonalization\TrainedDataStore" /v "HarvestContacts " /t REG_DWORD /d "0" /f
reg add "HKCU\Software\Microsoft\Personalization\Settings" /v "AcceptedPrivacyPolicy  " /t REG_DWORD /d "0" /f

reg add "HKCU\Software\Microsoft\Input" /v "IsInputAppPreloadEnabled" /t REG_DWORD /d "0" /f
reg add "HKCU\Software\Microsoft\Input\Settings" /v "VoiceTypingEnabled" /t REG_DWORD /d "0" /f
reg add "HKCU\Software\Microsoft\Input\TIPC" /v "Enabled" /t REG_DWORD /d "0" /f

echo [-] Setting CSRSS to Realtime
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\csrss.exe\PerfOptions" /v "CpuPriorityClass" /t REG_DWORD /d "4" /f 
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\csrss.exe\PerfOptions" /v "IoPriority" /t REG_DWORD /d "3" /f  
timeout /t 1 /nobreak > NUL

echo [-] Keyboard Tweaks
Reg.exe add "HKCU\Control Panel\Accessibility\Keyboard Response" /v "Flags" /t REG_DWORD /d "0" /f
Reg.exe add "HKCU\Control Panel\Keyboard" /v "InitialKeyboardIndicators" /t REG_SZ /d "0" /f
Reg.exe add "HKCU\Control Panel\Accessibility\Keyboard Response" /v "DelayBeforeAcceptance" /t REG_SZ /d "0" /f

Reg.exe add "HKCU\Control Panel\Accessibility\Keyboard Response" /v "Last BounceKey Setting" /t REG_DWORD /d "0" /f
Reg.exe add "HKCU\Control Panel\Accessibility\Keyboard Response" /v "Last Valid Delay" /t REG_DWORD /d "0" /f
Reg.exe add "HKCU\Control Panel\Accessibility\Keyboard Response" /v "Last Valid Repeat" /t REG_DWORD /d "0" /f
Reg.exe add "HKCU\Control Panel\Accessibility\Keyboard Response" /v "Last Valid Wait" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters" /v "ThreadPriority" /t REG_DWORD /d "31" /f

echo [-] extra Mouse Tweaks
Reg.exe add "HKU\.DEFAULT\Control Panel\Mouse" /v "MouseHoverTime" /t REG_SZ /d "0" /f
Reg.exe add "HKU\.DEFAULT\Control Panel\Mouse" /v "MouseSpeed" /t REG_SZ /d "0" /f
Reg.exe add "HKCU\Control Panel\Accessibility\MouseKeys" /v "Flags" /t REG_SZ /d "186" /f
Reg.exe add "HKCU\Control Panel\Accessibility\MouseKeys" /v "MaximumSpeed" /t REG_SZ /d "40" /f
Reg.exe add "HKCU\Control Panel\Accessibility\MouseKeys" /v "TimeToMaximumSpeed" /t REG_SZ /d "3000" /f

echo [-] Mouse Pointers Scheme None
Reg.exe add "HKCU\Control Panel\Cursors" /v "AppStarting" /t REG_EXPAND_SZ /d "" /f
Reg.exe add "HKCU\Control Panel\Cursors" /v "Arrow" /t REG_EXPAND_SZ /d "" /f
Reg.exe add "HKCU\Control Panel\Cursors" /v "ContactVisualization" /t REG_DWORD /d "1" /f
Reg.exe add "HKCU\Control Panel\Cursors" /v "Crosshair" /t REG_EXPAND_SZ /d "" /f
Reg.exe add "HKCU\Control Panel\Cursors" /v "GestureVisualization" /t REG_DWORD /d "31" /f
Reg.exe add "HKCU\Control Panel\Cursors" /v "Hand" /t REG_EXPAND_SZ /d "" /f
Reg.exe add "HKCU\Control Panel\Cursors" /v "Help" /t REG_EXPAND_SZ /d "" /f
Reg.exe add "HKCU\Control Panel\Cursors" /v "IBeam" /t REG_EXPAND_SZ /d "" /f
Reg.exe add "HKCU\Control Panel\Cursors" /v "No" /t REG_EXPAND_SZ /d "" /f
Reg.exe add "HKCU\Control Panel\Cursors" /v "NWPen" /t REG_EXPAND_SZ /d "" /f
Reg.exe add "HKCU\Control Panel\Cursors" /v "Scheme Source" /t REG_DWORD /d "0" /f
Reg.exe add "HKCU\Control Panel\Cursors" /v "SizeAll" /t REG_EXPAND_SZ /d "" /f
Reg.exe add "HKCU\Control Panel\Cursors" /v "SizeNESW" /t REG_EXPAND_SZ /d "" /f
Reg.exe add "HKCU\Control Panel\Cursors" /v "SizeNS" /t REG_EXPAND_SZ /d "" /f
Reg.exe add "HKCU\Control Panel\Cursors" /v "SizeNWSE" /t REG_EXPAND_SZ /d "" /f
Reg.exe add "HKCU\Control Panel\Cursors" /v "SizeWE" /t REG_EXPAND_SZ /d "" /f
Reg.exe add "HKCU\Control Panel\Cursors" /v "UpArrow" /t REG_EXPAND_SZ /d "" /f
Reg.exe add "HKCU\Control Panel\Cursors" /v "Wait" /t REG_EXPAND_SZ /d "" /f
Reg.exe add "HKCU\Control Panel\Cursors" /ve /t REG_SZ /d "" /f

cls
echo.%W% ██╗  ██╗██████╗ ███╗   ███╗
echo.%W% ██║ ██╔╝██╔══██╗████╗ ████║
echo.%W% █████═╝ ██████╦╝██╔████╔██║
echo.%W% ██╔═██╗ ██╔══██╗██║╚██╔╝██║
echo.%W% ██║ ╚██╗██████╦╝██║ ╚═╝ ██║
echo.%W% ╚═╝  ╚═╝╚═════╝ ╚═╝     ╚═╝
echo.%C%╔══════════════════════════════════════════════════════════════════════════════════════════════╗
echo.%C%║                      %w% Low mouse data queue size lowers input delay,                          %C%║
echo.%C%║                  %w% but it may cause mouse and keyboard lag on low end CPUs                    %C%║        
echo.%C%║                                                                                              %C%║
echo.%C%║           %R%[1]%w% High End CPU        %R%[2]%w% Mid end CPU          %R%[3]%w% Low end CPU                   %C%║
echo.%C%║                                                                                              %C%║
echo.%C%╚══════════════════════════════════════════════════════════════════════════════════════════════╝

set /p input=:
if /i %input% == 1 Goto High
if /i %input% == 2 Goto Mid
if /i %input% == 3 Goto Low

:High
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\mouclass\Parameters" /v "MouseDataQueueSize" /t REG_DWORD /d "18" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters" /v "KeyboardDataQueueSize" /t REG_DWORD /d "18" /f
goto Menu

:Mid
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\mouclass\Parameters" /v "MouseDataQueueSize" /t REG_DWORD /d "25" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters" /v "KeyboardDataQueueSize" /t REG_DWORD /d "25" /f
goto Menu

:low
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\mouclass\Parameters" /v "MouseDataQueueSize" /t REG_DWORD /d "35" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters" /v "KeyboardDataQueueSize" /t REG_DWORD /d "35" /f
goto Menu


:Power
echo [+] My Power plan
powercfg -import "C:\Ra1nerFree\Ra1ners_Performance_plan.pow" 11111111-1111-1111-1111-111111111191
echo.
powercfg -changename 11111111-1111-1111-1111-111111111191 "Ra1ners Ultimate Performance" "The Best Powerplan For Performance"
echo.
echo [+] Power plan active
powercfg -SETACTIVE "11111111-1111-1111-1111-111111111191"
echo.
echo.[-] Disabling GPU Energy Driver
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\GpuEnergyDrv" /v "Start" /t REG_DWORD /d "4" /f 
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\GpuEnergyDr" /v "Start" /t REG_DWORD /d "4" /f 
timeout /t 1 /nobreak > NUL
echo.
echo [-] Disabling Energy Logging
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power\EnergyEstimation\TaggedEnergy" /v "DisableTaggedEnergyLogging" /t REG_DWORD /d "1" /f 
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power\EnergyEstimation\TaggedEnergy" /v "TelemetryMaxApplication" /t REG_DWORD /d "0" /f 
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power\EnergyEstimation\TaggedEnergy" /v "TelemetryMaxTagPerApplication" /t REG_DWORD /d "0" /f 
timeout /t 1 /nobreak > NUL
echo.
echo [-] Disabling Fast Startup
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v "HiberbootEnabled" /t REG_DWORD /d "0" /f 
timeout /t 1 /nobreak > NUL
echo.
echo [-] Disabling Hibernation
powercfg /h off
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "HibernateEnabled" /t REG_DWORD /d "0" /f 
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "SleepReliabilityDetailedDiagnostics" /t REG_DWORD /d "0" /f 
timeout /t 1 /nobreak > NUL
echo.
echo [-] Disabling Sleep Study
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v "SleepStudyDisabled" /t REG_DWORD /d "1" /f 
timeout /t 1 /nobreak > NUL
echo.
:: Disable C-States
powercfg -setacvalueindex scheme_current SUB_SLEEP AWAYMODE 0
powercfg /setactive SCHEME_CURRENT
powercfg -setacvalueindex scheme_current SUB_SLEEP ALLOWSTANDBY 0
powercfg /setactive SCHEME_CURRENT
powercfg -setacvalueindex scheme_current SUB_SLEEP HYBRIDSLEEP 0
powercfg /setactive SCHEME_CURRENT
powercfg -setacvalueindex scheme_current sub_processor PROCTHROTTLEMIN 100
powercfg /setactive SCHEME_CURRENT
echo Disable C-States
echo.
echo [-] Disable Throttle States
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\0cc5b647-c1df-4637-891a-dec35c318583" /v "ValueMin" /t REG_DWORD /d "0" /f

echo [-] Disabling CoalescingTimerInterval
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager" /v "CoalescingTimerInterval" /t REG_DWORD /d "0" /f 
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v "CoalescingTimerInterval" /t REG_DWORD /d "0" /f 
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "CoalescingTimerInterval" /t REG_DWORD /d "0" /f 
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v "CoalescingTimerInterval" /t REG_DWORD /d "0" /f 
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Executive" /v "CoalescingTimerInterval" /t REG_DWORD /d "0" /f 
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power\ModernSleep" /v "CoalescingTimerInterval" /t REG_DWORD /d "0" /f 
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "CoalescingTimerInterval" /t REG_DWORD /d "0" /f 
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "PlatformAoAcOverride" /t REG_DWORD /d "0" /f 
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "EnergyEstimationEnabled" /t REG_DWORD /d "0" /f 
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "EventProcessorEnabled" /t REG_DWORD /d "0" /f 
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "CsEnabled" /t REG_DWORD /d "0" /f 
echo
echo [-] Disabling Power Throttling
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" /v "PowerThrottlingOff" /t REG_DWORD /d "1" /f 
timeout /t 1 /nobreak > NUL
echo
echo [-] balanced
powercfg -delete 381b4222-f694-41f0-9685-ff5bb260df2e
echo
echo [-] high performance
powercfg -delete 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
echo
echo [-] power saver
powercfg -delete a1841308-3541-4fab-bc81-f71556f20b4a
echo
echo [-] hibernate
powercfg -h off
echo
echo check power plan
echo

goto menu

:GPU

cls
echo.%C%╔══════════════════════════════════════════════════════════════════════════════════════════════╗
echo.%C%║                      %w% Low mouse data queue size lowers input delay,                          %C%║
echo.%C%║                     %w% but it may cause mouse and kb lag on low end CPUs                       %C%║        
echo.%C%║                                                                                              %C%║
echo.%C%║           %R%[1]%w% NVIDIA Geforce     %R%[2]%w% AMD Radeon           %R%[3]%w% Intel IGPU                     %C%║
echo.%C%║                                                                                              %C%║
echo.%C%╚══════════════════════════════════════════════════════════════════════════════════════════════╝

set /p input=:
if /i %input% == 1 Goto Nvidia
if /i %input% == 2 Goto AMD
if /i %input% == 3 Goto Intel

:Nvidia
cls
echo. %C%╔══════════════════════════════════════════════════════════════════════════════════════════════════════════╗
echo. %C%║%W%                             ███╗   ██╗██╗   ██╗██╗██████╗ ██╗ █████╗                                     %C%║
echo. %C%║%W%                             ████╗  ██║██║   ██║██║██╔══██╗██║██╔══██╗                                    %C%║
echo. %C%║%W%                             ██╔██╗ ██║██║   ██║██║██║  ██║██║███████║                                    %C%║
echo. %C%║%W%                             ██║╚██╗██║╚██╗ ██╔╝██║██║  ██║██║██╔══██║                                    %C%║
echo. %C%║%W%                             ██║ ╚████║ ╚████╔╝ ██║██████╔╝██║██║  ██║                                    %C%║
echo. %C%║%W%                             ╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═════╝ ╚═╝╚═╝  ╚═╝                                    %C%║  
echo. %C%╠══════════════════════════════════════════════════════════════════════════════════════════════════════════╣
echo. %C%║%W%                                                                                                          %C%║
echo. %C%║%R%           [1]%W% NVIDIA GENERAL TWEAKS                      %R%[2]%W% CONTROL PANEL SETTINGS                      %C%║
echo. %C%║%W%                                                                                                          %C%║
echo. %C%║%R%           [3]%W% DISABLE NVIDIA HDCP                        %R%[4]%W% DISABLE NVIDIA TELEMENTRY                   %C%║
echo. %C%║%W%                                                                                                          %C%║
echo. %C%║%R%           [5]%W% DOWNLOAD NVIDIA DRIVER                     %R%[6]%W% HIDDEN NVIDIA TWEAKS                        %C%║
echo. %C%║%W%                                                                                                          %C%║
echo. %C%╠══════════════════════════════════════════════════════════════════════════════════════════════════════════╣
echo. %C%║%W%                                                                                                          %C%║
echo. %C%║%W%                                          %R%[X] Menu                                                        %C%║
echo. %C%║%W%                                                                                                          %C%║
echo. %C%║%W%                     %R%[B]%w% CHOOSE THE WRONG GPU GO BACK AND CHOOSE ANOTHER                                  %C%║
echo. %C%║%W%                                                                                                          %C%║
echo. %C%╚══════════════════════════════════════════════════════════════════════════════════════════════════════════╝

set /p input=:
if /i %input% == 1 Goto NVIDIA1
if /i %input% == 2 Goto NVIDIA2
if /i %input% == 3 Goto NVIDIA3
if /i %input% == 4 Goto NVIDIA4
if /i %input% == 5 Goto NVIDIA5
if /i %input% == 6 Goto NVIDIA6
if /i %input% == X goto Menu
if /i %input% == B goto GPU
goto GPU

:NVIDIA1
echo %C% [-] Enabling MSI Mode%G%
for /f %%g in ('wmic path win32_videocontroller get PNPDeviceID ^| findstr /L "VEN_"') do (
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Enum\%%g\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties" /v "MSISupported" /t REG_DWORD /d "1" /f  
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Enum\%%g\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePriority" /t REG_DWORD /d "0" /f 
)

echo %W% [-] Setting NVIDIA Latency Tolerance%C%
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "D3PCLatency" /t REG_DWORD /d "1" /f 
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "F1TransitionLatency" /t REG_DWORD /d "1" /f 
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "LOWLATENCY" /t REG_DWORD /d "1" /f 
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "Node3DLowLatency" /t REG_DWORD /d "1" /f 
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "PciLatencyTimerControl" /t REG_DWORD /d "20" /f 
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "RMDeepL1EntryLatencyUsec" /t REG_DWORD /d "1" /f 
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "RmGspcMaxFtuS" /t REG_DWORD /d "1" /f 
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "RmGspcMinFtuS" /t REG_DWORD /d "1" /f 
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "RmGspcPerioduS" /t REG_DWORD /d "1" /f 
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "RMLpwrEiIdleThresholdUs" /t REG_DWORD /d "1" /f 
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "RMLpwrGrIdleThresholdUs" /t REG_DWORD /d "1" /f 
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "RMLpwrGrRgIdleThresholdUs" /t REG_DWORD /d "1" /f 
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "RMLpwrMsIdleThresholdUs" /t REG_DWORD /d "1" /f 
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "VRDirectFlipDPCDelayUs" /t REG_DWORD /d "1" /f 
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "VRDirectFlipTimingMarginUs" /t REG_DWORD /d "1" /f 
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "VRDirectJITFlipMsHybridFlipDelayUs" /t REG_DWORD /d "1" /f 
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "vrrCursorMarginUs" /t REG_DWORD /d "1" /f 
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "vrrDeflickerMarginUs" /t REG_DWORD /d "1" /f 
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "vrrDeflickerMaxUs" /t REG_DWORD /d "1" /f 

echo %W% [-] Disabling Write Combining%C%
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "DisableWriteCombining" /t REG_DWORD /d "1" /f 

echo %W% [-] Disabling Preemption%C%
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "DisablePreemption" /t REG_DWORD /d "1" /f 
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "DisableCudaContextPreemption" /t REG_DWORD /d "1" /f 
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "EnableCEPreemption" /t REG_DWORD /d "0" /f 
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "DisablePreemptionOnS3S4" /t REG_DWORD /d "1" /f 
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "ComputePreemption" /t REG_DWORD /d "0" /f 
Goto Nvidia
:NVIDIA2
start "" /wait "C:\Ra1nerFree\nvidiaProfileInspector.exe" "C:\Ra1nerFree\Ra1ners_Nvidia_Improvement.nip"
Goto Nvidia
:NVIDIA3
reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "RMHdcpKeyglobZero" /t REG_DWORD /d "00000001" /f

Goto Nvidia
:NVIDIA4
echo %C% [-] Disabling NVIDIA Telemetry%G%
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "NvBackend" /f 
Reg.exe add "HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS" /v "EnableRID66610" /t REG_DWORD /d "0" /f 
Reg.exe add "HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS" /v "EnableRID64640" /t REG_DWORD /d "0" /f 
Reg.exe add "HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS" /v "EnableRID44231" /t REG_DWORD /d "0" /f 
schtasks /change /disable /tn "NvTmRep_CrashReport1_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}" 
schtasks /change /disable /tn "NvTmRep_CrashReport2_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}" 
schtasks /change /disable /tn "NvTmRep_CrashReport3_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}" 
schtasks /change /disable /tn "NvTmRep_CrashReport4_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}" 
schtasks /change /disable /tn "NvDriverUpdateCheckDaily_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}" 
schtasks /change /disable /tn "NVIDIA GeForce Experience SelfUpdate_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}" 
schtasks /change /disable /tn "NvTmMon_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}" 


Goto Nvidia
:NVIDIA5
start https://youtu.be/Ss6sIkhCuK8
c:\Ra1nerFree\NVCleanstall_1.16.0.exe

Goto Nvidia
:NVIDIA6

Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "ExitLatency" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "ExitLatencyCheckEnabled" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "Latency" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "LatencyToleranceDefault" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "LatencyToleranceFSVP" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "LatencyTolerancePerfOverride" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "LatencyToleranceScreenOffIR" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "LatencyToleranceVSyncEnabled" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "RtlCapabilityCheckLatency" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "QosManagesIdleProcessors" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "DisableVsyncLatencyUpdate" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "DisableSensorWatchdog" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "CoalescingTimerInterval" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "InterruptSteeringDisabled" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "LowLatencyScalingPercentage" /t REG_DWORD /d "100" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "HighPerformance" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "HighestPerformance" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "MinimumThrottlePercent" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "MaximumThrottlePercent" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "MaximumPerformancePercent" /t REG_DWORD /d "100" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "InitialUnparkCount" /t REG_DWORD /d "100" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "DefaultD3TransitionLatencyActivelyUsed" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "DefaultD3TransitionLatencyIdleLongTime" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "DefaultD3TransitionLatencyIdleMonitorOff" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "DefaultD3TransitionLatencyIdleNoContext" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "DefaultD3TransitionLatencyIdleShortTime" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "DefaultD3TransitionLatencyIdleVeryLongTime" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "DefaultLatencyToleranceIdle0" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "DefaultLatencyToleranceIdle0MonitorOff" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "DefaultLatencyToleranceIdle1" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "DefaultLatencyToleranceIdle1MonitorOff" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "DefaultLatencyToleranceMemory" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "DefaultLatencyToleranceNoContext" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "DefaultLatencyToleranceNoContextMonitorOff" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "DefaultLatencyToleranceOther" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "DefaultLatencyToleranceTimerPeriod" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "DefaultMemoryRefreshLatencyToleranceActivelyUsed" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "DefaultMemoryRefreshLatencyToleranceMonitorOff" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "DefaultMemoryRefreshLatencyToleranceNoContext" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "Latency" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "MaxIAverageGraphicsLatencyInOneBucket" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "MiracastPerfTrackGraphicsLatency" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "MonitorLatencyTolerance" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "MonitorRefreshLatencyTolerance" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "TransitionLatency" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "EnablePreemption" /t REG_DWORD /d "0" /f

Reg.exe add "HKLM\SYSTEM\ControlSet001\Services\nvlddmkm" /v "EnableMidGfxPreemption" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\ControlSet001\Services\nvlddmkm" /v "EnableMidGfxPreemptionVGPU" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\ControlSet001\Services\nvlddmkm" /v "EnableMidBufferPreemptionForHighTdrTimeout" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\ControlSet001\Services\nvlddmkm" /v "EnableMidBufferPreemption" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\ControlSet001\Services\nvlddmkm" /v "ComputePreemption" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\ControlSet001\Services\nvlddmkm" /v "DisablePreemption" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\ControlSet001\Services\nvlddmkm" /v "EnableMidBufferPreemptionForHighTdrTimeout" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\CurrentControlSet\Control\GraphicsDrivers\Scheduler" /f /v "EnablePreemption" /t REG_DWORD /d "0"
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Scheduler" /v "EnablePreemption" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Scheduler" /v "EnablePreemption" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Scheduler" /v "PlatformSupportMiracast" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "DisablePreemption" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Scheduler" /v "EnablePreemption" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "EnablePreemption" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Power" /v "EnablePreemption" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "EnablePreemption" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Power" /v "DisableCudaContextPreemption" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Power" /v "DisablePreemptionOnS3S4" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Power" /v "ComputePreemption" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Power" /v "EnableMidGfxPreemptionVGPU" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Power" /v "EnableMidBufferPreemptionForHighTdrTimeout" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Power" /v "EnableAsyncMidBufferPreemption" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Power" /v "EnableSCGMidBufferPreemption" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Power" /v "PerfAnalyzeMidBufferPreemption" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Power" /v "EnableMidGfxPreemption" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Power" /v "EnableMidBufferPreemption" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Scheduler" /v "EnablePreemption" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Power" /v "EnableCEPreemption" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "GPUPreemptionLevel" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "ComputePreemption" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "EnableMidGfxPreemptionVGPU" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "EnableMidBufferPreemptionForHighTdrTimeout" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "EnableAsyncMidBufferPreemption" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "EnableSCGMidBufferPreemption" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "PerfAnalyzeMidBufferPreemption" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "EnableMidGfxPreemption" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "EnableMidBufferPreemption" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "EnableCEPreemption" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "DisableCudaContextPreemption" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "DisablePreemptionOnS3S4" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Power" /v "GPUPreemptionLevel" /t REG_DWORD /d "0" /f

Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "GPUPreemptionLevel" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "ComputePreemption" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "EnableMidGfxPreemptionVGPU" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "EnableMidBufferPreemptionForHighTdrTimeout" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "EnableAsyncMidBufferPreemption" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "EnableSCGMidBufferPreemption" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "PerfAnalyzeMidBufferPreemption" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "EnableMidGfxPreemption" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "EnableMidBufferPreemption" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "EnableCEPreemption" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "DisableCudaContextPreemption" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "DisablePreemptionOnS3S4" /t REG_DWORD /d "1" /f

Goto Nvidia
:AMD
echo %C% [-]  Enabling MSI Mode %G%
for /f %%g in ('wmic path win32_videocontroller get PNPDeviceID ^| findstr /L "VEN_"') do (
reg add "HKLM\SYSTEM\CurrentControlSet\Enum\%%g\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties" /v "MSISupported" /t REG_DWORD /d "1" /f  
reg add "HKLM\SYSTEM\CurrentControlSet\Enum\%%g\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePriority" /t REG_DWORD /d "0" /f 
)
timeout /t 1 /nobreak > NUL


echo %C% [-] Disabling Display Refresh Rate Override%G%
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "3D_Refresh_Rate_Override_DEF" /t REG_DWORD /d "0" /f 
timeout /t 1 /nobreak > NUL


echo %C%[-]Disabling SnapShot%G%
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "AllowSnapshot" /t REG_DWORD /d "0" /f 
timeout /t 1 /nobreak > NUL

echo %C%[-]Disabling Anti Aliasing%G%
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "AAF_NA" /t REG_DWORD /d "0" /f 
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "AntiAlias_NA" /t REG_SZ /d "0" /f 
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "ASTT_NA" /t REG_SZ /d "0" /f 
timeout /t 1 /nobreak > NUL

echo %C%[-]Disabling Subscriptions%G%
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "AllowSubscription" /t REG_DWORD /d "0" /f 
timeout /t 1 /nobreak > NUL

echo %C%[-]Disabling Anisotropic Filtering%G%
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "AreaAniso_NA" /t REG_SZ /d "0" /f 
timeout /t 1 /nobreak > NUL


echo %C%[-]Disabling Radeon Overlay%G%
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "AllowRSOverlay" /t REG_SZ /d "false" /f  
timeout /t 1 /nobreak > NUL

echo Enabling Adaptive DeInterlacing%G%
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "Adaptive De-interlacing" /t REG_DWORD /d "1" /f 
timeout /t 1 /nobreak > NUL


echo %C%[-]Disabling Skins%G%
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "AllowSkins" /t REG_SZ /d "false" /f  
timeout /t 1 /nobreak > NUL

echo %C%[-]Disabling Automatic Color Depth Reduction%G%
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "AutoColorDepthReduction_NA" /t REG_DWORD /d "0" /f 
timeout /t 1 /nobreak > NUL


echo %C%[-]Disabling Power Gating%G%
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "DisableSAMUPowerGating" /t REG_DWORD /d "1" /f 
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "DisableUVDPowerGatingDynamic" /t REG_DWORD /d "1" /f 
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "DisableVCEPowerGating" /t REG_DWORD /d "1" /f 
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "DisablePowerGating" /t REG_DWORD /d "1" /f 
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "DisableDrmdmaPowerGating" /t REG_DWORD /d "1" /f 
timeout /t 1 /nobreak > NUL


echo %C%[-]Disabling Clock Gating%G%
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "EnableVceSwClockGating" /t REG_DWORD /d "1" /f 
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "EnableUvdClockGating" /t REG_DWORD /d "1" /f 
timeout /t 1 /nobreak > NUL

echo %C%[-]Disabling Active State Power Management%G%
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "EnableAspmL0s" /t REG_DWORD /d "0" /f 
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "EnableAspmL1" /t REG_DWORD /d "0" /f 
timeout /t 1 /nobreak > NUL


echo %C%[-]Disabling Ultra Low Power States%G%
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "EnableUlps" /t REG_DWORD /d "0" /f 
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "EnableUlps_NA" /t REG_SZ /d "0" /f 
timeout /t 1 /nobreak > NUL


echo %C%[-]Enabling De-Lag%G%
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "KMD_DeLagEnabled" /t REG_DWORD /d "1" /f 
timeout /t 1 /nobreak > NUL

echo %C%[-]Disabling Frame Rate Target%G%
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "KMD_FRTEnabled" /t REG_DWORD /d "0" /f 
timeout /t 1 /nobreak > NUL

echo %C%[-]Disabling DMA%G%
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "DisableDMACopy" /t REG_DWORD /d "1" /f 
timeout /t 1 /nobreak > NUL

echo %C%[-]Enable BlockWrite%G%
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "DisableBlockWrite" /t REG_DWORD /d "0" /f 
timeout /t 1 /nobreak > NUL

echo %C%[-]Disabling Stutter Mode%G%
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "StutterMode" /t REG_DWORD /d "0" /f 
timeout /t 1 /nobreak > NUL

echo %C%[-]Disabling GPU Memory Clock Sleep State%G%
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "PP_SclkDeepSleepDisable" /t REG_DWORD /d "1" /f 
timeout /t 1 /nobreak > NUL

echo %C%[-]Disabling Thermal Throttling%G%
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "PP_ThermalAutoThrottlingEnable" /t REG_DWORD /d "0" /f 
timeout /t 1 /nobreak > NUL

echo %C%[-]Disabling Preemption%G%
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "KMD_EnableComputePreemption" /t REG_DWORD /d "0" /f 
timeout /t 1 /nobreak > NUL

echo %C%[-]Setting Main3D%G%
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000\UMD" /v "Main3D_DEF" /t REG_SZ /d "1" /f 
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000\UMD" /v "Main3D" /t REG_BINARY /d "3100" /f 
timeout /t 1 /nobreak > NUL

echo %C%[-]Setting FlipQueueSize%G%
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000\UMD" /v "FlipQueueSize" /t REG_BINARY /d "3100" /f 
timeout /t 1 /nobreak > NUL

echo %C%[-]Setting Shader Cache Size%G%
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000\UMD" /v "ShaderCache" /t REG_BINARY /d "3200" /f 
timeout /t 1 /nobreak > NUL

echo %C%[-]Configuring TFQ%G%
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000\UMD" /v "TFQ" /t REG_BINARY /d "3200" /f 
timeout /t 1 /nobreak > NUL

echo %C%[-]Disabling High-Bandwidth Digital Content Protection%G%
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000\\DAL2_DATA__2_0\DisplayPath_4\EDID_D109_78E9\Option" /v "ProtectionControl" /t REG_BINARY /d "0100000001000000" /f 
timeout /t 1 /nobreak > NUL

echo %C%[-]Disabling GPU Power Down%G%
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "PP_GPUPowerDownEnabled" /t REG_DWORD /d "1" /f 
timeout /t 1 /nobreak > NUL

echo %C%[-]Disabling AMD Logging%G%
reg add "HKLM\SYSTEM\CurrentControlSet\Services\amdlog" /v "Start" /t REG_DWORD /d "4" /f 
timeout /t 1 /nobreak > NUL
Goto menu

:Intel
:: Set the REGPATH_INTEL variable
set REGPATH_INTEL=HKLM\SOFTWARE\Intel

:: Disable Overlay Display Surface Quality Enhancement
reg add "!REGPATH_INTEL!" /v "Disable_OverlayDSQualityEnhancement" /t REG_DWORD /d "1" /f

:: Increase Fixed Segment
reg add "!REGPATH_INTEL!" /v "IncreaseFixedSegment" /t REG_DWORD /d "1" /f

:: Disable Adaptive Vsync
reg add "!REGPATH_INTEL!" /v "AdaptiveVsyncEnable" /t REG_DWORD /d "0" /f

:: Disable Panel Self Refresh (PF) on DisplayPort (DP)
reg add "!REGPATH_INTEL!" /v "DisablePFonDP" /t REG_DWORD /d "1" /f

:: Enable Compensation for Digital Visual Interface (DVI)
reg add "!REGPATH_INTEL!" /v "EnableCompensationForDVI" /t REG_DWORD /d "1" /f

:: No Fast Link Training for eDP (Embedded DisplayPort)
reg add "!REGPATH_INTEL!" /v "NoFastLinkTrainingForeDP" /t REG_DWORD /d "0" /f

:: Allow Deep C States
reg add "!REGPATH_INTEL!" /v "AllowDeepCStates" /t REG_DWORD /d "0" /f

:: Set A/C Power Policy Version
reg add "!REGPATH_INTEL!" /v "ACPowerPolicyVersion" /t REG_DWORD /d "16898" /f

:: Set DC Power Policy Version
reg add "!REGPATH_INTEL!" /v "DCPowerPolicyVersion" /t REG_DWORD /d "16642" /f

Goto menu
 
:CPU
:: Set Win32PrioritySeparation 26 hex/38 dec
Reg add "HKLM\System\CurrentControlSet\Control\PriorityControl" /v "Win32PrioritySeparation" /t REG_DWORD /d "38" /f
echo Win32PrioritySeparation

:: Reliable Timestamp
Reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Reliability" /v "TimeStampInterval" /t REG_DWORD /d "1" /f
Reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Reliability" /v "IoPriority" /t REG_DWORD /d "3" /f
echo Timestamp Interval

:: CPU
Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v "DistributeTimers" /t REG_DWORD /d "1" /f

:: Enable All Logical Cores
bcdedit /set {current} numproc %THREADS%
echo Enable All Logical Cores

:: Fix CPU Stock Speed
Reg add "HKLM\SYSTEM\CurrentControlSet\Services\IntelPPM" /v Start /t REG_DWORD /d 3 /f
Reg add "HKLM\SYSTEM\CurrentControlSet\Services\AmdPPM" /v Start /t REG_DWORD /d 3 /f
echo Fix CPU Stock Speed

:: Disable Power Throttling
Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v "CoalescingTimerInterval" /t REG_DWORD /d "0" /f
Reg add "HKLM\System\CurrentControlSet\Control\Power" /v "EnergyEstimationEnabled" /t REG_DWORD /d "0" /f
Reg add "HKLM\System\CurrentControlSet\Control\Power" /v "EventProcessorEnabled" /t REG_DWORD /d "0" /f
Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" /v "PowerThrottlingOff" /t REG_DWORD /d "1" /f
echo Disable Power Throttling

:: Disable Hibernation
powercfg /h off
echo Disable Hibernation

:: Device Idle Policy: Performance
powercfg -setacvalueindex scheme_current sub_none DEVICEIDLE 0
:: Require a password on wakeup: OFF
powercfg -setacvalueindex scheme_current sub_none CONSOLELOCK 0

:: USB 3 Link Power Management: OFF 
powercfg -setacvalueindex scheme_current 2a737441-1930-4402-8d77-b2bebba308a3 d4e98f31-5ffe-4ce1-be31-1b38b384c009 0
:: USB selective suspend setting: OFF
powercfg -setacvalueindex scheme_current 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0
:: Link State Power Management: OFF
powercfg -setacvalueindex scheme_current SUB_PCIEXPRESS ASPM 0
:: AHCI Link Power Management - HIPM/DIPM: OFF
powercfg -setacvalueindex scheme_current SUB_DISK 0b2d69d7-a2a1-449c-9680-f91c70521c60 0

:: NVMe Power State Transition Latency Tolerance
powercfg -setacvalueindex scheme_current SUB_DISK dbc9e238-6de9-49e3-92cd-8c2b4946b472 1
powercfg -setacvalueindex scheme_current SUB_DISK fc95af4d-40e7-4b6d-835a-56d131dbc80e 1

:: Interrupt Steering
echo %PROCESSOR_IDENTIFIER% | find "Intel" >nul && (
powercfg -setacvalueindex scheme_current SUB_INTSTEER MODE 6
echo Interrupt Steering
)

:: Use Higher P-States on Lower C-States And Viseversa
powercfg -setacvalueindex scheme_current sub_processor IDLESCALING 1
echo Configure C-States

:: Enable Hardware P-states
powercfg -setacvalueindex scheme_current sub_processor PERFAUTONOMOUS 1
powercfg -setacvalueindex scheme_current sub_processor PERFAUTONOMOUSWINDOW 20000
powercfg -setacvalueindex scheme_current sub_processor PERFCHECK 20
:: Dont restrict core boost
powercfg -setacvalueindex scheme_current sub_processor PERFEPP 0
:: Enable Turbo Boost
powercfg -setacvalueindex scheme_current sub_processor PERFBOOSTMODE 1
powercfg -setacvalueindex scheme_current sub_processor PERFBOOSTPOL 100
echo Enable Hardware P-States

:: Disable C-States
powercfg -setacvalueindex scheme_current SUB_SLEEP AWAYMODE 0
powercfg /setactive SCHEME_CURRENT
powercfg -setacvalueindex scheme_current SUB_SLEEP ALLOWSTANDBY 0
powercfg /setactive SCHEME_CURRENT
powercfg -setacvalueindex scheme_current SUB_SLEEP HYBRIDSLEEP 0
powercfg /setactive SCHEME_CURRENT
powercfg -setacvalueindex scheme_current sub_processor PROCTHROTTLEMIN 100
powercfg /setactive SCHEME_CURRENT
echo Disable C-States
)

:: CPU Cooling Tweaks
powercfg /setACvalueindex scheme_current SUB_PROCESSOR SYSCOOLPOL 1
powercfg /setDCvalueindex scheme_current SUB_PROCESSOR SYSCOOLPOL 1
powercfg /setactive SCHEME_CURRENT

:: Disable Core Parking
echo %PROCESSOR_IDENTIFIER% | find "Intel" >nul && (
powercfg -setacvalueindex scheme_current sub_processor CPMINCORES 100
) || (
powercfg -setacvalueindex scheme_current SUB_INTSTEER UNPARKTIME 1
powercfg -setacvalueindex scheme_current SUB_INTSTEER PERPROCLOAD 10000
)
echo Disable Core Parking
)

goto menu

:Net
cls
echo. %C%╔══════════════════════════════════════════════════════════════════════════════════════════════════════════╗
echo. %C%║%W%                   ███╗   ██╗███████╗████████╗██╗    ██╗ ██████╗ ██████╗ ██╗  ██╗                         %C%║
echo. %C%║%W%                   ████╗  ██║██╔════╝╚══██╔══╝██║    ██║██╔═══██╗██╔══██╗██║ ██╔╝                         %C%║
echo. %C%║%W%                   ██╔██╗ ██║█████╗     ██║   ██║ █╗ ██║██║   ██║██████╔╝█████╔╝                          %C%║
echo. %C%║%W%                   ██║╚██╗██║██╔══╝     ██║   ██║███╗██║██║   ██║██╔══██╗██╔═██╗                          %C%║ 
echo. %C%║%W%                   ██║ ╚████║███████╗   ██║   ╚███╔███╔╝╚██████╔╝██║  ██║██║  ██╗                         %C%║
echo. %C%║%W%                   ╚═╝  ╚═══╝╚══════╝   ╚═╝    ╚══╝╚══╝  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝                         %C%║
echo. %C%╠══════════════════════════════════════════════════════════════════════════════════════════════════════════╣
echo. %C%║%W%                                                                                                          %C%║
echo. %C%║%R%           [1]%W% Optimize DNS Server                        %R%[2]%W% Optimize general Network settings           %C%║
echo. %C%║%W%                                                                                                          %C%║
echo. %C%║%R%           [3]%W% Optimize network TCP Settings              %R%[4]%W% Network priority                            %C%║
echo. %C%║%W%                                                                                                          %C%║
echo. %C%║%R%           [5]%W% Optimize Network Adapter settings          %R%[6]%W% Update Network drivers                      %C%║
echo. %C%║%W%                                                                                                          %C%║
echo. %C%║%R%           [7]%W% Advanced Tweaks                            %R%[8]%W% Disable Nagiles Algorithm                   %C%║
echo. %C%║%W%                                                                                                          %C%║
echo. %C%╠══════════════════════════════════════════════════════════════════════════════════════════════════════════╣
echo. %C%║%W%                                                                                                          %C%║
echo. %C%║%W%                                          %R%[B] Menu                                                        %C%║
echo. %C%║%W%                                                                                                          %C%║
echo. %C%╚══════════════════════════════════════════════════════════════════════════════════════════════════════════╝

set /p input=:
if /i %input% == 1 goto Net1
if /i %input% == 2 goto Net2
if /i %input% == 3 goto Net3
if /i %input% == 4 goto Net4
if /i %input% == 5 goto Net5
if /i %input% == 6 goto Net6
if /i %input% == 7 goto Net7
if /i %input% == 8 goto Net8
if /i %input% == B goto Menu
goto Menu

:net1
powershell -Command "& {Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.MessageBox]::Show('Choose [fastest DNS] then start DNS test and click apply after Software to do this opens after you click ok', 'Ra1ner Tweaking Utility', 'Ok', [System.Windows.Forms.MessageBoxIcon]::Information);}"
"C:\Ra1nerFree\DnsJumper.exe"
goto :Net

:Net2
::Internet Refresher
ipconfig /all
ipconfig /flushdns
ipconfig /release
ipconfig /renew

::Upload and download optimizations
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\AFD\Parameters" /v "DefaultReceiveWindow" /t REG_DWORD /d "16384" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\AFD\Parameters" /v "DefaultSendWindow" /t REG_DWORD /d "16384" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\AFD\Parameters" /v "FastCopyReceiveThreshold" /t REG_DWORD /d "16384" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\AFD\Parameters" /v "FastSendDatagramThreshold" /t REG_DWORD /d "16384" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\AFD\Parameters" /v "DynamicSendBufferDisable" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\AFD\Parameters" /v "IgnorePushBitOnReceives" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\AFD\Parameters" /v "NonBlockingSendSpecialBuffering" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\AFD\Parameters" /v "DisableRawSecurity" /t REG_DWORD /d "1" /f

:: Netsh Tweaks
netsh int tcp set global timestamps=disabled
netsh int tcp set heuristics disabled
netsh int tcp set global chimney=disabled
netsh int tcp set global ecncapability=disabled
netsh int tcp set global nonsackrttresiliency=disabled
netsh int tcp set security mpp=disabled
netsh int tcp set security profiles=disabled
netsh int ip set global icmpredirects=disabled
netsh int tcp set security mpp=disabled profiles=disabled
netsh int ip set global multicastforwarding=disabled
netsh int tcp set supplemental internet congestionprovider=ctcp
netsh interface teredo set state disabled
netsh winsock reset
netsh int ip set global taskoffload=disabled
netsh int ip set global neighborcachelimit=4096
netsh int tcp set global dca=enabled
netsh int tcp set global netdma=enabled
PowerShell Disable-NetAdapterLso -Name "*"
powershell "ForEach($adapter In Get-NetAdapter){Disable-NetAdapterPowerManagement -Name $adapter.Name -ErrorAction SilentlyContinue}"
powershell "ForEach($adapter In Get-NetAdapter){Disable-NetAdapterLso -Name $adapter.Name -ErrorAction SilentlyContinue}"

Reg add "HKLM\Software\Policies\Microsoft\Windows\Psched" /v "NonBestEffortLimit" /t REG_DWORD /d "0" /f 

for /f %%i in ('wmic path win32_NetworkAdapter get PNPDeviceID') do set "str=%%i" & if "!str:PCI\VEN_=!" neq "!str!" (
:: DEL NET Device Priority
Reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePriority" /f 
:: Enable MSI Mode on Net
Reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties" /v "MSISupported" /t REG_DWORD /d "1" /f 
:: Hyperthreading 4 Cores
if %THREADS% gtr 2 if %THREADS% lss 4 if %CORES% neq %THREADS% (
Reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePolicy" /t REG_DWORD /d "4" /f
Reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "AssignmentSetOverride" /t REG_BINARY /d "30" /f
) 
:: No Hyperthreading 4 Cores
if %THREADS% gtr 2 if %THREADS% lss 4 if %CORES% equ %THREADS% (
Reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePolicy" /t REG_DWORD /d "4" /f
Reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "AssignmentSetOverride" /t REG_BINARY /d "04" /f
) 
:: More than 4 cores Affinites (NET SpreadMessageAcrossAllProccessors)
if %THREADS% gtr 4 (
Reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePolicy" /t REG_DWORD /d "5" /f
Reg delete "HKLM\SYSTEM\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "AssignmentSetOverride" /f
) 
)
echo NET MSI Mode
echo NET Affinites

:: Set the maximum number of concurrent connections (per server endpoint) allowed when making requests using an HttpClient object.
Reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v "MaxConnectionsPerServer" /t REG_DWORD /d "16" /f  
:: Maximum number of HTTP 1.0 connections to a Web server
Reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v "MaxConnectionsPer1_0Server" /t REG_DWORD /d "16" /f  
echo Maximum number of concurrent connections

:: Enable DNS over HTTPS
Reg add "HKLM\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" /v "EnableAutoDoh" /t REG_DWORD /d "2" /f
echo Enable DNS over HTTPS

:: https://admx.help/?Category=Windows_10_2016&Policy=Microsoft.Policies.QualityofService::QosTimerResolution
Reg add "HKLM\Software\Policies\Microsoft\Windows\Psched" /v "TimerResolution" /t REG_DWORD /d "1" /f 
Reg add "HKLM\System\CurrentControlSet\Services\AFD\Parameters" /v "DoNotHoldNicBuffers" /t REG_DWORD /d "1" /f 
echo Qos TimerResolution

:: Disable LLMNR
Reg add "HKLM\Software\Policies\Microsoft\Windows NT\DNSClient" /v "EnableMulticast" /t REG_DWORD /d "0" /f 
echo Disable LLMNR

:: Netsh
netsh int tcp set supplemental template=InternetCustom congestionprovider=bbr2 enablecwndrestart=disable
netsh int tcp set global congestionprovider=bbr2
netsh int tcp set security mpp=disabled profiles=disabled 
netsh int tcp set heur forcews=disable 
netsh int tcp set global rss=enabled autotuninglevel=normal ecncapability=disable dca=enabled netdma=disabled ^
timestamps=disabled rsc=disabled nonsackrttresiliency=disabled maxsynretransmissions=2 ^
fastopen=enabled fastopenfallback=default hystart=disabled prr=default pacingprofile=off 
netsh int ip set global groupforwardedfragments=disable icmpredirects=disabled minmtu=576 flowlabel=disable multicastforwarding=disabled 
echo Netsh

:: 0 - Disable LMHOSTS Lookup on all adapters / 1 - Enable
reg add "HKLM\System\CurrentControlSet\Services\NetBT\Parameters" /v "EnableLMHOSTS" /t REG_DWORD /d "0" /f

:: 2 - Disable NetBIOS over TCP/IP on all adapters / 1 - Enable / 0 - Default
wmic nicconfig where TcpipNetbiosOptions=0 call SetTcpipNetbios 2
wmic nicconfig where TcpipNetbiosOptions=1 call SetTcpipNetbios 2

:: NetBIOS / 0 - Disabled / 1 - Allowed / 2 - Disabled on public networks / 3 - Learning mode
reg add "HKLM\System\CurrentControlSet\Services\Dnscache\Parameters" /v "EnableNetbios" /t REG_DWORD /d "0" /f

:: 0 - Disable WiFi Sense (shares your WiFi network login with other people)
reg add "HKLM\Software\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots" /v "value" /t REG_DWORD /d "0" /f
reg add "HKLM\Software\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting" /v "value" /t REG_DWORD /d "0" /f
reg add "HKLM\Software\Microsoft\WcmSvc\wifinetworkmanager\config" /v "AutoConnectAllowedOEM" /t REG_DWORD /d "0" /f

goto :Net
:Net3
:: Enable QoS Policy outside domain networks
Reg add "HKLM\System\CurrentControlSet\Services\Tcpip\QoS" /v "Do not use NLA" /t REG_DWORD /d "1" /f 

:: Set max port to 65535
Reg add "HKLM\System\CurrentControlSet\Services\Tcpip\Parameters" /v "MaxUserPort" /t REG_DWORD /d "65534" /f  
echo Set max port to 65535

:: Reduce TIME_WAIT
Reg add "HKLM\System\CurrentControlSet\Services\Tcpip\Parameters" /v "TcpTimedWaitDelay" /t REG_DWORD /d "30" /f  
echo Reduce TIME_WAIT

:: Disable Window Scaling Heuristics (tries to identify connectivity and throughput problems and take appropriate measures.) 
Reg add "HKLM\System\CurrentControlSet\Services\Tcpip\Parameters" /v "EnableWsd" /t REG_DWORD /d "0" /f  
echo Disable Window Scaling Heuristics

:: Enable TCP Extensions for High Performance
Reg add "HKLM\System\CurrentControlSet\Services\Tcpip\Parameters" /v "Tcp1323Opts" /t REG_DWORD /d "1" /f   
echo Enable TCP Extensions for High Performance

:: Detect congestion fail to receive acknowledgement for a packet within the estimated timeout
Reg add "HKLM\System\CurrentControlSet\Services\Tcpip\Parameters" /v "TCPCongestionControl" /t REG_DWORD /d "1" /f  
echo Detect congestion fails

:: Enable The Network Adapter Onboard Processor
netsh int ip set global taskoffload=enabled 
Reg add "HKLM\System\CurrentControlSet\Services\Tcpip\Parameters" /v "DisableTaskOffload" /t REG_DWORD /d "0" /f 
echo Enable The Network Adapter Onboard Processor

:: Disable NetBios
Reg add "HKLM\System\CurrentControlSet\Services\NetBT\Parameters\Interfaces" /v "NetbiosOptions" /t REG_DWORD /d "2" /f 
echo Disable NetBios

:: Reduce Time To Live
Reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "DefaultTTL" /t REG_DWORD /d "64" /f 
echo Reduce Time To Live

:: Duplicate ACKs
Reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "TcpMaxDupAcks" /t REG_DWORD /d "2" /f
:: Disable SACKS
Reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "SackOpts" /t REG_DWORD /d "0" /f

:: Disable IPv6
netsh int ipv6 isatap set state disabled
netsh int teredo set state disabled
netsh interface ipv6 6to4 set state state=disabled undoonstop=disabled
reg add "HKLM\Software\Policies\Microsoft\Windows\TCPIP\v6Transition" /v "6to4_State" /t REG_SZ /d "Disabled" /f
reg add "HKLM\Software\Policies\Microsoft\Windows\TCPIP\v6Transition" /v "ISATAP_State" /t REG_SZ /d "Disabled" /f
reg add "HKLM\Software\Policies\Microsoft\Windows\TCPIP\v6Transition" /v "Teredo_State" /t REG_SZ /d "Disabled" /f
reg add "HKLM\System\CurrentControlSet\Services\Tcpip6\Parameters" /v "DisabledComponents" /t REG_DWORD /d "255" /f
reg add "HKLM\System\CurrentControlSet\Services\Tcpip6\Parameters" /v "EnableICSIPv6" /t REG_DWORD /d "255" /f

:: Tcpip Tweaks
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "EnableICMPRedirect" /t REG_DWORD /d "1" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "EnablePMTUDiscovery" /t REG_DWORD /d "1" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "Tcp1323Opts" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "TcpMaxDupAcks" /t REG_DWORD /d "2" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "TcpTimedWaitDelay" /t REG_DWORD /d "32" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "GlobalMaxTcpWindowSize" /t REG_DWORD /d "8760" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "TcpWindowSize" /t REG_DWORD /d "8760" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "MaxConnectionsPerServer" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "MaxUserPort" /t REG_DWORD /d "65534" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "SackOpts" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "DefaultTTL" /t REG_DWORD /d "64" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "NetworkThrottlingIndex" /t REG_SZ /d "ffffffff" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "NV Hostname" /t REG_SZ /d "domme" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "DataBasePath" /t REG_EXPAND_SZ /d "%%SystemRoot%%\System32\drivers\etc" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "NameServer" /t REG_SZ /d "" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "ForwardBroadcasts" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "IPEnableRouter" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "Domain" /t REG_SZ /d "" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "Hostname" /t REG_SZ /d "domme" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "SearchList" /t REG_SZ /d "" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "UseDomainNameDevolution" /t REG_DWORD /d "1" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "DeadGWDetectDefault" /t REG_DWORD /d "1" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "DontAddDefaultGatewayDefault" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "EnableSecurityFilters" /t REG_DWORD /d "0" /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\localstrike.net\ads" /v "*" /t REG_DWORD /d "4" /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\localstrike.net\search" /v "*" /t REG_DWORD /d "4" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Adapters\{A8DFEEA2-1FBA-427A-8639-668BFC4F78B0}" /v "LLInterface" /t REG_SZ /d "" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Adapters\{A8DFEEA2-1FBA-427A-8639-668BFC4F78B0}" /v "IpConfig" /t REG_MULTI_SZ /d "Tcpip\Parameters\Interfaces\{A8DFEEA2-1FBA-427A-8639-668BFC4F78B0}" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Adapters\{B2C8C55E-653D-4C97-AADB-6DE6FB94AC89}" /v "LLInterface" /t REG_SZ /d "ARP1394" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Adapters\{B2C8C55E-653D-4C97-AADB-6DE6FB94AC89}" /v "IpConfig" /t REG_MULTI_SZ /d "Tcpip\Parameters\Interfaces\{B2C8C55E-653D-4C97-AADB-6DE6FB94AC89}" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Adapters\{E686FBA4-2E2C-4855-9035-0C70B85184B6}" /v "LLInterface" /t REG_SZ /d "" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Adapters\{E686FBA4-2E2C-4855-9035-0C70B85184B6}" /v "IpConfig" /t REG_MULTI_SZ /d "Tcpip\Parameters\Interfaces\{E686FBA4-2E2C-4855-9035-0C70B85184B6}" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\DNSRegisteredAdapters" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{20612573-D9EB-46BB-9D1D-EED00C62A620}" /v "UseZeroBroadcast" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{20612573-D9EB-46BB-9D1D-EED00C62A620}" /v "IPAddress" /t REG_MULTI_SZ /d "0.0.0.0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{20612573-D9EB-46BB-9D1D-EED00C62A620}" /v "SubnetMask" /t REG_MULTI_SZ /d "0.0.0.0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{20612573-D9EB-46BB-9D1D-EED00C62A620}" /v "DefaultGateway" /t REG_MULTI_SZ /d "" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{20612573-D9EB-46BB-9D1D-EED00C62A620}" /v "EnableDeadGWDetect" /t REG_DWORD /d "1" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{20612573-D9EB-46BB-9D1D-EED00C62A620}" /v "DontAddDefaultGateway" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{A8DFEEA2-1FBA-427A-8639-668BFC4F78B0}" /v "UseZeroBroadcast" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{A8DFEEA2-1FBA-427A-8639-668BFC4F78B0}" /v "EnableDeadGWDetect" /t REG_DWORD /d "1" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{A8DFEEA2-1FBA-427A-8639-668BFC4F78B0}" /v "EnableDHCP" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{A8DFEEA2-1FBA-427A-8639-668BFC4F78B0}" /v "IPAddress" /t REG_MULTI_SZ /d "192.168.0.2" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{A8DFEEA2-1FBA-427A-8639-668BFC4F78B0}" /v "SubnetMask" /t REG_MULTI_SZ /d "255.255.255.0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{A8DFEEA2-1FBA-427A-8639-668BFC4F78B0}" /v "DefaultGateway" /t REG_MULTI_SZ /d "192.168.0.1" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{A8DFEEA2-1FBA-427A-8639-668BFC4F78B0}" /v "DefaultGatewayMetric" /t REG_MULTI_SZ /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{A8DFEEA2-1FBA-427A-8639-668BFC4F78B0}" /v "NameServer" /t REG_SZ /d "192.168.0.1" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{A8DFEEA2-1FBA-427A-8639-668BFC4F78B0}" /v "Domain" /t REG_SZ /d "" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{A8DFEEA2-1FBA-427A-8639-668BFC4F78B0}" /v "RegistrationEnabled" /t REG_DWORD /d "1" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{A8DFEEA2-1FBA-427A-8639-668BFC4F78B0}" /v "RegisterAdapterName" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{A8DFEEA2-1FBA-427A-8639-668BFC4F78B0}" /v "TCPAllowedPorts" /t REG_MULTI_SZ /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{A8DFEEA2-1FBA-427A-8639-668BFC4F78B0}" /v "UDPAllowedPorts" /t REG_MULTI_SZ /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{A8DFEEA2-1FBA-427A-8639-668BFC4F78B0}" /v "RawIPAllowedProtocols" /t REG_MULTI_SZ /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{A8DFEEA2-1FBA-427A-8639-668BFC4F78B0}" /v "NTEContextList" /t REG_MULTI_SZ /d "0x00000002" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{A8DFEEA2-1FBA-427A-8639-668BFC4F78B0}" /v "DhcpClassIdBin" /t REG_BINARY /d "" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{A8DFEEA2-1FBA-427A-8639-668BFC4F78B0}" /v "DhcpServer" /t REG_SZ /d "255.255.255.255" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{A8DFEEA2-1FBA-427A-8639-668BFC4F78B0}" /v "Lease" /t REG_DWORD /d "3600" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{A8DFEEA2-1FBA-427A-8639-668BFC4F78B0}" /v "LeaseObtainedTime" /t REG_DWORD /d "1128721584" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{A8DFEEA2-1FBA-427A-8639-668BFC4F78B0}" /v "T1" /t REG_DWORD /d "1128723384" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{A8DFEEA2-1FBA-427A-8639-668BFC4F78B0}" /v "T2" /t REG_DWORD /d "1128724734" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{A8DFEEA2-1FBA-427A-8639-668BFC4F78B0}" /v "LeaseTerminatesTime" /t REG_DWORD /d "1128725184" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{A8DFEEA2-1FBA-427A-8639-668BFC4F78B0}" /v "IPAutoconfigurationAddress" /t REG_SZ /d "0.0.0.0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{A8DFEEA2-1FBA-427A-8639-668BFC4F78B0}" /v "IPAutoconfigurationMask" /t REG_SZ /d "255.255.0.0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{A8DFEEA2-1FBA-427A-8639-668BFC4F78B0}" /v "IPAutoconfigurationSeed" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{A8DFEEA2-1FBA-427A-8639-668BFC4F78B0}" /v "AddressType" /t REG_DWORD /d "0" /f

goto :Net
:Net4
:: Internet Priority
Start "" /wait ""C:\Ra1nerFree\NSudo.exe"" -U:T -P:E -ShowWindowMode:Hide cmd /c sc start Psched
for %%i in (cs2 VALORANT-Win64-Shipping javaw FortniteClient-Win64-Shipping ModernWarfare r5apex) do (
Reg add "HKLM\Software\Policies\Microsoft\Windows\QoS\%%i" /v "Application Name" /t REG_SZ /d "%%i.exe" /f
Reg add "HKLM\Software\Policies\Microsoft\Windows\QoS\%%i" /v "Version" /t REG_SZ /d "1.0" /f
Reg add "HKLM\Software\Policies\Microsoft\Windows\QoS\%%i" /v "Protocol" /t REG_SZ /d "*" /f
Reg add "HKLM\Software\Policies\Microsoft\Windows\QoS\%%i" /v "Local Port" /t REG_SZ /d "*" /f
Reg add "HKLM\Software\Policies\Microsoft\Windows\QoS\%%i" /v "Local IP" /t REG_SZ /d "*" /f
Reg add "HKLM\Software\Policies\Microsoft\Windows\QoS\%%i" /v "Local IP Prefix Length" /t REG_SZ /d "*" /f
Reg add "HKLM\Software\Policies\Microsoft\Windows\QoS\%%i" /v "Remote Port" /t REG_SZ /d "*" /f
Reg add "HKLM\Software\Policies\Microsoft\Windows\QoS\%%i" /v "Remote IP" /t REG_SZ /d "*" /f
Reg add "HKLM\Software\Policies\Microsoft\Windows\QoS\%%i" /v "Remote IP Prefix Length" /t REG_SZ /d "*" /f
Reg add "HKLM\Software\Policies\Microsoft\Windows\QoS\%%i" /v "DSCP Value" /t REG_SZ /d "46" /f
Reg add "HKLM\Software\Policies\Microsoft\Windows\QoS\%%i" /v "Throttle Rate" /t REG_SZ /d "-1" /f
)
Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Psched" /v "NonBestEffortLimit" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Psched" /v "NonBestEffortLimit" /t REG_DWORD /d "0" /f

Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\ServiceProvider" /v "LocalPriority" /t REG_DWORD /d "4" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\ServiceProvider" /v "HostsPriority" /t REG_DWORD /d "5" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\ServiceProvider" /v "DnsPriority" /t REG_DWORD /d "6" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\ServiceProvider" /v "NetbtPriority" /t REG_DWORD /d "7" /f
echo Priority

goto :Net
:Net5

:: Configure network interface {9A2FF573-9392-4328-A76E-3CC5A195D9E2}
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Adapters\{9A2FF573-9392-4328-A76E-3CC5A195D9E2}" /v "LLInterface" /t REG_SZ /d "ARP1394" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Adapters\{9A2FF573-9392-4328-A76E-3CC5A195D9E2}" /v "IpConfig" /t REG_MULTI_SZ /d "Tcpip\Parameters\Interfaces\{9A2FF573-9392-4328-A76E-3CC5A195D9E2}" /f

:: Configure network interface {A8C43F70-D71E-41C5-8CE7-41258A8A7E37}
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Adapters\{A8C43F70-D71E-41C5-8CE7-41258A8A7E37}" /v "LLInterface" /t REG_SZ /d "" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Adapters\{A8C43F70-D71E-41C5-8CE7-41258A8A7E37}" /v "IpConfig" /t REG_MULTI_SZ /d "Tcpip\Parameters\Interfaces\{A8C43F70-D71E-41C5-8CE7-41258A8A7E37}" /f

:: Configure network interface {0DD48E26-3D78-4179-94E1-B985BD446474}
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{0DD48E26-3D78-4179-94E1-B985BD446474}" /v "UseZeroBroadcast" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{0DD48E26-3D78-4179-94E1-B985BD446474}" /v "EnableDHCP" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{0DD48E26-3D78-4179-94E1-B985BD446474}" /v "IPAddress" /t REG_MULTI_SZ /d "0.0.0.0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{0DD48E26-3D78-4179-94E1-B985BD446474}" /v "SubnetMask" /t REG_MULTI_SZ /d "0.0.0.0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{0DD48E26-3D78-4179-94E1-B985BD446474}" /v "DefaultGateway" /t REG_MULTI_SZ /d "" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{0DD48E26-3D78-4179-94E1-B985BD446474}" /v "EnableDeadGWDetect" /t REG_DWORD /d "1" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{0DD48E26-3D78-4179-94E1-B985BD446474}" /v "DontAddDefaultGateway" /t REG_DWORD /d "0" /f

:: Configure network interface {749A9614-EC83-4CC3-B32B-C3696B9AEEED}
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{749A9614-EC83-4CC3-B32B-C3696B9AEEED}" /v "UseZeroBroadcast" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{749A9614-EC83-4CC3-B32B-C3696B9AEEED}" /v "EnableDHCP" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{749A9614-EC83-4CC3-B32B-C3696B9AEEED}" /v "IPAddress" /t REG_MULTI_SZ /d "0.0.0.0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{749A9614-EC83-4CC3-B32B-C3696B9AEEED}" /v "SubnetMask" /t REG_MULTI_SZ /d "0.0.0.0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{749A9614-EC83-4CC3-B32B-C3696B9AEEED}" /v "DefaultGateway" /t REG_MULTI_SZ /d "" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{749A9614-EC83-4CC3-B32B-C3696B9AEEED}" /v "EnableDeadGWDetect" /t REG_DWORD /d "1" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{749A9614-EC83-4CC3-B32B-C3696B9AEEED}" /v "DontAddDefaultGateway" /t REG_DWORD /d "0" /f

:: Configure network interface {823A9830-5EC9-48B8-B5EF-EF5F087EBB7D}
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{823A9830-5EC9-48B8-B5EF-EF5F087EBB7D}" /v "UseZeroBroadcast" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{823A9830-5EC9-48B8-B5EF-EF5F087EBB7D}" /v "EnableDHCP" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{823A9830-5EC9-48B8-B5EF-EF5F087EBB7D}" /v "IPAddress" /t REG_MULTI_SZ /d "0.0.0.0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{823A9830-5EC9-48B8-B5EF-EF5F087EBB7D}" /v "SubnetMask" /t REG_MULTI_SZ /d "0.0.0.0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{823A9830-5EC9-48B8-B5EF-EF5F087EBB7D}" /v "DefaultGateway" /t REG_MULTI_SZ /d "" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{823A9830-5EC9-48B8-B5EF-EF5F087EBB7D}" /v "EnableDeadGWDetect" /t REG_DWORD /d "1" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{823A9830-5EC9-48B8-B5EF-EF5F087EBB7D}" /v "DontAddDefaultGateway" /t REG_DWORD /d "0" /f

:: Configure network interface {9A2FF573-9392-4328-A76E-3CC5A195D9E2}
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{9A2FF573-9392-4328-A76E-3CC5A195D9E2}" /v "UseZeroBroadcast" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{9A2FF573-9392-4328-A76E-3CC5A195D9E2}" /v "EnableDHCP" /t REG_DWORD /d "1" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{9A2FF573-9392-4328-A76E-3CC5A195D9E2}" /v "IPAddress" /t REG_MULTI_SZ /d "0.0.0.0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{9A2FF573-9392-4328-A76E-3CC5A195D9E2}" /v "SubnetMask" /t REG_MULTI_SZ /d "0.0.0.0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{9A2FF573-9392-4328-A76E-3CC5A195D9E2}" /v "DefaultGateway" /t REG_MULTI_SZ /d "" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{9A2FF573-9392-4328-A76E-3CC5A195D9E2}" /v "DefaultGatewayMetric" /t REG_MULTI_SZ /d "" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{9A2FF573-9392-4328-A76E-3CC5A195D9E2}" /v "NameServer" /t REG_SZ /d "" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{9A2FF573-9392-4328-A76E-3CC5A195D9E2}" /v "Domain" /t REG_SZ /d "" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{9A2FF573-9392-4328-A76E-3CC5A195D9E2}" /v "RegistrationEnabled" /t REG_DWORD /d "1" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{9A2FF573-9392-4328-A76E-3CC5A195D9E2}" /v "RegisterAdapterName" /t REG_DWORD /d "0" /f

:: Configure network interface {A8C43F70-D71E-41C5-8CE7-41258A8A7E37}
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{A8C43F70-D71E-41C5-8CE7-41258A8A7E37}" /v "UseZeroBroadcast" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{A8C43F70-D71E-41C5-8CE7-41258A8A7E37}" /v "EnableDeadGWDetect" /t REG_DWORD /d "1" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{A8C43F70-D71E-41C5-8CE7-41258A8A7E37}" /v "EnableDHCP" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{A8C43F70-D71E-41C5-8CE7-41258A8A7E37}" /v "IPAddress" /t REG_MULTI_SZ /d "192.168.0.1" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{A8C43F70-D71E-41C5-8CE7-41258A8A7E37}" /v "SubnetMask" /t REG_MULTI_SZ /d "255.255.255.0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{A8C43F70-D71E-41C5-8CE7-41258A8A7E37}" /v "DefaultGateway" /t REG_MULTI_SZ /d "" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{A8C43F70-D71E-41C5-8CE7-41258A8A7E37}" /v "DefaultGatewayMetric" /t REG_MULTI_SZ /d "" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{A8C43F70-D71E-41C5-8CE7-41258A8A7E37}" /v "NameServer" /t REG_SZ /d "" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{A8C43F70-D71E-41C5-8CE7-41258A8A7E37}" /v "Domain" /t REG_SZ /d "" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{A8C43F70-D71E-41C5-8CE7-41258A8A7E37}" /v "RegistrationEnabled" /t REG_DWORD /d "1" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{A8C43F70-D71E-41C5-8CE7-41258A8A7E37}" /v "RegisterAdapterName" /t REG_DWORD /d "0" /f

:: Configure network interface {B54D8B1E-9214-40A6-90BA-39C6FC82E86B}
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{B54D8B1E-9214-40A6-90BA-39C6FC82E86B}" /v "UseZeroBroadcast" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{B54D8B1E-9214-40A6-90BA-39C6FC82E86B}" /v "EnableDHCP" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{B54D8B1E-9214-40A6-90BA-39C6FC82E86B}" /v "IPAddress" /t REG_MULTI_SZ /d "0.0.0.0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{B54D8B1E-9214-40A6-90BA-39C6FC82E86B}" /v "SubnetMask" /t REG_MULTI_SZ /d "0.0.0.0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{B54D8B1E-9214-40A6-90BA-39C6FC82E86B}" /v "DefaultGateway" /t REG_MULTI_SZ /d "" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{B54D8B1E-9214-40A6-90BA-39C6FC82E86B}" /v "EnableDeadGWDetect" /t REG_DWORD /d "1" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{B54D8B1E-9214-40A6-90BA-39C6FC82E86B}" /v "DontAddDefaultGateway" /t REG_DWORD /d "0" /f

:: NIC
for /f "tokens=3*" %%a in ('Reg query "HKLM\Software\Microsoft\Windows NT\CurrentVersion\NetworkCards" /k /v /f "Description" /s /e ^| findstr /ri "REG_SZ"') do (
for /f %%g in ('Reg query "HKLM\System\CurrentControlSet\Control\Class\{4d36e972-e325-11ce-bfc1-08002be10318}" /s /f "%%b" /d ^| findstr /C:"HKEY"') do (
:: Disable Keys w "*"
Reg add "%%g" /v "*WakeOnMagicPacket" /t REG_SZ /d "0" /f
Reg add "%%g" /v "*WakeOnPattern" /t REG_SZ /d "0" /f
Reg add "%%g" /v "*FlowControl" /t REG_SZ /d "0" /f
Reg add "%%g" /v "*EEE" /t REG_SZ /d "0" /f
:: Disable Keys wo "*"
Reg add "%%g" /v "EnablePME" /t REG_SZ /d "0" /f
Reg add "%%g" /v "WakeOnLink" /t REG_SZ /d "0" /f
Reg add "%%g" /v "EEELinkAdvertisement" /t REG_SZ /d "0" /f
Reg add "%%g" /v "ReduceSpeedOnPowerDown" /t REG_SZ /d "0" /f
Reg add "%%g" /v "PowerSavingMode" /t REG_SZ /d "0" /f
Reg add "%%g" /v "EnableGreenEthernet" /t REG_SZ /d "0" /f
Reg add "%%g" /v "S5WakeOnLan" /t REG_SZ /d "0" /f
Reg add "%%g" /v "ULPMode" /t REG_SZ /d "0" /f
Reg add "%%g" /v "GigaLite" /t REG_SZ /d "0" /f
Reg add "%%g" /v "EnableSavePowerNow" /t REG_SZ /d "0" /f
Reg add "%%g" /v "EnablePowerManagement" /t REG_SZ /d "0" /f
Reg add "%%g" /v "EnableDynamicPowerGating" /t REG_SZ /d "0" /f
Reg add "%%g" /v "EnableConnectedPowerGating" /t REG_SZ /d "0" /f
Reg add "%%g" /v "AutoPowerSaveModeEnabled" /t REG_SZ /d "0" /f
Reg add "%%g" /v "AutoDisableGigabit" /t REG_SZ /d "0" /f
Reg add "%%g" /v "AdvancedEEE" /t REG_SZ /d "0" /f
Reg add "%%g" /v "PowerDownPll" /t REG_SZ /d "0" /f
Reg add "%%g" /v "S5NicKeepOverrideMacAddrV2" /t REG_SZ /d "0" /f
:: Disable JumboPacket
Reg add "%%g" /v "JumboPacket" /t REG_SZ /d "0" /f
:: Interrupt Moderation Adaptive (Default)
Reg add "%%g" /v "ITR" /t REG_SZ /d "125" /f
:: Receive/Transmit Buffers
Reg add "%%g" /v "ReceiveBuffers" /t REG_SZ /d "1024" /f
Reg add "%%g" /v "TransmitBuffers" /t REG_SZ /d "2048" /f
:: Disable Wake Features
Reg add "%%g" /v "WolShutdownLinkSpeed" /t REG_SZ /d "2" /f
:: Disable LargeSendOffloads
Reg add "%%g" /v "LsoV2IPv4" /t REG_SZ /d "0" /f
Reg add "%%g" /v "LsoV2IPv6" /t REG_SZ /d "0" /f
:: PnPCapabilities
Reg add "%%g" /v "PnPCapabilities" /t REG_DWORD /d "24" /f
:: Disable Offloads
Reg add "%%g" /v "UDPChecksumOffloadIPv6" /t REG_SZ /d "0" /f
Reg add "%%g" /v "IPChecksumOffloadIPv4" /t REG_SZ /d "0" /f
Reg add "%%g" /v "UDPChecksumOffloadIPv4" /t REG_SZ /d "0" /f
Reg add "%%g" /v "PMARPOffload" /t REG_SZ /d "0" /f
Reg add "%%g" /v "PMNSOffload" /t REG_SZ /d "0" /f
Reg add "%%g" /v "TCPChecksumOffloadIPv4" /t REG_SZ /d "0" /f
Reg add "%%g" /v "TCPChecksumOffloadIPv6" /t REG_SZ /d "0" /f
:: RSS
Reg add "%%g" /v "RSS" /t REG_SZ /d "1" /f
Reg add "%%g" /v "*NumRssQueues" /t REG_SZ /d "2" /f
if %CORES% geq 6 (
Reg add "%%g" /v "*RssBaseProcNumber" /t REG_SZ /d "4" /f
Reg add "%%g" /v "*RssMaxProcNumber" /t REG_SZ /d "5" /f
) else if %CORES% geq 4 (
Reg add "%%g" /v "*RssBaseProcNumber" /t REG_SZ /d "2" /f
Reg add "%%g" /v "*RssMaxProcNumber" /t REG_SZ /d "3" /f
) else (
Reg delete "%%g" /v "*RssBaseProcNumber" /f
Reg delete "%%g" /v "*RssMaxProcNumber" /f
)
)
)
echo NIC


goto :Net
:Net6
cls
echo.%C%╔══════════════════════════════════════════════════════════════════════════════════════════════╗   
echo.%C%║                                                                                              %C%║
echo.%C%║           %R%[1]%w% Realtek Driver     %R%[2]%w% Intel Driver     %R%[3]%w% Broadcom Driver                   %C%║
echo.%C%║                                                                                              %C%║
echo.%C%╚══════════════════════════════════════════════════════════════════════════════════════════════╝

set /p input=:
if /i %input% == 1 goto Realtek
if /i %input% == 2 goto Intelnet
if /i %input% == 3 goto BROADCOM


:Realtek
start https://www.realtek.com/en/component/zoo/category/network-interface-controllers-10-100-1000m-gigabit-ethernet-pci-express-software
goto :net
:IntelNet
start https://www.intel.com/content/www/us/en/download/18293/25016/intel-network-adapter-driver-for-windows-10.html
goto :Net
:BROADCOM
start https://docs.broadcom.com/docs/12378735
goto :Net

:Net7
set global initialrto=2000
set global maxsynretransmissions=2
set global fastopen=enabled
set global fastopenfallback=enabled
set global hystart=enabled
set global prr=enabled
set global pacingprofile=off
regsvr32 actxprxy.dll

POWERSHELL Set-NetTCPSetting -SettingName internet -ScalingHeuristics disabled -ErrorAction SilentlyContinue
POWERSHELL Set-NetTCPSetting -SettingName internet -MinRto 300 -ErrorAction SilentlyContinue

POWERSHELL Disable-NetAdapterBinding -Name "*" -ComponentID ms_lldp -ErrorAction SilentlyContinue
POWERSHELL Disable-NetAdapterBinding -Name "*" -ComponentID ms_lltdio -ErrorAction SilentlyContinue
POWERSHELL Disable-NetAdapterBinding -Name "*" -ComponentID ms_msclient -ErrorAction SilentlyContinue
POWERSHELL Disable-NetAdapterBinding -Name "*" -ComponentID ms_server -ErrorAction SilentlyContinue
POWERSHELL Disable-NetAdapterBinding -Name "*" -ComponentID ms_rspndr -ErrorAction SilentlyContinue
POWERSHELL Disable-NetAdapterBinding -Name "*" -ComponentID ms_implat -ErrorAction SilentlyContinue
POWERSHELL Disable-NetAdapterBinding -Name "*" -ComponentID ms_pacer -ErrorAction SilentlyContinue
POWERSHELL Disable-NetAdapterBinding -Name "*" -ComponentID ms_pppoe -ErrorAction SilentlyContinue
POWERSHELL Disable-NetAdapterBinding -Name "*" -ComponentID ms_rdma_ndk -ErrorAction SilentlyContinue
POWERSHELL Disable-NetAdapterBinding -Name "*" -ComponentID ms_ndisuio -ErrorAction SilentlyContinue
POWERSHELL Disable-NetAdapterBinding -Name "*" -ComponentID ms_wfplwf_upper -ErrorAction SilentlyContinue
POWERSHELL Disable-NetAdapterBinding -Name "*" -ComponentID ms_wfplwf_lower -ErrorAction SilentlyContinue
POWERSHELL Disable-NetAdapterBinding -Name "*" -ComponentID ms_netbt -ErrorAction SilentlyContinue
POWERSHELL Disable-NetAdapterBinding -Name "*" -ComponentID ms_netbios -ErrorAction SilentlyContinue

POWERSHELL Disable-NetAdapterQos -Name "*" -ErrorAction SilentlyContinue
POWERSHELL Disable-NetAdapterEncapsulatedPacketTaskOffload -Name "*" -ErrorAction SilentlyContinue
POWERSHELL Disable-NetAdapterIPsecOffload -Name "*" -ErrorAction SilentlyContinue
POWERSHELL Disable-NetAdapterChecksumOffload -Name "*" -ErrorAction SilentlyContinue
POWERSHELL Disable-NetAdapterLso -Name "*" -ErrorAction SilentlyContinue
POWERSHELL Disable-NetAdapterRsc -Name "*" -ErrorAction SilentlyContinue
POWERSHELL Disable-NetAdapterIPsecOffload -Name "*" -ErrorAction SilentlyContinue


goto :Net
:Net8
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces" /v "TCPDelAckTicks" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "TCPDelAckTicks" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "TCPNoDelay" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces" /v "TCPNoDelay" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\MSMQ\Parameters" /v "TCPNoDelay" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "TcpAckFrequency" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces" /v "TcpAckFrequency" /t REG_DWORD /d "1" /f
goto :Net

:Priority
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\I/O System" /v "PassiveIntRealTimeWorkerPriority" /t REG_DWORD /d "18" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\KernelVelocity" /v "DisableFGBoostDecay" /t REG_DWORD /d "1" /f

Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\dwm.exe\PerfOptions" /v "CpuPriorityClass" /t REG_DWORD /d "4" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\dwm.exe\PerfOptions" /v "IoPriority" /t REG_DWORD /d "3" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\lsass.exe\PerfOptions" /v "CpuPriorityClass" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\lsass.exe\PerfOptions" /v "IoPriority" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\lsass.exe\PerfOptions" /v "PagePriority" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\ntoskrnl.exe\PerfOptions" /v "CpuPriorityClass" /t REG_DWORD /d "4" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\ntoskrnl.exe\PerfOptions" /v "IoPriority" /t REG_DWORD /d "3" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\SearchIndexer.exe\PerfOptions" /v "CpuPriorityClass" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\SearchIndexer.exe\PerfOptions" /v "IoPriority" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\svchost.exe\PerfOptions" /v "CpuPriorityClass" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\TrustedInstaller.exe\PerfOptions" /v "CpuPriorityClass" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\TrustedInstaller.exe\PerfOptions" /v "IoPriority" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\wuauclt.exe\PerfOptions" /v "CpuPriorityClass" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\wuauclt.exe\PerfOptions" /v "IoPriority" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\audiodg.exe\PerfOptions" /v "CpuPriorityClass" /t REG_DWORD /d "2" /f
Reg.exe add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\audiodg.exe\PerfOptions" /v "CpuPriorityClass" /t REG_DWORD /d "2" /f
Reg.exe add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\dwm.exe\PerfOptions" /v "CpuPriorityClass" /t REG_DWORD /d "4" /f
Reg.exe add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\dwm.exe\PerfOptions" /v "IoPriority" /t REG_DWORD /d "3" /f
Reg.exe add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\lsass.exe\PerfOptions" /v "CpuPriorityClass" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\lsass.exe\PerfOptions" /v "IoPriority" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\lsass.exe\PerfOptions" /v "PagePriority" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\ntoskrnl.exe\PerfOptions" /v "CpuPriorityClass" /t REG_DWORD /d "4" /f
Reg.exe add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\ntoskrnl.exe\PerfOptions" /v "IoPriority" /t REG_DWORD /d "3" /f
Reg.exe add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\SearchIndexer.exe\PerfOptions" /v "CpuPriorityClass" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\SearchIndexer.exe\PerfOptions" /v "IoPriority" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\svchost.exe\PerfOptions" /v "CpuPriorityClass" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\TrustedInstaller.exe\PerfOptions" /v "CpuPriorityClass" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\TrustedInstaller.exe\PerfOptions" /v "IoPriority" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\wuauclt.exe\PerfOptions" /v "CpuPriorityClass" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\wuauclt.exe\PerfOptions" /v "IoPriority" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Low Latency" /v "Affinity" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Low Latency" /v "Background Only" /t REG_SZ /d "False" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Low Latency" /v "BackgroundPriority" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Low Latency" /v "Clock Rate" /t REG_DWORD /d "10000" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Low Latency" /v "GPU Priority" /t REG_DWORD /d "8" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Low Latency" /v "Priority" /t REG_DWORD /d "2" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Low Latency" /v "Scheduling Category" /t REG_SZ /d "Medium" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Low Latency" /v "SFIO Priority" /t REG_SZ /d "High" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Low Latency" /v "Latency Sensitive" /t REG_SZ /d "True" /f
timeout /t 1 /nobreak > nul

Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Affinity" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Background Only" /t REG_SZ /d "False" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "BackgroundPriority" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Clock Rate" /t REG_DWORD /d "10000" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "GPU Priority" /t REG_DWORD /d "18" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Priority" /t REG_DWORD /d "2" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Scheduling Category" /t REG_SZ /d "High" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "SFIO Priority" /t REG_SZ /d "High" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Latency Sensitive" /t REG_SZ /d "True" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Low Latency" /v "Affinity" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Low Latency" /v "Background Only" /t REG_SZ /d "False" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Low Latency" /v "BackgroundPriority" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Low Latency" /v "Clock Rate" /t REG_DWORD /d "10000" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Low Latency" /v "GPU Priority" /t REG_DWORD /d "8" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Low Latency" /v "Priority" /t REG_DWORD /d "2" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Low Latency" /v "Scheduling Category" /t REG_SZ /d "Medium" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Low Latency" /v "SFIO Priority" /t REG_SZ /d "High" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Low Latency" /v "Latency Sensitive" /t REG_SZ /d "True" /f

Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Affinity" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Background Only" /t REG_SZ /d "False" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "BackgroundPriority" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Clock Rate" /t REG_DWORD /d "10000" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "GPU Priority" /t REG_DWORD /d "18" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Priority" /t REG_DWORD /d "2" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Scheduling Category" /t REG_SZ /d "High" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "SFIO Priority" /t REG_SZ /d "High" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Latency Sensitive" /t REG_SZ /d "True" /f

Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\I/O System" /v "PassiveIntRealTimeWorkerPriority" /t REG_DWORD /d "18" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\KernelVelocity" /v "DisableFGBoostDecay" /t REG_DWORD /d "1" /f

Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\dwm.exe\PerfOptions" /v "CpuPriorityClass" /t REG_DWORD /d "4" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\dwm.exe\PerfOptions" /v "IoPriority" /t REG_DWORD /d "3" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\lsass.exe\PerfOptions" /v "CpuPriorityClass" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\lsass.exe\PerfOptions" /v "IoPriority" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\lsass.exe\PerfOptions" /v "PagePriority" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\ntoskrnl.exe\PerfOptions" /v "CpuPriorityClass" /t REG_DWORD /d "4" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\ntoskrnl.exe\PerfOptions" /v "IoPriority" /t REG_DWORD /d "3" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\SearchIndexer.exe\PerfOptions" /v "CpuPriorityClass" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\SearchIndexer.exe\PerfOptions" /v "IoPriority" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\svchost.exe\PerfOptions" /v "CpuPriorityClass" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\TrustedInstaller.exe\PerfOptions" /v "CpuPriorityClass" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\TrustedInstaller.exe\PerfOptions" /v "IoPriority" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\wuauclt.exe\PerfOptions" /v "CpuPriorityClass" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\wuauclt.exe\PerfOptions" /v "IoPriority" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\audiodg.exe\PerfOptions" /v "CpuPriorityClass" /t REG_DWORD /d "2" /f
Reg.exe add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\audiodg.exe\PerfOptions" /v "CpuPriorityClass" /t REG_DWORD /d "2" /f
Reg.exe add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\dwm.exe\PerfOptions" /v "CpuPriorityClass" /t REG_DWORD /d "4" /f
Reg.exe add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\dwm.exe\PerfOptions" /v "IoPriority" /t REG_DWORD /d "3" /f
Reg.exe add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\lsass.exe\PerfOptions" /v "CpuPriorityClass" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\lsass.exe\PerfOptions" /v "IoPriority" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\lsass.exe\PerfOptions" /v "PagePriority" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\ntoskrnl.exe\PerfOptions" /v "CpuPriorityClass" /t REG_DWORD /d "4" /f
Reg.exe add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\ntoskrnl.exe\PerfOptions" /v "IoPriority" /t REG_DWORD /d "3" /f
Reg.exe add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\SearchIndexer.exe\PerfOptions" /v "CpuPriorityClass" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\SearchIndexer.exe\PerfOptions" /v "IoPriority" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\svchost.exe\PerfOptions" /v "CpuPriorityClass" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\TrustedInstaller.exe\PerfOptions" /v "CpuPriorityClass" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\TrustedInstaller.exe\PerfOptions" /v "IoPriority" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\wuauclt.exe\PerfOptions" /v "CpuPriorityClass" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\wuauclt.exe\PerfOptions" /v "IoPriority" /t REG_DWORD /d "0" /f

reg add "HKLM\SYSTEM\ResourcePolicyStore\ResourceSets\Policies\CPU\HardCap0" /v "CapPercentage" /t REG_DWORD /d "0" /f 
reg add "HKLM\SYSTEM\ResourcePolicyStore\ResourceSets\Policies\CPU\HardCap0" /v "SchedulingType" /t REG_DWORD /d "0" /f 
reg add "HKLM\SYSTEM\ResourcePolicyStore\ResourceSets\Policies\CPU\Paused" /v "CapPercentage" /t REG_DWORD /d "0" /f 
reg add "HKLM\SYSTEM\ResourcePolicyStore\ResourceSets\Policies\CPU\Paused" /v "SchedulingType" /t REG_DWORD /d "0" /f 
reg add "HKLM\SYSTEM\ResourcePolicyStore\ResourceSets\Policies\CPU\SoftCapFull" /v "CapPercentage" /t REG_DWORD /d "0" /f 
reg add "HKLM\SYSTEM\ResourcePolicyStore\ResourceSets\Policies\CPU\SoftCapFull" /v "SchedulingType" /t REG_DWORD /d "0" /f 
reg add "HKLM\SYSTEM\ResourcePolicyStore\ResourceSets\Policies\CPU\SoftCapLow" /v "CapPercentage" /t REG_DWORD /d "0" /f 
reg add "HKLM\SYSTEM\ResourcePolicyStore\ResourceSets\Policies\CPU\SoftCapLow" /v "SchedulingType" /t REG_DWORD /d "0" /f 

goto General

:USB
:: Modify USB and Control Panel settings
reg add "HKCU\Software\Microsoft\Shell\USB" /v "NotifyOnWeakCharger" /t REG_DWORD /d "0" /f
reg add "HKCU\Control Panel\Desktop" /v "WindowArrangementActive" /t REG_SZ /d "0" /f
reg add "HKCU\Control Panel\Desktop" /v "DragFullWindows" /t REG_SZ /d "0" /f
reg add "HKCU\Control Panel\Desktop" /v "MenuShowDelay" /t REG_SZ /d "0" /f
reg add "HKCU\Control Panel\Desktop" /v "MouseWheelRouting" /t REG_DWORD /d "0" /f
reg add "HKCU\Control Panel\Desktop" /v "Pattern" /t REG_DWORD /d "0" /f
reg add "HKCU\Control Panel\Desktop" /v "WindowArrangementActive" /t REG_DWORD /d "0" /f
reg add "HKCU\Control Panel\Desktop" /v "ScreenSaverIsSecure" /t REG_SZ /d "0" /f
reg add "HKCU\Control Panel\Desktop" /v "ActiveWndTrackTimeout" /t REG_DWORD /d "0" /f
reg add "HKCU\Control Panel\Desktop" /v "BlockSendInputResets" /t REG_SZ /d "0" /f
reg add "HKCU\Control Panel\Desktop" /v "EnablePerProcessSystemDPI" /t REG_DWORD /d "0" /f
reg add "HKCU\Control Panel\Desktop" /v "Beep" /t REG_SZ /d "No" /f
reg add "HKCU\Control Panel\Desktop" /v "ExtendedSounds" /t REG_SZ /d "No" /f
reg add "HKCU\Control Panel\Desktop" /v "KeyboardDelay" /t REG_SZ /d "0" /f
reg add "HKCU\Control Panel\Desktop" /v "MouseSensitivity" /t REG_SZ /d "10" /f
reg add "HKCU\Control Panel\Desktop" /v "MouseSpeed" /t REG_SZ /d "0" /f
reg add "HKCU\Control Panel\Desktop" /v "MouseThreshold1" /t REG_SZ /d "0" /f
reg add "HKCU\Control Panel\Desktop" /v "MouseThreshold2" /t REG_SZ /d "0" /f
reg add "HKCU\Control Panel\Desktop" /v "Win8DpiScaling" /t REG_DWORD /d "0" /f
reg add "HKCU\Control Panel\Desktop" /v "DpiScalingVer" /t REG_DWORD /d "4096" /f
reg add "HKCU\Control Panel\Desktop" /v "ScreenSaverIsSecure" /t REG_SZ /d "0" /f
reg add "HKCU\Control Panel\Desktop" /v "PaintDesktopVersion" /t REG_DWORD /d "0" /f
reg add "HKCU\Control Panel\Desktop" /v "WallpaperOriginX" /t REG_DWORD /d "0" /f
reg add "HKCU\Control Panel\Desktop" /v "WallpaperOriginY" /t REG_DWORD /d "0" /f
reg add "HKCU\Control Panel\Desktop" /v "ForegroundLockTimeout" /t REG_DWORD /d "0" /f
reg add "HKCU\Control Panel\Desktop" /v "LastUpdated" /t REG_DWORD /d "4294967295" /f
reg add "HKCU\Control Panel\Mouse" /v "ActiveWindowTracking" /t REG_DWORD /d "0" /f
reg add "HKCU\Control Panel\Mouse" /v "Beep" /t REG_SZ /d "No" /f
reg add "HKCU\Control Panel\Mouse" /v "ExtendedSounds" /t REG_SZ /d "No" /f
reg add "HKCU\Control Panel\Mouse" /v "MouseSensitivity" /t REG_SZ /d "10" /f
reg add "HKCU\Control Panel\Mouse" /v "MouseSpeed" /t REG_SZ /d "0" /f
reg add "HKCU\Control Panel\Mouse" /v "MouseThreshold1" /t REG_SZ /d "0" /f
reg add "HKCU\Control Panel\Mouse" /v "MouseThreshold2" /t REG_SZ /d "0" /f
reg add "HKCU\Control Panel\Mouse" /v "MouseTrails" /t REG_SZ /d "0" /f
reg add "HKCU\Control Panel\Mouse" /v "SmoothMouseXCurve" /t REG_BINARY /d "0000000000000000c0cc0c0000000000809919000000000040662600000000000033330000000000" /f
reg add "HKCU\Control Panel\Mouse" /v "SmoothMouseYCurve" /t REG_BINARY /d "0000000000000000000038000000000000007000000000000000a800000000000000e00000000000" /f
reg add "HKCU\Control Panel\Mouse" /v "SnapToDefaultButton" /t REG_SZ /d "0" /f
reg add "HKCU\Control Panel\Mouse" /v "SwapMouseButtons" /t REG_SZ /d "0" /f

echo  - Thread Priorityd
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\usbxhci\Parameters" /v "ThreadPriority" /t REG_DWORD /d "31" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\USBHUB3\Parameters" /v "ThreadPriority" /t REG_DWORD /d "31" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm\Parameters" /v "ThreadPriority" /t REG_DWORD /d "31" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\NDIS\Parameters" /v "ThreadPriority" /t REG_DWORD /d "31" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\DXGKrnl\Parameters" /v "ThreadPriority" /t REG_DWORD /d "15" /f

echo  - Disabling USB Selective Suspend
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\USB" /v "DisableSelectiveSuspend" /t REG_DWO

for /f %%i in ('wmic path Win32_IDEController get PNPDeviceID 2^>nul') do set "str=%%i" & if "!str:PCI\VEN_=!" neq "!str!" (
:: DEL Sata controllers Device Priority
Reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePriority" /f 
:: Enable MSI Mode on Sata controllers
Reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties" /v "MSISupported" /t REG_DWORD /d "1" /f 
)

for /f %%i in ('wmic path Win32_USBController get PNPDeviceID') do set "str=%%i" & if "!str:PCI\VEN_=!" neq "!str!" (
:: DEL USB Device Priority
Reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePriority" /f 
:: Enable MSI Mode on USB
Reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties" /v "MSISupported" /t REG_DWORD /d "1" /f 
:: Hyperthreading 4 Cores
if %THREADS% gtr 2 if %THREADS% lss 4 if %CORES% neq %THREADS% (
Reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePolicy" /t REG_DWORD /d "4" /f
Reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "AssignmentSetOverride" /t REG_BINARY /d "C0" /f
) 
:: No Hyperthreading 4 Cores
if %THREADS% gtr 2 if %THREADS% lss 4 if %CORES% equ %THREADS% (
Reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePolicy" /t REG_DWORD /d "4" /f
Reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "AssignmentSetOverride" /t REG_BINARY /d "08" /f
) 
)
echo USB MSI Mode
echo USB Affinites
echo Delete all device priorities

:: Disable USB Power Savings
for /f "tokens=*" %%i in ('Reg query "HKLM\SYSTEM\CurrentControlSet\Enum" /s /f "StorPort" ^| findstr "StorPort"') do Reg add "%%i" /v "EnableIdlePowerManagement" /t REG_DWORD /d "0" /f 
echo Disable USB Power Savings

:: Disable Power Saving
for /f "tokens=*" %%i in ('wmic PATH Win32_PnPEntity GET DeviceID ^| findstr "USB\VID_"') do (
Reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters" /v "EnhancedPowerManagementEnabled" /t REG_DWORD /d "0" /f
Reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters" /v "AllowIdleIrpInD3" /t REG_DWORD /d "0" /f
Reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters" /v "EnableSelectiveSuspend" /t REG_DWORD /d "0" /f
Reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters" /v "DeviceSelectiveSuspended" /t REG_DWORD /d "0" /f
Reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters" /v "SelectiveSuspendEnabled" /t REG_DWORD /d "0" /f
Reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters" /v "SelectiveSuspendOn" /t REG_DWORD /d "0" /f
Reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters" /v "D3ColdSupported" /t REG_DWORD /d "0" /f
) 
echo Disable Power Savings

goto General

:Games
cls
echo. %C%╔══════════════════════════════════════════╗
echo. %C%║%W%                                          %C%║
echo. %C%║%W%     Pick the Game You want to optimize   %C%║
echo. %C%║%W%                                          %C%║
echo. %C%║%R%     [1]%W% Counter strike 2                 %C%║
echo. %C%║%W%                                          %C%║
echo. %C%║%R%     [2]%W% Fortnite                         %C%║              
echo. %C%║%W%                                          %C%║
echo. %C%╠══════════════════════════════════════════╣
echo. %C%║%R%     [B] Go back                          %C%║
echo. %C%╚══════════════════════════════════════════╝

set /p input=:
if /i %input% == 1 goto CS2
if /i %input% == 2 goto Fortnite
if /i %input% == B goto Menu

:CS2
:: Modify game-related settings
reg add "HKCU\Software\Microsoft\Games" /v "FpsAll" /t REG_DWORD /d "1" /f
reg add "HKCU\Software\Microsoft\Games" /v "GameFluidity" /t REG_DWORD /d "1" /f
reg add "HKCU\Software\Microsoft\Games" /v "FpsStatusGames" /t REG_DWORD /d "16" /f
reg add "HKCU\Software\Microsoft\Games" /v "FpsStatusGamesAll" /t REG_DWORD /d "4" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Affinity" /t REG_DWORD /d "0" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Background Only" /t REG_SZ /d "False" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Clock Rate" /t REG_DWORD /d "10000" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "GPU Priority" /t REG_DWORD /d "8" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Priority" /t REG_DWORD /d "2" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Scheduling Category" /t REG_SZ /d "High" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "SFIO Priority" /t REG_SZ /d "High" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Latency Sensitive" /t REG_SZ /d "True" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Low Latency" /v "Affinity" /t REG_DWORD /d "0" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Low Latency" /v "Background Only" /t REG_SZ /d "False" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Low Latency" /v "Clock Rate" /t REG_DWORD /d "10000" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Low Latency" /v "GPU Priority" /t REG_DWORD /d "8" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Low Latency" /v "Priority" /t REG_DWORD /d "2" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Low Latency" /v "Scheduling Category" /t REG_SZ /d "High" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Low Latency" /v "SFIO Priority" /t REG_SZ /d "High" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Low Latency" /v "Latency Sensitive" /t REG_SZ /d "True" /f

goto Games

:Fortnite
:: Modify game-related settings
reg add "HKCU\Software\Microsoft\Games" /v "FpsAll" /t REG_DWORD /d "1" /f
reg add "HKCU\Software\Microsoft\Games" /v "GameFluidity" /t REG_DWORD /d "1" /f
reg add "HKCU\Software\Microsoft\Games" /v "FpsStatusGames" /t REG_DWORD /d "16" /f
reg add "HKCU\Software\Microsoft\Games" /v "FpsStatusGamesAll" /t REG_DWORD /d "4" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Affinity" /t REG_DWORD /d "0" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Background Only" /t REG_SZ /d "False" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Clock Rate" /t REG_DWORD /d "10000" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "GPU Priority" /t REG_DWORD /d "8" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Priority" /t REG_DWORD /d "2" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Scheduling Category" /t REG_SZ /d "High" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "SFIO Priority" /t REG_SZ /d "High" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Latency Sensitive" /t REG_SZ /d "True" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Low Latency" /v "Affinity" /t REG_DWORD /d "0" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Low Latency" /v "Background Only" /t REG_SZ /d "False" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Low Latency" /v "Clock Rate" /t REG_DWORD /d "10000" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Low Latency" /v "GPU Priority" /t REG_DWORD /d "8" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Low Latency" /v "Priority" /t REG_DWORD /d "2" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Low Latency" /v "Scheduling Category" /t REG_SZ /d "High" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Low Latency" /v "SFIO Priority" /t REG_SZ /d "High" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Low Latency" /v "Latency Sensitive" /t REG_SZ /d "True" /f

Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "CpuPriorityClass" /t REG_DWORD /d "00000003
" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "GpuPriorityClass" /t REG_DWORD /d "8" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "CpuPriority" /t REG_DWORD /d "42" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "GpuPriority" /t REG_DWORD /d "42" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "IoPriority" /t REG_DWORD /d "8" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "Clock Rate" /t REG_DWORD /d "65536" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "GPU Priority" /t REG_DWORD /d "42" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "Affinity" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "CpuThreadPriority" /t REG_DWORD /d "8" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "CpuPriorityControl" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "CpuThreadCount" /t REG_DWORD /d "8" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "PowerThrottlingOff" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "CpuPrioritySeperation" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "PowerLimitEnabled" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "Throttle Rate" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "Clock Rate" /t REG_DWORD /d "65536" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "Priority" /t REG_DWORD /d "6" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "SystemResponsiveness" /t REG_DWORD /d "10" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "GPU Priority" /t REG_DWORD /d "8" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "IOPriorityClass" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "MaximumPerformanceEnabled" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "MaxPerformance" /t REG_DWORD /d "256" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "LowestPerformance" /t REG_DWORD /d "256" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "MinimumPerformanceEnabled" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "Io Priority" /t REG_DWORD /d "8" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "HBFlagsSwitch" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "HiberbootEnabled" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "PowerSettingProfile" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "SleepStudyDeviceAccountingLevel" /t REG_DWORD /d "4" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "WatchdogResumeTimeout" /t REG_DWORD /d "120" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "WatchdogSleepTimeout" /t REG_DWORD /d "300" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "POSTTime" /t REG_DWORD /d "8323" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "BootmgrUserInputTime" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "FwPOSTTime" /t REG_DWORD /d "8323" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "CoalescingTimerInterval" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "GpuSpeed" /t REG_DWORD /d "256" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /ve /t REG_SZ /d "True" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "CpuCoresAlways" /t REG_DWORD /d "18" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "CpuUtilization" /t REG_DWORD /d "256" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "LatencyPerformance" /t REG_DWORD /d "256" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "GpuPerformance" /t REG_DWORD /d "256" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "RenderingSpread" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "RenderingPerformance" /t REG_DWORD /d "256" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "LatencySpread" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "RenderingPriority" /t REG_DWORD /d "8" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "LatencyPriority" /t REG_DWORD /d "8" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "CpuSpread" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "GpuRenderingPriority" /t REG_DWORD /d "8" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "SpreadPriority" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "GpuMax" /t REG_DWORD /d "256" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "MaxPerformance" /t REG_DWORD /d "256" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "MinPerformance" /t REG_DWORD /d "256" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "PerformancePriority" /t REG_DWORD /d "8" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "PerformanceSpread" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "GpuMaxPerformance" /t REG_DWORD /d "256" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "CpuMaxPerformance" /t REG_DWORD /d "256" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "GpuAccelerating" /t REG_DWORD /d "256" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "DisableHWAcceleration" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "MaxMultisampleSize" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "HwSchMode" /t REG_DWORD /d "2" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "GpuThrottling" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "GpuStutter" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "GpuStutter" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "FadeIo" /t REG_DWORD /d "24" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "GpuClockSwitchLatency" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "UseReferenceRasterizer" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "DisableHWAcceleration" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "MaxMultisampleSize" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "UseReferenceRasterizer" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "DisableHWAcceleration" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "EnableHWAcceleration" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "HwSchMode" /t REG_DWORD /d "2" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "GpuThrottling" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "GpuStutter" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "GpuStutter" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "FadeIo" /t REG_DWORD /d "24" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "GpuClockSwitchLatency" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "HwSchMode" /t REG_DWORD /d "2" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "SmoothBrightnessDefaultEnable" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "SmoothBrightnessDefaultDisable" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "EnableRenderingSlowDown" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "EnableRenderingCache" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "EnableRenderingPowerSlowDown" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "EnablePowerSlowDown" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "EnablePowerControlSlowDown" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "DisableRenderingContextPreemption" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "DisableRenderingPreemption" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "DisableFGBoostDecay" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "IsLowPriority" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "IsRenderingLowPriority" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "RenderingBasePriority" /t REG_DWORD /d "130" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "RenderingOverTargetPriority" /t REG_DWORD /d "80" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "RenderThrottlingOff" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "EnableMidRenderingPreemption" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "RenderingPowerSteeringEnable" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "PowerSavingVsyncOn" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "HwSchedMode" /t REG_DWORD /d "2" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "GpuClockSwitchLatency" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "UnlimitedPerformance" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "SmoothStutterEnabled" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "EnableGpuTempData" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "EnableGpuCashing" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "EnableGpuSlowDown" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "PPMEnabled" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "EnableGpuPowerControl" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "EnableGpuPreemption" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "GpuIdleLatencyEnabled" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "GpuIdleEnabled" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "GpuPreemptionEnabled" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "GpuBackgoundTaskPriority" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "GpuRenderingPriority" /t REG_DWORD /d "3" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "GpuBackgoundTaskLimit" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "PowerSavingBackgoundTaskEnabled" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "RenderingSmoothStutterEnabled" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "RenderingStutterEnabled" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "GpuRenderingLatencyEnabled" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "GpuRenderingPriority" /t REG_DWORD /d "3" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "GpuRenderingPriorityForBackgoundTask" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "PowerSavingRenderingEnabled" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "GpuClockSpeed" /t REG_DWORD /d "65536" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "GpuRenderingClockSpeed" /t REG_DWORD /d "65536" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "UseBestResolution" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "SmoothResolutionEnabled" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "TVSupportEnabled" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "GpuThrottleRate" /t REG_DWORD /d "65536" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "DisableHWAcceleration" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "EnableHWAcceleration" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "HwSchMode" /t REG_DWORD /d "2" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "SmoothBrightnessDefaultEnable" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "SmoothBrightnessDefaultDisable" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "EnableRenderingSlowDown" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "EnableRenderingCache" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "EnableRenderingPowerSlowDown" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "EnablePowerSlowDown" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "EnablePowerControlSlowDown" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "DisableRenderingContextPreemption" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "DisableRenderingPreemption" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "DisableFGBoostDecay" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "IsLowPriority" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "IsRenderingLowPriority" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "RenderingBasePriority" /t REG_DWORD /d "130" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "RenderingOverTargetPriority" /t REG_DWORD /d "80" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "RenderThrottlingOff" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "EnableMidRenderingPreemption" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "RenderingPowerSteeringEnable" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "SwapEffectUpgradeCache" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "HwSchMode" /t REG_DWORD /d "2" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "GpuThrottling" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "GpuStutter" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "GpuStutter" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "FadeIo" /t REG_DWORD /d "24" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "GpuClockSwitchLatency" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "DisableHWAcceleration" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "EnableHWAcceleration" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "HwSchMode" /t REG_DWORD /d "2" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "SmoothBrightnessDefaultEnable" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "SmoothBrightnessDefaultDisable" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "EnableRenderingSlowDown" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "EnableRenderingCache" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "EnableRenderingPowerSlowDown" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "EnablePowerSlowDown" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "EnablePowerControlSlowDown" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "DisableRenderingContextPreemption" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "DisableRenderingPreemption" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "DisableFGBoostDecay" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "IsLowPriority" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "IsRenderingLowPriority" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "RenderingBasePriority" /t REG_DWORD /d "130" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "RenderingOverTargetPriority" /t REG_DWORD /d "80" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "RenderThrottlingOff" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "EnableMidRenderingPreemption" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "RenderingPowerSteeringEnable" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "PowerSavingVsyncOn" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "HwSchedMode" /t REG_DWORD /d "2" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "GpuClockSwitchLatency" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "UnlimitedPerformance" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "SmoothStutterEnabled" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "EnableGpuTempData" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "EnableGpuCashing" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "EnableGpuSlowDown" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "PPMEnabled" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "EnableGpuPowerControl" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "EnableGpuPreemption" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "GpuIdleLatencyEnabled" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "GpuIdleEnabled" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "GpuPreemptionEnabled" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "GpuBackgoundTaskPriority" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "GpuRenderingPriority" /t REG_DWORD /d "3" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "GpuBackgoundTaskLimit" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "PowerSavingBackgoundTaskEnabled" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "RenderingSmoothStutterEnabled" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "RenderingStutterEnabled" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "GpuRenderingLatencyEnabled" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "GpuRenderingPriority" /t REG_DWORD /d "3" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "GpuRenderingPriorityForBackgoundTask" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "PowerSavingRenderingEnabled" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "GpuClockSpeed" /t REG_DWORD /d "65536" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "GpuRenderingClockSpeed" /t REG_DWORD /d "65536" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "UseBestResolution" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "SmoothResolutionEnabled" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "TVSupportEnabled" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v "GpuThrottleRate" /t REG_DWORD /d "65536" /f
Reg.exe add "HKCU\Software\Epic Games\FortniteGame" /v "PoolSize" /t REG_DWORD /d 1000 /f
Reg.exe add "HKLM\SOFTWARE\AMD\Tdr\TdrDelay" /v "Delay" /t REG_DWORD /d 60 /f
Reg.exe add "HKCU\Software\Epic Games\Fortnite\DirectX12" /v "EnableAsyncCompute" /t REG_DWORD /d 1 /f
Reg.exe add "HKCU\Software\Epic Games\Fortnite\DirectX12" /v "EnableShaderPreCaching" /t REG_DWORD /d 1 /f
Reg.exe add "HKCU\Software\Epic Games\Fortnite\DirectX12" /v "DistanceFieldShadowing" /t REG_DWORD /d 0 /f
Reg.exe add "HKCU\Software\Epic Games\Fortnite" /v "TexturePoolSizeResidency" /t REG_DWORD /d 2 /f
Reg.exe add "HKCU\Software\Epic Games\Fortnite" /v "TextureMipBias" /t REG_DWORD /d 2 /f
Reg.exe add "HKCU\Software\Epic Games\Fortnite\DirectX12" /v "ThreadedOptimizations" /t REG_DWORD /d 1 /f
Reg.exe add "HKCU\Software\Epic Games\Fortnite\DirectX12" /v "MultiGPU" /t REG_DWORD /d 1 /f
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "FortniteClient-Win64-Shipping.exe" /t REG_SZ /d "GpuPreference=HighPerf" /f
Reg.exe add "HKLM\SOFTWARE\Khronos\OpenCL\Vendors\Advanced Micro Devices, Inc." /v "EnableThreadedOptimizations" /t REG_DWORD /d 1 /f
Reg.exe add "HKCU\Software\AMD\Gaming\GpuOverDrive" /v "PerformanceLevel" /t REG_DWORD /d 2 /f
Reg.exe add "HKCU\Software\AMD\Gaming\GpuOverDrive" /v "PowerStatePerformance" /t REG_DWORD /d 2 /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\DirectX" /v "DefThreadPriority" /t REG_DWORD /d "5" /f
Reg.exe add "HKCU\Software\Epic Games\Fortnite\DirectX12" /v "EnableShaderLinking" /t REG_DWORD /d "1" /f
Reg.exe add "HKCU\Software\Epic Games\Fortnite\DirectX12" /v "GPUBasedValidation" /t REG_DWORD /d "1" /f
Reg.exe add "HKCU\Software\Epic Games\FortniteGame\Battle Royale" /v "TextureQuality" /t REG_DWORD /d "0" /f
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences\FortniteClient-Win64-Shipping.exe" /v "GpuPreference" /t REG_DWORD /d "4" /f
Reg.exe add "HKEY_CURRENT_USER\Software\Epic Games\FortniteGame\DisplaySettings" /v "TextureLODBias" /t REG_DWORD /d -8 /f
Reg.exe add "HKEY_CURRENT_USER\Software\Epic Games\Fortnite\DirectX12" /v "UseOptimalAsyncCompute" /t REG_DWORD /d 1 /f
Reg.exe add "HKEY_CURRENT_USER\Software\Epic Games\Fortnite\DirectX12" /v "UseOptimalGpuMaxTime" /t REG_DWORD /d 1 /f
Reg.exe add "HKEY_CURRENT_USER\Software\Epic Games\Fortnite\DirectX12" /v "UseOptimalGpuUpdateTime" /t REG_DWORD /d 1 /f
Reg.exe add "HKEY_CURRENT_USER\Software\Epic Games\FortniteGame\DirectX12" /v "Tearing" /t REG_DWORD /d 0 /f
Reg.exe add "HKEY_CURRENT_USER\Software\Epic Games\FortniteGame\DirectX12" /v "GPUBusyLoadEnable" /t REG_DWORD /d 0 /f
Reg.exe add "HKEY_CURRENT_USER\Software\Epic Games\FortniteGame\DirectX12" /v "GPUBusyLoadRejectionLimit" /t REG_DWORD /d 2 /f
Reg.exe add "HKEY_CURRENT_USER\Software\Epic Games\FortniteGame\DirectX12" /v "GPUBusyLoadAsyncCompute" /t REG_DWORD /d 1 /f
Reg.exe add "HKCU\Software\Epic Games\Fortnite\DirectX12" /v "LODBias" /t REG_DWORD /d 0 /f
Reg.exe add "HKEY_CURRENT_USER\Software\Epic Games\Fortnite\DirectX12" /v "OutOfProcessGPU" /t REG_DWORD /d 1 /f
Reg.exe add "HKEY_CURRENT_USER\Software\Epic Games\Fortnite\DirectX12" /v "FeatureLevel" /t REG_DWORD /d 0x00000012 /f
Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "TdrDelay" /t REG_DWORD /d 10 /f
Reg.exe add "HKEY_CURRENT_USER\Software\Epic Games\Fortnite\DirectX12" /v "OptimizeForPerf" /t REG_DWORD /d 1 /f
Reg.exe add "HKEY_CURRENT_USER\Software\Epic Games\Fortnite\FortniteGame\Settings" /v "TextureStreamingBudget" /t REG_DWORD /d 0 /f
Reg.exe add "HKCU\Software\Epic Games\Fortnite" /v "ThreadedRendering" /t REG_DWORD /d "1" /f
reg add "HKEY_CURRENT_USER\Software\AMD\Gaming\GpuPwrMode" /v "FortniteClient-Win64-Shipping.exe" /t REG_DWORD /d 3 /f

netsh advfirewall firewall add rule name="StopThrottling" dir=in action=block remoteip=173.194.55.0/24,206.111.0.0/16 enable=yes

:Resolution
echo. %C%╔══════════════════════════════════════════╗
echo. %C%║%W%                                          %C%║
echo. %C%║%W%     %C%Pick Your Resolution                 %C%║
echo. %C%║%W%                                          %C%║
echo. %C%║%R%     [1]%W% Native (4K)                      %C%║
echo. %C%║%W%                                          %C%║
echo. %C%║%R%     [2]%W% Native (1440p)                   %C%║
echo. %C%║%W%                                          %C%║
echo. %C%║%R%     [3]%W% Native (1080p)                   %C%║
echo. %C%║%W%                                          %C%║
echo. %C%║%R%     [4]%W% Streched (1650x1080)             %C%║
echo. %C%║%W%                                          %C%║
echo. %C%║%R%     [5]%W% Streched (1440x1080)             %C%║              
echo. %C%║%W%                                          %C%║
echo. %C%╚══════════════════════════════════════════╝

set /p input=:
if /i %input% == 1 goto 4k
if /i %input% == 2 goto 2k
if /i %input% == 3 goto 1k
if /i %input% == 4 goto 1650
if /i %input% == 5 goto 1440

:4k
curl -g -k -l -# -o "c:\Ra1nerFree\GameUserSettings.ini" "https://cdn.discordapp.com/attachments/1184138546890686554/1188486271681708062/GameUserSettings.ini?ex=659ab318&is=65883e18&hm=0173dff6f1ce615414bab9e30f6032b6cf184ba63f9b47f41e3db6a813c86bea&"
replace "c:\Ra1nerFree\GameUserSettings.ini" "%Localappdata%\FortniteGame\Saved\Config\WindowsClient"
attrib +r "%Localappdata%\FortniteGame\Saved\Config\WindowsClient\GameUserSettings.ini"

goto Games

:2k
curl -g -k -l -# -o "c:\Ra1nerFree\GameUserSettings.ini" "https://cdn.discordapp.com/attachments/1184138546890686554/1188486519556689980/GameUserSettings.ini?ex=659ab353&is=65883e53&hm=201256dd1b1ba3df5e4ac3435f6590c4c6bbdca0a6e3c4a6f64ba520ec0931f7&"replace ""c:\Ra1nerFree\GameUserSettings.ini" "%Localappdata%\FortniteGame\Saved\Config\WindowsClient"
replace "c:\Ra1nerFree\GameUserSettings.ini" "%Localappdata%\FortniteGame\Saved\Config\WindowsClient"
attrib +r "%Localappdata%\FortniteGame\Saved\Config\WindowsClient\GameUserSettings.ini"

goto Games

:1k
curl -g -k -l -# -o "c:\Ra1nerFree\GameUserSettings.ini" "https://cdn.discordapp.com/attachments/1184138546890686554/1188486656085458996/GameUserSettings.ini?ex=659ab373&is=65883e73&hm=dfd3d978157d9ae1afa105503eef9dc1d47c41d1f86ec7132fb508bff0fe67a2&"
replace "c:\Ra1nerFree\GameUserSettings.ini" "%Localappdata%\FortniteGame\Saved\Config\WindowsClient"
attrib +r "%Localappdata%\FortniteGame\Saved\Config\WindowsClient\GameUserSettings.ini"

goto Games

:1650
curl -g -k -l -# -o "c:\Ra1nerFree\GameUserSettings.ini" "https://cdn.discordapp.com/attachments/1184138546890686554/1188486782925422682/GameUserSettings.ini?ex=659ab392&is=65883e92&hm=1c8d7567d612dc67bb3e66136b418f9abecee1d6c920a8675da89b37e1d641ee&"
replace "c:\Ra1nerFree\GameUserSettings.ini" "%Localappdata%\FortniteGame\Saved\Config\WindowsClient"
attrib +r "%Localappdata%\FortniteGame\Saved\Config\WindowsClient\GameUserSettings.ini"

goto Games

:1440
curl -g -k -l -# -o "c:\Ra1nerFree\GameUserSettings.ini" "https://cdn.discordapp.com/attachments/1184138546890686554/1188486892841336832/GameUserSettings.ini?ex=659ab3ac&is=65883eac&hm=5f4bf1a83cd5497ab1bb01f60f411f9f20446db1423ed6bc9e52d035767892d9&"
replace "c:\Ra1nerFree\GameUserSettings.ini" "%Localappdata%\FortniteGame\Saved\Config\WindowsClient"
attrib +r "%Localappdata%\FortniteGame\Saved\Config\WindowsClient\GameUserSettings.ini"

goto Games

:BCD       

else (
:: Disable HPET
sc config "STR" start=disabled >nul 2>&1
sc stop STR >nul 2>&11
bcdedit /deletevalue useplatformclock 
bcdedit /set disabledynamictick yes 
bcdedit /set useplatformtick yes
echo Disable HPET
)


bcdedit /set increaseuserva 8000


:: Better Input
bcdedit /set tscsyncpolicy legacy 
echo tscsyncpolicy legacy

:: Disable Early Launch Anti-Malware Protection
bcdedit /set disableelamdrivers Yes 
echo Disable Early Launch Anti-Malware Protection
)

:: Disable Data Execution Prevention
echo %PROCESSOR_IDENTIFIER% ^| find "Intel" >nul && bcdedit /set nx optout >nul || bcdedit /set nx alwaysoff >nul
echo Disable Data Execution Prevention

:: Linear Address 57
bcdedit /set linearaddress57 OptOut 
bcdedit /set increaseuserva 268435328 
echo Linear Address 57

:: Disable some of the kernel memory mitigations
bcdedit /set isolatedcontext No 
bcdedit /set allowedinmemorysettings 0x0 
echo Kernel memory mitigations

:: Disable DMA memory protection and cores isolation
bcdedit /set vsmlaunchtype Off 
bcdedit /set vm No 
Reg add "HKLM\Software\Policies\Microsoft\FVE" /v "DisableExternalDMAUnderLock" /t REG_DWORD /d "0" /f 
Reg add "HKLM\Software\Policies\Microsoft\Windows\DeviceGuard" /v "EnableVirtualizationBasedSecurity" /t REG_DWORD /d "0" /f 
Reg add "HKLM\Software\Policies\Microsoft\Windows\DeviceGuard" /v "HVCIMATRequired" /t REG_DWORD /d "0" /f 
echo DMA memory protection and cores isolation

:: Enable X2Apic
bcdedit /set x2apicpolicy Enable 
bcdedit /set uselegacyapicmode No 
echo Enable X2Apic

:: Enable Memory Mapping for PCI-E devices
bcdedit /set configaccesspolicy Default 
bcdedit /set MSI Default 
bcdedit /set usephysicaldestination No 
bcdedit /set usefirmwarepcisettings No 
echo Enable Memory Mapping

bcdedit /deletevalue avoidlowmemory    
bcdedit /deletevalue bootems    
bcdedit /deletevalue bootlog         
bcdedit /deletevalue configflags    
bcdedit /deletevalue debug      
bcdedit /deletevalue extendedinput     
bcdedit /deletevalue firstmegabytepolicy    
bcdedit /deletevalue forcefipscrypto    
bcdedit /deletevalue forcelegacyplatform    
bcdedit /deletevalue graphicsmodedisabled                 
bcdedit /deletevalue nolowmem         
bcdedit /deletevalue onecpu    
bcdedit /deletevalue pae    
bcdedit /deletevalue perfmem        
bcdedit /deletevalue sos     
bcdedit /deletevalue testsigning    
bcdedit /deletevalue tpmbootentropy    
bcdedit /timeout 0    
bcdedit /set bootux disabled    
bcdedit /set bootmenupolicy standard     
bcdedit /set quietboot yes    
bcdedit /set {globalsettings} custom:16000067 true    
bcdedit /set {globalsettings} custom:16000069 true    
bcdedit /set {globalsettings} custom:16000068 true    
bcdedit /set highestmode Yes

goto General

:DirectX
powershell -Command "& {Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.MessageBox]::Show('Update your DirectX Driver Just follow the promts on the directX Download that will open when you click ok', 'Ra1ner Tweaking Utility', 'Ok', [System.Windows.Forms.MessageBoxIcon]::Information);}"

"c:\Ra1nerFree\DirectX.exe"

Reg add "HKLM\SOFTWARE\Microsoft\DirectDraw" /v "DisableAGPSupport" /t Reg_DWORD /d "0" /f
Reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\DirectDraw" /v "DisableAGPSupport" /t Reg_DWORD /d "0" /f
Reg add "HKLM\SOFTWARE\Microsoft\DirectDraw" /v "UseNonLocalVidMem" /t Reg_DWORD /d "1" /f
Reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\DirectDraw" /v "UseNonLocalVidMem" /t Reg_DWORD /d "1" /f
Reg add "HKLM\SOFTWARE\Microsoft\Direct3D" /v "UseNonLocalVidMem" /t Reg_DWORD /d "1" /f
Reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Direct3D" /v "UseNonLocalVidMem" /t Reg_DWORD /d "1" /f
Reg add "HKLM\SOFTWARE\Microsoft\DirectDraw" /v "DisableDDSCAPSInDDSD" /t Reg_DWORD /d "0" /f
Reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\DirectDraw" /v "DisableDDSCAPSInDDSD" /t Reg_DWORD /d "0" /f
Reg add "HKLM\SOFTWARE\Microsoft\DirectDraw" /v "EmulationOnly" /t Reg_DWORD /d "0" /f
Reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\DirectDraw" /v "EmulationOnly" /t Reg_DWORD /d "0" /f
Reg add "HKLM\SOFTWARE\Microsoft\DirectDraw" /v "EmulatePointSprites" /t Reg_DWORD /d "0" /f
Reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\DirectDraw" /v "EmulatePointSprites" /t Reg_DWORD /d "0" /f
Reg add "HKLM\SOFTWARE\Microsoft\Direct3D\Drivers" /v "ForceRgbRasterizer" /t Reg_DWORD /d "0" /f
Reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Direct3D\Drivers" /v "ForceRgbRasterizer" /t Reg_DWORD /d "0" /f
Reg add "HKLM\SOFTWARE\Microsoft\DirectDraw" /v "EmulateStateBlocks" /t Reg_DWORD /d "0" /f
Reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\DirectDraw" /v "EmulateStateBlocks" /t Reg_DWORD /d "0" /f
Reg add "HKLM\SOFTWARE\Microsoft\Direct3D" /v "EnableDebugging" /t Reg_DWORD /d "0" /f
Reg add "HKLM\SOFTWARE\Microsoft\Direct3D" /v "FullDebug" /t Reg_DWORD /d "0" /f
Reg add "HKLM\SOFTWARE\Microsoft\Direct3D" /v "DisableDM" /t Reg_DWORD /d "1" /f
Reg add "HKLM\SOFTWARE\Microsoft\Direct3D" /v "EnableMultimonDebugging" /t Reg_DWORD /d "0" /f
Reg add "HKLM\SOFTWARE\Microsoft\Direct3D" /v "LoadDebugRuntime" /t Reg_DWORD /d "0" /f
Reg add "HKLM\SOFTWARE\Microsoft\Direct3D\Drivers" /v "EnumReference" /t Reg_DWORD /d "1" /f
Reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Direct3D\Drivers" /v "EnumReference" /t Reg_DWORD /d "1" /f
Reg add "HKLM\SOFTWARE\Microsoft\Direct3D\Drivers" /v "EnumSeparateMMX" /t Reg_DWORD /d "1" /f
Reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Direct3D\Drivers" /v "EnumSeparateMMX" /t Reg_DWORD /d "1" /f
Reg add "HKLM\SOFTWARE\Microsoft\Direct3D\Drivers" /v "EnumRamp" /t Reg_DWORD /d "1" /f
Reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Direct3D\Drivers" /v "EnumRamp" /t Reg_DWORD /d "1" /f
Reg add "HKLM\SOFTWARE\Microsoft\Direct3D\Drivers" /v "EnumNullDevice" /t Reg_DWORD /d "1" /f
Reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Direct3D\Drivers" /v "EnumNullDevice" /t Reg_DWORD /d "1" /f
Reg add "HKLM\SOFTWARE\Microsoft\Direct3D" /v "FewVertices" /t Reg_DWORD /d "1" /f
Reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Direct3D" /v "FewVertices" /t Reg_DWORD /d "1" /f
Reg add "HKLM\SOFTWARE\Microsoft\DirectDraw" /v "DisableMMX" /t Reg_DWORD /d "0" /f
Reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\DirectDraw" /v "DisableMMX" /t Reg_DWORD /d "0" /f
Reg add "HKLM\SOFTWARE\Microsoft\Direct3D" /v "DisableMMX" /t Reg_DWORD /d "0" /f
Reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Direct3D" /v "DisableMMX" /t Reg_DWORD /d "0" /f
Reg add "HKLM\SOFTWARE\Microsoft\Direct3D" /v "MMX Fast Path" /t Reg_DWORD /d "1" /f
Reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Direct3D" /v "MMX Fast Path" /t Reg_DWORD /d "1" /f
Reg add "HKLM\SOFTWARE\Microsoft\Direct3D" /v "MMXFastPath" /t Reg_DWORD /d "1" /f
Reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Direct3D" /v "MMXFastPath" /t Reg_DWORD /d "1" /f
Reg add "HKLM\SOFTWARE\Microsoft\Direct3D" /v "UseMMXForRGB" /t Reg_DWORD /d "1" /f
Reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Direct3D" /v "UseMMXForRGB" /t Reg_DWORD /d "1" /f
Reg add "HKLM\SOFTWARE\Microsoft\Direct3D\Drivers" /v "UseMMXForRGB" /t Reg_DWORD /d "1" /f
Reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Direct3D\Drivers" /v "UseMMXForRGB" /t Reg_DWORD /d "1" /f
Reg add "HKLM\SOFTWARE\Microsoft\Direct3D\Drivers" /v "EnumSeparateMMX" /t Reg_DWORD /d "1" /f
Reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Direct3D\Drivers" /v "EnumSeparateMMX" /t Reg_DWORD /d "1" /f
Reg add "HKLM\SOFTWARE\Microsoft\DirectDraw" /v "ForceNoSysLock" /t Reg_DWORD /d "0" /f
Reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\DirectDraw" /v "ForceNoSysLock" /t Reg_DWORD /d "0" /f

goto Menu

:Storage
fsutil behavior set memoryusage 2
fsutil behavior set mftzone 4
fsutil behavior set disableLastAccess 0
fsutil behavior set disable8dot3 1 
fsutil behavior set disabledeletenotify 0
fsutil behavior set encryptpagingfile 0

goto General

:Advanced
cls
echo. %C%╔══════════════════════════════════════════════════════════════════════════════════════════════════════════╗
echo. %C%║%R%             █████╗ ██████╗ ██╗   ██╗ █████╗ ███╗   ██╗ ██████╗███████╗██████╗                            %C%║
echo. %C%║%R%            ██╔══██╗██╔══██╗██║   ██║██╔══██╗████╗  ██║██╔════╝██╔════╝██╔══██╗                           %C%║
echo. %C%║%R%            ███████║██║  ██║██║   ██║███████║██╔██╗ ██║██║     █████╗  ██║  ██║                           %C%║
echo. %C%║%R%            ██╔══██║██║  ██║╚██╗ ██╔╝██╔══██║██║╚██╗██║██║     ██╔══╝  ██║  ██║                           %C%║
echo. %C%║%R%            ██║  ██║██████╔╝ ╚████╔╝ ██║  ██║██║ ╚████║╚██████╗███████╗██████╔╝                           %C%║
echo. %C%║%R%            ╚═╝  ╚═╝╚═════╝   ╚═══╝  ╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝╚══════╝╚═════╝                            %C%║
echo. %C%╠══════════════════════════════════════════════════════════════════════════════════════════════════════════╣
echo. %C%║%W%                                                                                                          %C%║
echo. %C%║%W%                               BE %R%REALLY CAREFULL%W% With these Changes                                      %C%║
echo. %C%║%W%            since it can be very confusing to fix if you dont know what you are doing                     %C%║
echo. %C%║%W%                                                                                                          %C%║
echo. %C%║%R%         [1]%W% Block Windows Updates (Can cause Microsoft apps not to install)                              %C%║
echo. %C%║%W%                                                                                                          %C%║
echo. %C%║%R%         [2]%W% Remove Microsoft Edge (Apps like Disney+ Will not be useable if you remove microsoft edge)   %C%║
echo. %C%║%W%                                                                                                          %C%║
echo. %C%║%R%         [3]%W% Disable Bluetooth (Says it self you wont be able to use devices over bluetooth)              %C%║
echo. %C%║%W%                                                                                                          %C%║
echo. %C%║%R%         [4]%W% Disable Xbox Services (You wont be able to login to Games from the Xbox store)               %C%║
echo. %C%║%W%                                                                                                          %C%║
echo. %C%║%R%         [5]%W% Enable Windows 10 Context menu/Right click menu On windows 11                                %C%║
echo. %C%║%W%                                                                                                          %C%║
echo. %C%║%R%         [R]%W% Revert these Settings                                                                        %C%║
echo. %C%║%W%                                                                                                          %C%║
echo. %C%╠══════════════════════════════════════════════════════════════════════════════════════════════════════════╣
echo. %C%║%W%                                                                                                          %C%║
echo. %C%║%W%                                             %R%[B] Back                                                     %C%║
echo. %C%║%W%                                                                                                          %C%║
echo. %C%╚══════════════════════════════════════════════════════════════════════════════════════════════════════════╝

set /p input=:
if /i %input% == 1 goto A1
if /i %input% == 2 goto A2
if /i %input% == 3 goto A3
if /i %input% == 4 goto A4
if /i %input% == 5 goto Win10
if /i %input% == R goto UndoAdvanced
if /i %input% == B goto Menu
goto Menu

:A1
chcp 437 > nul

powershell -Command "& {Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.MessageBox]::Show('Choose disable updates in Windows Update_Blocker.exe, press ok to open it', 'Ra1ner Tweaking Utility', 'Ok', [System.Windows.Forms.MessageBoxIcon]::Information);}"
chcp 65001 > nul

c:\Ra1nerFree\Update_Blocker.exe
goto Advanced

:A2
:: Uninstall Microsoft Edge using the setup tool
cd "%PROGRAMFILES(X86)%\Microsoft\Edge\Application"
for /d %%I in (*) do (
    cd "%%I\Installer"
    setup --uninstall --force-uninstall --system-level
    cd ..
)

:: Remove Microsoft Edge folders
cd "%PROGRAMFILES(X86)%\Microsoft\Edge"
rmdir /s /q "C:\Program Files (x86)\Microsoft\Edge"

:A3
Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\BTAGService" /v "Start" /t REG_DWORD /d "4" /f
Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\bthserv" /v "Start" /t REG_DWORD /d "4" /f
Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\BthAvctpSvc" /v "Start" /t REG_DWORD /d "4" /f
Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\BluetoothUserService" /v "Start" /t REG_DWORD /d "4" /f

goto Advanced

:A4
sc config xbgm start= disabled >nul 2>&1
sc config XblAuthManager start= disabled
sc config XblGameSave start= disabled
sc config XboxGipSvc start= disabled
sc config XboxNetApiSvc start= disabled

goto Advanced

:Win10
echo [+] Changing registry
timeout /t 1 /nobreak > NUL
reg.exe add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /f /ve
echo [+] Registry changed waiting for Explorer to restart
timeout /t 1 /nobreak > NUL
echo [-] Explorer.exe Now Restarting
taskkill /F /IM explorer.exe
start explorer
timeout /t 1 /nobreak > NUL
echo (+) Windows 10 Right click menu now added
timeout /t 1 /nobreak > NUL
goto Advanced

:UndoAdvanced
cls
echo. %C%╔══════════════════════════════════════════════════════════════════════════════════════════════════════════╗
echo. %C%║%W%                                                                                                          %C%║
echo. %C%║%R%         [1]%W% Enable Windows Updates                                                                       %C%║
echo. %C%║%W%                                                                                                          %C%║
echo. %C%║%R%         [2]%W% Reinstall Microsoft Edge                                                                     %C%║
echo. %C%║%W%                                                                                                          %C%║
echo. %C%║%R%         [3]%W% Enable Bluetooth                                                                             %C%║
echo. %C%║%W%                                                                                                          %C%║
echo. %C%║%R%         [4]%W% Enable Xbox Services                                                                         %C%║
echo. %C%║%W%                                                                                                          %C%║
echo. %C%╠══════════════════════════════════════════════════════════════════════════════════════════════════════════╣
echo. %C%║%W%                                                                                                          %C%║
echo. %C%║%R%         [B] Back                                                                                         %C%║
echo. %C%║%W%                                                                                                          %C%║
echo. %C%╚══════════════════════════════════════════════════════════════════════════════════════════════════════════╝

set /p input=:
if /i %input% == 1 goto UA1
if /i %input% == 2 goto UA2
if /i %input% == 3 goto UA3
if /i %input% == 4 goto UA4
if /i %input% == B goto Advanced
goto Advanced

:UA1
powershell -Command "& {Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.MessageBox]::Show('Choose Enable updates in Windows Update_Blocker.exe, press ok to open it', 'Ra1ner Tweaking Utility', 'Ok', [System.Windows.Forms.MessageBoxIcon]::Information);}"
chcp 65001 > nul

c:\Ra1nerFree\Update_Blocker.exe
goto :UndoAdvanced

:UA2
Start "https://www.microsoft.com/en-us/edge/download?form=MA13FJ"
goto :UndoAdvanced

:UA3
Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\BTAGService" /v "Start" /t REG_DWORD /d "2" /f
Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\bthserv" /v "Start" /t REG_DWORD /d "2" /f
Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\BthAvctpSvc" /v "Start" /t REG_DWORD /d "2" /f
Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\BluetoothUserService" /v "Start" /t REG_DWORD /d "2" /f
goto :UndoAdvanced
goto 
:UA4
sc config xbgm start= demand
sc config XblAuthManager start= demand
sc config XblGameSave start= demand
sc config XboxGipSvc start= demand
sc config XboxNetApiSvc start= demand
goto :UndoAdvanced
