#时间
$Date = ((get-date).AddDays(-1)).ToString("yyyy-MM-dd")
$tabletime = ((get-date).adddays(-1)).ToString("yyyy_MM_dd")

#错误日志
$logs = ((get-date).ToString("yyyyMMddHHmm"))
$logfiles = "c:\logs\retained\$logs.txt"

#创建日志目录
if(!(Test-Path c:\logs\retained)){New-Item c:\logs\retained -type directory -force}

#conn stat mssql
$SqlConnection = New-Object System.Data.SqlClient.SqlConnection
$CnnString ="Server = 10.0.0.106; User Id = sa; Password = password"
$SqlConnection.ConnectionString = $CnnString
$CC = $SqlConnection.CreateCommand();

#流存表记录基数
$cc.CommandText="select count(1) TodayLoginCount from [KysdLogDB].[dbo].[pt_frist_$tabletime]"
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

if ($num -gt 0){
    $a=($dt1|select TodayLoginCount)|%{$_.TodayLoginCount}
    $cc.CommandText="
if exists(select * from [KysdStatisticsDB].[dbo].[Retained] where Date = '$Date') begin;
    update [KysdStatisticsDB].[dbo].[Retained] set TodayLoginCount=$a where Date='$Date'
end;
else begin;
    INSERT INTO [KysdStatisticsDB].[dbo].[Retained] ([GamesID],[OSID],[OSVersionID],[ChannelID],[SpreadChannelID],[SpreadSubChannelID],[Date],[TodayLoginCount]) VALUES (1,1,1,1,1,0,'$Date',$a)
end;
"
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
}


#次日留存 第3天算
$2Date = ((get-date).AddDays(-2)).ToString("yyyy-MM-dd")
$1day=((get-date).AddDays(-1)).ToString("yyyy_MM_dd")
$2day=((get-date).AddDays(-2)).ToString("yyyy_MM_dd")

$cc.CommandText="select  count(1) SecondDayRetention from [KysdLogDB].[dbo].[pt_frist_$2day] a inner join [KysdLogDB].[dbo].[pt_login_$1day] b on a.ChannelUserId=b.UserId"
$da=New-Object System.Data.SqlClient.SqlDataAdapter($cc)
$dt1=New-Object System.Data.DataTable
try{
    $num=$da.Fill($dt1)
     
}
catch{
    Write-Host "次日留存错误！"
    $body = $_.Exception.Message 
    $body | out-file -Append -filepath  "d:\2retained.txt" -Force
    $cc.CommandText | out-file -Append -filepath  "d:\2retained.txt" -Force

}

if($dt1 -ne $null){

$a=($dt1|select SecondDayRetention)|%{$_.SecondDayRetention}
$cc.CommandText="update [KysdStatisticsDB].[dbo].[Retained] set SecondDayRetention=$a where Date='$2Date'"
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

}




#三日留存 第5天算
$3Date = ((get-date).AddDays(-4)).ToString("yyyy-MM-dd")
$1day=((get-date).AddDays(-1)).ToString("yyyy_MM_dd")
$2day=((get-date).AddDays(-2)).ToString("yyyy_MM_dd")
$3day=((get-date).AddDays(-4)).ToString("yyyy_MM_dd")

$cc.CommandText="use [KysdLogDB]
select sum(a.number) ThirdDayRetention from (
select count(distinct(a.ChannelUserId)) number from [KysdLogDB].[dbo].[pt_frist_$3day] a inner join (
select * from [dbo].[pt_login_$1day]
union 
select * from [dbo].[pt_login_$2day]) b
on a.ChannelUserId=b.UserId group by a.ChannelId) a"

$da=New-Object System.Data.SqlClient.SqlDataAdapter($cc)
$dt1=New-Object System.Data.DataTable
try{
    $num=$da.Fill($dt1)
     
}
catch{
    Write-Host "三日留存错误！"
    $body = $_.Exception.Message 
    $body | out-file -Append -filepath  "d:\2retained.txt" -Force
    $cc.CommandText | out-file -Append -filepath  "d:\2retained.txt" -Force

}

if($dt1 -ne $null){

$a=($dt1|select ThirdDayRetention)|%{$_.ThirdDayRetention}
$cc.CommandText="update [KysdStatisticsDB].[dbo].[Retained] set ThirdDayRetention=$a where Date='$3Date'"
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

}








exit