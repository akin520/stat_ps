@echo off
rem download
powershell -File "D:\statscripts\download1time.ps1"

rem register
powershell -File "D:\statscripts\register1time.ps1"

rem online
powershell -File "D:\statscripts\online1time.ps1"

rem login1time
powershell -File "D:\statscripts\ptlogin1time.ps1"

