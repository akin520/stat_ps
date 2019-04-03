@echo off
winrm quickconfig -q
winrm set winrm/config/client @{TrustedHosts="*"}
ftype Microsoft.PowerShellScript.1="%SystemRoot%\system32\windowspowershell\v1.0\powershell.exe" ".\"%1""
"%SystemRoot%\system32\windowspowershell\v1.0\powershell.exe" set-executionpolicy remotesigned
pause