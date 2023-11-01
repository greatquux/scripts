REM i/o reducing script for terminal servers
REM aims to srsly reduce the amount of i/o stupid programs use
REM without breaking them; do this by replacing folder with a file
REM stupid programs just silently continue working without all that disk i/o
REM make sure this starts up in user session - place in
REM C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp

@ECHO OFF
SET logfile=%temp%\reduce_disk_usage.log
echo "Running reduce_disk_usage script for %USERNAME% at %DATE% %TIME%" > %logfile% 2>&1

REM try to install these registry entries to disable I/O-hogging logging
reg add HKCU\Policies\Microsoft\office\16.0\Outlook\Logging /v DisableDefaultLogging  /t REG_DWORD /d 1 /f
reg add HKCU\Policies\Microsoft\office\16.0\Excel\Logging /v DisableDefaultLogging  /t REG_DWORD /d 1 /f
reg add HKCU\Policies\Microsoft\office\16.0\Word\Logging /v DisableDefaultLogging  /t REG_DWORD /d 1 /f
reg add HKCU\Policies\Microsoft\office\16.0\PowerPoint\Logging /v DisableDefaultLogging  /t REG_DWORD /d 1 /f
reg add HKCU\Policies\Microsoft\office\16.0\Publisher\Logging /v DisableDefaultLogging  /t REG_DWORD /d 1 /f
reg add HKCU\Policies\Microsoft\office\16.0\Access\Logging /v DisableDefaultLogging  /t REG_DWORD /d 1 /f

REM disable office telemetry because it uses too much I/O also
reg add HKCU\Software\Policies\Microsoft\Office\16.0\Common /v QMEnable /t REG_DWORD /d 0 /f
reg add HKCU\Software\Policies\Microsoft\Office\16.0\Common /v SendCustomerData /t REG_DWORD /d 0 /f
reg add HKCU\Software\Policies\Microsoft\Office\16.0\osm /v EnableLogging /t REG_DWORD /d 0 /f
reg add HKCU\Software\Policies\Microsoft\Office\16.0\osm /v EnableFileObfuscation /t REG_DWORD /d 1 /f
reg add HKCU\Software\Policies\Microsoft\Office\16.0\osm /v EnableUpload /t REG_DWORD /d 0 /f
reg add HKCU\Software\Policies\Microsoft\Office\Common\ClientTelemetry /v DisableTelemetry /t REG_DWORD /d 1 /f
reg add HKCU\Software\Policies\Microsoft\Office\Common\ClientTelemetry /v SendTelemetry /t REG_DWORD /d 3 /f


REM office diagnostics are i/o intensive, try to do this first
rd /s /q "%Temp%\Outlook Logging" >> %logfile% 2>&1
REM alternate approach - disallow any access
mkdir "%Temp%\Outlook Logging" >> %logfile% 2>&1
echo y|cacls "%Temp%\Outlook Logging" /d %USERNAME% >> %logfile% 2>&1
REM mklink /j "%Temp%\Outlook Logging" null >> %logfile% 2>&1
rd /s /q %Temp%\Diagnostics >> %logfile% 2>&1
mkdir %Temp%\Diagnostics >> %logfile% 2>&1
echo y|cacls %Temp%\Diagnostics /d %USERNAME% >> %logfile% 2>&1
REM mklink /j %Temp%\Diagnostics null >> %logfile% 2>&1

REM service workers are the worst for i/o
REM mkdir in case cleanup script removed it
mkdir "%AppData%\Microsoft\Teams\Service Worker"  >> %logfile% 2>&1
rd /s /q "%AppData%\Microsoft\Teams\Service Worker\CacheStorage" >> %logfile% 2>&1
echo "%date%" > "%AppData%\Microsoft\Teams\Service Worker\CacheStorage" >> %logfile% 2>&1
attrib +r "%AppData%\Microsoft\Teams\Service Worker\CacheStorage" >> %logfile% 2>&1

rd /s /q "%LocalAppData%\Google\Chrome\User Data\Default\Service Worker\CacheStorage" >> %logfile% 2>&1
echo "%date%" > "%LocalAppData%\Google\Chrome\User Data\Default\Service Worker\CacheStorage" >> %logfile% 2>&1
rd /s /q "%LocalAppData%\Google\Chrome\User Data\Profile 1\Service Worker\CacheStorage" >> %logfile% 2>&1
echo "%date%" > "%LocalAppData%\Google\Chrome\User Data\Profile 1\Service Worker\CacheStorage" >> %logfile% 2>&1
rd /s /q "%LocalAppData%\Google\Chrome\User Data\Profile 2\Service Worker\CacheStorage" >> %logfile% 2>&1
echo "%date%" > "%LocalAppData%\Google\Chrome\User Data\Profile 2\Service Worker\CacheStorage" >> %logfile% 2>&1
rd /s /q "%LocalAppData%\Google\Chrome\User Data\Guest Profile\Service Worker\CacheStorage" >> %logfile% 2>&1
echo "%date%" > "%LocalAppData%\Google\Chrome\User Data\Guest Profile\Service Worker\CacheStorage" >> %logfile% 2>&1

rd /s /q "%LocalAppData%\Microsoft\Edge\User Data\Default\Service Worker\CacheStorage" >> %logfile% 2>&1
echo "%date%" > "%LocalAppData%\Microsoft\Edge\User Data\Default\Service Worker\CacheStorage" >> %logfile% 2>&1
rd /s /q "%LocalAppData%\BraveSoftware\Brave-Browser\User Data\Default\Service Worker\CacheStorage" >> %logfile% 2>&1
echo "%date%" > "%LocalAppData%\BraveSoftware\Brave-Browser\User Data\Default\Service Worker\CacheStorage" >> %logfile% 2>&1


REM stop Teams from automatically starting up
reg delete HKCU\Software\Microsoft\Windows\CurrentVersion\Run /v com.squirrel.Teams.Teams /f
