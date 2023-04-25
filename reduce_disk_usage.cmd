REM i/o reducing script for terminal servers
REM aims to srsly reduce the amount of i/o stupid programs use
REM without breaking them; do this by replacing folder with a file
REM stupid programs just silently continue working without all that disk i/o

REM service workers are the worst
rd /s /q "%AppData%\Microsoft\Teams\Service Worker\CacheStorage"
echo %date% > "%AppData%\Microsoft\Teams\Service Worker\CacheStorage"

rd /s /q "%LocalAppData%\Google\Chrome\User Data\Default\Service Worker\CacheStorage"
echo %date% > "%LocalAppData%\Google\Chrome\User Data\Default\Service Worker\CacheStorage"
rd /s /q "%LocalAppData%\Google\Chrome\User Data\Profile 1\Service Worker\CacheStorage"
echo %date% > "%LocalAppData%\Google\Chrome\User Data\Profile 1\Service Worker\CacheStorage"
rd /s /q "%LocalAppData%\Google\Chrome\User Data\Profile 2\Service Worker\CacheStorage"
echo %date% > "%LocalAppData%\Google\Chrome\User Data\Profile 2\Service Worker\CacheStorage"

rd /s /q "%LocalAppData%\Microsoft\Edge\User Data\Default\Service Worker\CacheStorage"
echo %date% > "%LocalAppData%\Microsoft\Edge\User Data\Default\Service Worker\CacheStorage"
rd /s /q "%LocalAppData%\BraveSoftware\Brave-Browser\User Data\Default\Service Worker\CacheStorage"
echo %date% > "%LocalAppData%\BraveSoftware\Brave-Browser\User Data\Default\Service Worker\CacheStorage"

REM office diagnostics are also bad
rd /s /q %Temp%\Diagnostics
echo %date% > %Temp%\Diagnostics
rd /s /q "%Temp%\Outlook Logging"
echo %date% > "%Temp%\Outlook Logging"
