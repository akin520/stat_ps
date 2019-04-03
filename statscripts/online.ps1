#5分钟在线人数
Import-Module C:\Windows\System32\WindowsPowerShell\v1.0\Modules\PowerRedis
#解除锁定
#Get-ChildItem -Path  C:\Windows\System32\WindowsPowerShell\v1.0\Modules\PowerRedis -Recurse |  Unblock-File

#help
#(get-module –list PowerRedis).ExportedCmdlets

$d1 = ((get-date).ToString("yyyy-MM-dd HH:mm"))
$logs = ((get-date).ToString("yyyyMMddHHmm"))
$logfiles = "c:\logs\online\$logs.txt"

#创建日志目录
if(!(Test-Path c:\logs\online)){New-Item c:\logs\online -type directory -force}


$conn = Connect-RedisServer -RedisServer "10.0.1.92"
$users = Search-RedisKeys "bzsg_user.*"
DisConnect-RedisServer

if($users -eq $null){
    $num = 0
}else{
    $num = ($users|Measure-Object|select Count).Count
}
$num

$SqlConnection = New-Object System.Data.SqlClient.SqlConnection
$CnnString ="Server = 10.0.0.106; User Id = sa; Password = password"
$SqlConnection.ConnectionString = $CnnString
$CC = $SqlConnection.CreateCommand();

$cc.CommandText="INSERT INTO [KysdStatisticsDB].[dbo].[OnlineRealTime] ([GamesID],[OSID],[OSVersionID],[ChannelID],[SpreadChannelID] ,[SpreadSubChannelID],[DateTime],[OnlineCount]) VALUES (1,1,1,1,1,0,'$d1',$num)"
$dt1=New-Object System.Data.DataTable
$da=New-Object System.Data.SqlClient.SqlDataAdapter($cc)
try{
    $null=$da.Fill($dt1)     
}
catch{
    Write-Host "操作错误！"
    $body = $_.Exception.Message 
    $body | out-file -Append -filepath  $logfiles -Force
    $cc.CommandText | out-file -Append -filepath  "$logfiles" -Force

}
exit
