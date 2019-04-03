#时间
$Date = ((get-date).AddHours(-1)).ToString("yyyy-MM-dd")
$Hours = ((get-date).AddHours(-1)).ToString("HH")
$d1 = ((get-date).AddHours(-1)).ToString("yyyy-MM-dd HH:00:00")
$d2 = ((get-date).AddHours(-1)).ToString("yyyy-MM-dd HH:59:59")

#错误日志
$logs = ((get-date).ToString("yyyyMMddHHmm"))
$logfiles = "c:\logs\login\$logs.txt"

#创建日志目录
if(!(Test-Path c:\logs\login)){New-Item c:\logs\login -type directory -force}

$SqlConnection = New-Object System.Data.SqlClient.SqlConnection
$CnnString ="Server = 124.202.152.104; User Id =stat_reader ; Password = stat_reader123"
$SqlConnection.ConnectionString = $CnnString
$CC = $SqlConnection.CreateCommand();

$cc.CommandText="USE [KysdAnySdkDB]
select count(distinct(a.UserId)) users,b.ChannelId,avg(b.GameId) gameId from 
(select * from [dbo].[LoginLogUserInfo] where CreateDate between '$d1' and '$d2') a,
(select * from [dbo].[LoginLog]) b
where a.loginlogid=b.id group by b.ChannelId
"

$da=New-Object System.Data.SqlClient.SqlDataAdapter($cc)
$dt1=New-Object System.Data.DataTable
try{
    $num=$da.Fill($dt1)
     
}
catch{
    Write-Host "操作错误！"
    $body = $_.Exception.Message 
    $body | out-file -Append -filepath  $logfiles -Force
    $cc.CommandText | out-file -Append -filepath  "$logfiles" -Force

}

$sqlmore=@()
$sql1=($dt1|select users,ChannelId, gameId)|%{
$GamesID=$_.gameId
$a = $_.ChannelId
switch ($a)
{      
    1000 { $ChannelId = 1 }
    1001 { $ChannelId = 3 }
    1002 { $ChannelId = 2 }
    1003 { $ChannelId = 4 }
    default { $ChannelId = 0 }
}
$SpreadChannelID=$ChannelId

$count = $_.users
"($GamesID,1,1,$ChannelId,$SpreadChannelID,0,'$Date','$Hours',2,$count)"
}
$sqlmore+=$sql1

$sqltmp = $sqlmore -join ','

#统计库
$SqlConnection = New-Object System.Data.SqlClient.SqlConnection
$CnnString ="Server = 10.0.0.106; User Id =sa ; Password = password"
$SqlConnection.ConnectionString = $CnnString
$CC = $SqlConnection.CreateCommand();

$cc.CommandText="INSERT INTO [KysdStatisticsDB].[dbo].[Login1Hour] ([GamesID],[OSID],[OSVersionID],[ChannelID],[SpreadChannelID],[SpreadSubChannelID],[Date],[Hour],[LoginTypeID],[Count]) VALUES $sqltmp"
$da=New-Object System.Data.SqlClient.SqlDataAdapter($cc)
$dt1=New-Object System.Data.DataTable

$batch_num = $sqlmore.count
if($batch_num -lt 0 ){
    Write-Host "null"
}else{
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