#win2008r2 install snmp 
#wirte by akin520
Import-Module ServerManager
if( ! (Test-Path c:\snmpinstall-ok) ){
    $check = Get-WindowsFeature | Where-Object {$_.Name -eq "SNMP-Services"}
    If ($check.Installed -ne "True") {
        #Install/Enable SNMP Services
        Add-WindowsFeature SNMP-Services | Out-Null
        $checkok = Get-WindowsFeature | Where-Object {$_.Name -eq "SNMP-Services"}
        If ($checkok.Installed -eq "True"){
        reg delete "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\SNMP\Parameters\PermittedManagers" /va /f | Out-Null
        reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\SNMP\Parameters\ValidCommunities" /v "kysd" /t REG_DWORD /d 4 /f | Out-Null
        New-Item -path c:\snmpinstall-ok -type file -force
        }
    }  
    Else{
        Write-Host "Error: SNMP Services Not Installed"
    }
}else{
    Write-Host "file ok!"
}