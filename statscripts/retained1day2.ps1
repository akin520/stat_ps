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

#留存表记录基数
$cc.CommandText="select ChannelId,count(1) Count from [KysdLogDB].[dbo].[pt_frist_$tabletime] group by ChannelId"
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

<#
pt:
Id	ChannelName
1000	快鱼时代平台
1001	酷派
1002	搜狗平台
1003	电信平台
stat:
ID	Name
1	快鱼时代
2	搜狗
3	酷派
4	电信
#>
$sql=($dt1|select ChannelId,Count)|%{
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
$b = $_.Count

"(1,1,1,$ChannelId,$SpreadChannelID,0,'$Date',$b)"
}


if ($num -gt 0){
    $a=$sql -join ','
    $cc.CommandText="INSERT INTO [KysdStatisticsDB].[dbo].[Retained] ([GamesID],[OSID],[OSVersionID],[ChannelID],[SpreadChannelID],[SpreadSubChannelID],[Date],[TodayLoginCount]) VALUES $a"
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

$cc.CommandText="select  a.ChannelId,count(1) Count from [KysdLogDB].[dbo].[pt_frist_$2day] a inner join [KysdLogDB].[dbo].[pt_login_$1day] b on a.ChannelUserId=b.UserId group by a.ChannelId"
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
$sql=($dt1|select ChannelId,Count)|%{
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
$b = $_.Count

"update [KysdStatisticsDB].[dbo].[Retained] set SecondDayRetention=$b where Date='$2Date' and SpreadChannelID=$SpreadChannelID and ChannelId=$ChannelId"
}

foreach($sqltmp in $sql){
$cc.CommandText="$sqltmp"
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

}


#三日留存 第5天算
$3Date = ((get-date).AddDays(-4)).ToString("yyyy-MM-dd")
$1day=((get-date).AddDays(-1)).ToString("yyyy_MM_dd")
$2day=((get-date).AddDays(-2)).ToString("yyyy_MM_dd")
$3day=((get-date).AddDays(-4)).ToString("yyyy_MM_dd")

$cc.CommandText="use [KysdLogDB]
select a.ChannelId,count(distinct(a.ChannelUserId)) Count from [KysdLogDB].[dbo].[pt_frist_$3day] a inner join (
select * from [dbo].[pt_login_$1day]
union 
select * from [dbo].[pt_login_$2day]) b
on a.ChannelUserId=b.UserId group by a.ChannelId"

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

$sql=($dt1|select ChannelId,Count)|%{
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
$b = $_.Count

"update [KysdStatisticsDB].[dbo].[Retained] set ThirdDayRetention=$b where Date='$3Date' and SpreadChannelID=$SpreadChannelID and ChannelId=$ChannelId"
}

foreach($sqltmp in $sql){
$cc.CommandText="$sqltmp"
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

}


#七日留存 第10天算
$7Date = ((get-date).AddDays(-9)).ToString("yyyy-MM-dd")
$1day=((get-date).AddDays(-1)).ToString("yyyy_MM_dd")
$2day=((get-date).AddDays(-2)).ToString("yyyy_MM_dd")
$3day=((get-date).AddDays(-3)).ToString("yyyy_MM_dd")
$7day=((get-date).AddDays(-9)).ToString("yyyy_MM_dd")

$cc.CommandText="use [KysdLogDB]
select a.ChannelId,count(distinct(a.ChannelUserId)) Count from [KysdLogDB].[dbo].[pt_frist_$7day] a inner join (
select * from [dbo].[pt_login_$1day]
union 
select * from [dbo].[pt_login_$2day]
union
select * from [dbo].[pt_login_$3day]) b
on a.ChannelUserId=b.UserId group by a.ChannelId "

$da=New-Object System.Data.SqlClient.SqlDataAdapter($cc)
$dt1=New-Object System.Data.DataTable
try{
    $num=$da.Fill($dt1)
     
}
catch{
    Write-Host "七日留存错误！"
    $body = $_.Exception.Message 
    $body | out-file -Append -filepath  "d:\2retained.txt" -Force
    $cc.CommandText | out-file -Append -filepath  "d:\2retained.txt" -Force

}

if($dt1 -ne $null){

$sql=($dt1|select ChannelId,Count)|%{
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
$b = $_.Count

"update [KysdStatisticsDB].[dbo].[Retained] set SeventhDayRetention=$b where Date='$7Date' and SpreadChannelID=$SpreadChannelID and ChannelId=$ChannelId"
}

foreach($sqltmp in $sql){
$cc.CommandText="$sqltmp"
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

}



#十五日留存 第18天算
$15Date = ((get-date).AddDays(-17)).ToString("yyyy-MM-dd")
$1day=((get-date).AddDays(-1)).ToString("yyyy_MM_dd")
$2day=((get-date).AddDays(-2)).ToString("yyyy_MM_dd")
$3day=((get-date).AddDays(-3)).ToString("yyyy_MM_dd")
$15day=((get-date).AddDays(-17)).ToString("yyyy_MM_dd")

$cc.CommandText="use [KysdLogDB]
select a.ChannelId,count(distinct(a.ChannelUserId)) Count from [KysdLogDB].[dbo].[pt_frist_$15day] a inner join (
select * from [dbo].[pt_login_$1day]
union 
select * from [dbo].[pt_login_$2day]
union
select * from [dbo].[pt_login_$3day]) b
on a.ChannelUserId=b.UserId group by a.ChannelId "

$da=New-Object System.Data.SqlClient.SqlDataAdapter($cc)
$dt1=New-Object System.Data.DataTable
try{
    $num=$da.Fill($dt1)
     
}
catch{
    Write-Host "十五日留存错误！"
    $body = $_.Exception.Message 
    $body | out-file -Append -filepath  "d:\2retained.txt" -Force
    $cc.CommandText | out-file -Append -filepath  "d:\2retained.txt" -Force

}

if($dt1 -ne $null){

$sql=($dt1|select ChannelId,Count)|%{
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
$b = $_.Count

"update [KysdStatisticsDB].[dbo].[Retained] set FiftiethDayRetention=$b where Date='$15Date' and SpreadChannelID=$SpreadChannelID and ChannelId=$ChannelId"
}

foreach($sqltmp in $sql){
$cc.CommandText="$sqltmp"
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

}


#三十日留存 第33天算
$30Date = ((get-date).AddDays(-32)).ToString("yyyy-MM-dd")
$1day=((get-date).AddDays(-1)).ToString("yyyy_MM_dd")
$2day=((get-date).AddDays(-2)).ToString("yyyy_MM_dd")
$3day=((get-date).AddDays(-3)).ToString("yyyy_MM_dd")
$30day=((get-date).AddDays(-32)).ToString("yyyy_MM_dd")

$cc.CommandText="use [KysdLogDB]
select a.ChannelId,count(distinct(a.ChannelUserId)) Count from [KysdLogDB].[dbo].[pt_frist_$30day] a inner join (
select * from [dbo].[pt_login_$1day]
union 
select * from [dbo].[pt_login_$2day]
union
select * from [dbo].[pt_login_$3day]) b
on a.ChannelUserId=b.UserId group by a.ChannelId "

$da=New-Object System.Data.SqlClient.SqlDataAdapter($cc)
$dt1=New-Object System.Data.DataTable
try{
    $num=$da.Fill($dt1)
     
}
catch{
    Write-Host "三十日留存错误！"
    $body = $_.Exception.Message 
    $body | out-file -Append -filepath  "d:\2retained.txt" -Force
    $cc.CommandText | out-file -Append -filepath  "d:\2retained.txt" -Force

}

if($dt1 -ne $null){

$sql=($dt1|select ChannelId,Count)|%{
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
$b = $_.Count

"update [KysdStatisticsDB].[dbo].[Retained] set ThirtiethDayRetention=$b where Date='$30Date' and SpreadChannelID=$SpreadChannelID and ChannelId=$ChannelId"
}

foreach($sqltmp in $sql){
$cc.CommandText="$sqltmp"
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

}


exit