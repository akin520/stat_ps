#在线人数
$logs = ((get-date).ToString("yyyyMMddHHmm"))
$logfiles = "c:\logs\online\$logs.txt"

#创建日志目录
if(!(Test-Path c:\logs\online)){New-Item c:\logs\online -type directory -force}


$Date = ((get-date).AddDays(-1)).ToString("yyyy-MM-dd")
$d1 = ((get-date).AddDays(-1)).ToString("yyyy-MM-dd 00:00:00")
$d2 = ((get-date).AddDays(-1)).ToString("yyyy-MM-dd 23:59:59")


$SqlConnection = New-Object System.Data.SqlClient.SqlConnection
$CnnString ="Server = 10.0.0.106; User Id = sa; Password = password"
$SqlConnection.ConnectionString = $CnnString
$CC = $SqlConnection.CreateCommand();

$cc.CommandText="SELECT MIN(OnlineCount) as mincount,AVG(OnlineCount) as avgcount,MAX(OnlineCount) as maxcount FROM [KysdStatisticsDB].[dbo].[OnlineRealTime] where DateTime between '$d1' and '$d2'"
$dt1=New-Object System.Data.DataTable
$da=New-Object System.Data.SqlClient.SqlDataAdapter($cc)
try{
    $num=$da.Fill($dt1)     
}
catch{
    Write-Host "操作错误！"
    $body = $_.Exception.Message 
    $body | out-file -Append -filepath  $logfiles -Force
    $cc.CommandText | out-file -Append -filepath  "$logfiles" -Force

}

$sqlmore=(($dt1|select mincount,avgcount,maxcount)|%{
$a=$_.mincount
$b=$_.avgcount
$c=$_.maxcount
"(1,1,1,1,1,0,'$Date',$a,$b,$c)"
}) -join ','

$batch_num = $sqlmore.count
if($batch_num -ge 0){
$cc.CommandText="INSERT INTO [KysdStatisticsDB].[dbo].[Online1Day] ([GamesID],[OSID],[OSVersionID],[ChannelID],[SpreadChannelID] ,[SpreadSubChannelID],[Date],[MinOnlineCount],[AvgOnlineCount],[MaxOnlineCount])  VALUES $sqlmore"
$dt1=New-Object System.Data.DataTable
$da=New-Object System.Data.SqlClient.SqlDataAdapter($cc)
try{
    $num=$da.Fill($dt1)     
}
catch{
    Write-Host "操作错误！"
    $body = $_.Exception.Message 
    $body | out-file -Append -filepath  $logfiles -Force
    $cc.CommandText | out-file -Append -filepath  "$logfiles" -Force

}
}


exit
