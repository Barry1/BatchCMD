' inspired by https://www.windowscentral.com/how-reset-thumbnail-cache-windows-10
taskkill /f /im explorer.exe
del /f /s /q /a %LocalAppData%\Microsoft\Windows\Explorer\thumbcache_*.db
start explorer.exe
