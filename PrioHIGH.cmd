@echo off
REM https://winaero.com/change-process-priority-windows-10/
REM PRIORITY LEVELS
REM VALUE   NAME
REM 256     Realtime
REM 128     High
REM 32768   Above normal
REM 32      Normal
REM 16384   Below normal
REM 64      Low
wmic process where name="%1" call setpriority High