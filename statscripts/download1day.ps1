#时间
$Date = ((get-date).AddDays(-1)).ToString("yyyy-MM-dd")
$d1 = ((get-date).AddDays(-1)).ToString("yyyy-MM-dd 00:00:00")
$d2 = ((get-date).AddDays(-1)).ToString("yyyy-MM-dd 23:59:59")

#错误日志
$logs = ((get-date).ToString("yyyyMMddHHmm"))
$logfiles = "c:\logs\download\$logs.txt"

#创建日志目录
if(!(Test-Path c:\logs\download)){New-Item c:\logs\download -type directory -force}

$SqlConnection = New-Object System.Data.SqlClient.SqlConnection
$CnnString ="Server = 124.202.152.104; User Id =stat_reader ; Password = stat_reader123"
$SqlConnection.ConnectionString = $CnnString
#$SqlConnection.Open()
$CC = $SqlConnection.CreateCommand();

$cc.CommandText="select code,count(1) as count from [WebManageSystem].[dbo].[BzDownloadLogs] where code in (4,6) and time between '$d1' and '$d2' group by code"
#select code,count(distinct(ip)) as countip from [WebManageSystem].[dbo].[BzDownloadLogs] where time between '$d1' and '$d2' group by code
#$cc.CommandText="select code,count(1) as count from [WebManageSystem].[dbo].[BzDownloadLogs] where time between '2014-08-01' and '2014-08-02' group by code"
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
$sql1=($dt1|select code,count)|%{
$a = $_.code
<#
switch ($a)
{      
    2 { $code = 0 }
    4 { $code = 5 }
    6 { $code = 1 }
    7 { $code = 7 }
    8 { $code = 8 }
    9 { $code = 9 }
    10 {$code = 10 }
    default { $code = 0 }
}#>

$count = $_.count
"(1,1,1,1,1,0,'$Date',$a,$count)"
}
$sqlmore+=$sql1

#去重
$cc.CommandText="select code,count(distinct(ip)) as countip from [WebManageSystem].[dbo].[BzDownloadLogs] where code in (4,6) and time between '$d1' and '$d2' group by code"
$da2=New-Object System.Data.SqlClient.SqlDataAdapter($cc)
$dt2=New-Object System.Data.DataTable
try{
    $num=$da2.Fill($dt2)
     
}
catch{
    Write-Host "操作错误！"
    $body = $_.Exception.Message 
    $body | out-file -Append -filepath  $logfiles -Force
    $cc.CommandText | out-file -Append -filepath  "$logfiles" -Force

}

$sql2=($dt2|select code,countip)|%{
$a = $_.code+10000
$count = $_.countip
"(1,1,1,1,1,0,'$Date',$a,$count)"
}
$sqlmore+=$sql2

$sqltmp = $sqlmore -join ','

#统计库
$SqlConnection = New-Object System.Data.SqlClient.SqlConnection
$CnnString ="Server = 10.0.0.106; User Id =sa ; Password = password"
$SqlConnection.ConnectionString = $CnnString
$CC = $SqlConnection.CreateCommand();

$cc.CommandText="DELETE FROM [KysdStatisticsDB].[dbo].[Download1Day] where Date='$Date'
INSERT INTO [KysdStatisticsDB].[dbo].[Download1Day] ([GamesID],[OSID],[OSVersionID],[ChannelID],[SpreadChannelID],[SpreadSubChannelID],[Date],[DownLoadTypeID],[Count]) VALUES $sqltmp"
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