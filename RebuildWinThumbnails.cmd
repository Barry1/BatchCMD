REM inspired by https://www.windowscentral.com/how-reset-thumbnail-cache-windows-10
REM archived also under https://archive.ph/5FY7W
REM also check https://github.com/bruhov/WinThumbsPreloader

:: Information regarding UAC
:: https://stackoverflow.com/questions/1894967/how-to-request-administrator-access-inside-a-batch-file
@ECHO OFF
IF NOT "%1"=="MAX" (powershell -WindowStyle Hidden -NoProfile -Command {Start-Process CMD -ArgumentList '/D,/C' -Verb RunAs} & START /MAX CMD /D /C %0 MAX & EXIT /B)
:--------------------------------------------------------------------------------------------------------------------------------------------------------------------
taskkill /f /im explorer.exe
del /f /s /q /a %LocalAppData%\Microsoft\Windows\Explorer\thumbcache_*.db
start explorer.exe
:--------------------------------------------------------------------------------------------------------------------------------------------------------------------
