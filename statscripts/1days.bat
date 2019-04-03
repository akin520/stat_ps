@echo off
powershell -File "D:\statscripts\frist_login.ps1"
powershell -File "D:\statscripts\login_time.ps1"
powershell -File "D:\statscripts\consume.ps1"
powershell -File "D:\statscripts\addamount.ps1"
powershell -File "D:\statscripts\login.ps1"

rem œ¬‘ÿÕ≥º∆
powershell -File "D:\statscripts\download1day.ps1"

rem register 
powershell -File "D:\statscripts\register1day.ps1"

rem onlineday
powershell -File "D:\statscripts\online1day.ps1"

rem consume1day
powershell -File "D:\statscripts\consume1day.ps1"

rem loginday
powershell -File "D:\statscripts\pt_frist_login_1day.ps1"

rem order1day
powershell -File "D:\statscripts\order1day.ps1"
powershell -File "D:\statscripts\pt_pay_frist_1day.ps1"

rem end
powershell -File "D:\statscripts\channel1day.ps1"

rem retained
::powershell -File "D:\statscripts\retained1day.ps1"
powershell -File "D:\statscripts\retained1day2.ps1"