::== timer2.bat
@echo off
set start=%TIME%
call BackupCopy.BAT
echo started at %START%>logfile
echo done at %TIME%>>logfile
:: DONE