#时间
$Date = ((get-date).AddDays(-1)).ToString("yyyy-MM-dd")
$d1 = ((get-date).AddDays(-1)).ToString("yyyy-MM-dd 00:00:00")
$d2 = ((get-date).AddDays(-1)).ToString("yyyy-MM-dd 23:59:59")

#错误日志
$logs = ((get-date).ToString("yyyyMMddHHmm"))
$logfiles = "c:\logs\register\$logs.txt"

#创建日志目录
if(!(Test-Path c:\logs\register)){New-Item c:\logs\register -type directory -force}

$SqlConnection = New-Object System.Data.SqlClient.SqlConnection
$CnnString ="Server = 124.202.152.104; User Id =stat_reader ; Password = stat_reader123"
$SqlConnection.ConnectionString = $CnnString
#$SqlConnection.Open()
$CC = $SqlConnection.CreateCommand();

$cc.CommandText="declare @hours1 int--快速注册用户 QuickLogin 1
declare @hours2 int--新增注册用户 Activity 2
declare @hours3 int--注册合计     Count 3
SELECT @hours1 = count(1) 
    FROM [KysdGameProxy].[dbo].[Game3Server0Account] where CreateTime between '$d1' and '$d2' and accounttype='QuickLogin'

SELECT @hours2 = count(1)
    FROM [KysdGameProxy].[dbo].[Game3Server0Account] where CreateTime between '$d1' and '$d2' and accounttype='Activity'

select @hours3 = @hours1+@hours2

select cast(@hours1 as varchar(10))  as 'QuickLogin'
select cast(@hours2 as varchar(10))  as 'Activity'
select cast(@hours3 as varchar(10))  as 'Count'

"

$da=New-Object System.Data.SqlClient.SqlDataAdapter($cc)
$dt1=New-Object System.Data.DataSet
try{
    $num=$da.Fill($dt1)
     
}
catch{
    Write-Host "操作错误！"
    $body = $_.Exception.Message 
    $body | out-file -Append -filepath  $logfiles -Force
    $cc.CommandText | out-file -Append -filepath  "$logfiles" -Force

}

#$dt1.tables[0].rows[0][0]
#$dt1.tables[1].rows[0][0]
#$dt1.tables[2].rows[0][0]

$sqltmp=@()
$quick=$dt1.Tables[0].rows[0][0]
if($quick -gt 0){
    $sqltmp+="(1,1,1,1,1,0,'$Date',1,$quick)"
}
$activ=$dt1.Tables[1].rows[0][0]
if($activ -gt 0){
    $sqltmp+="(1,1,1,1,1,0,'$Date',2,$activ)"
}
$count=$dt1.Tables[2].rows[0][0]
if($count -gt 0){
    $sqltmp+="(1,1,1,1,1,0,'$Date',3,$count)"
}

$sqlmore=$sqltmp -join ','

if ($sqlmore.Length -gt 0){

$SqlConnection = New-Object System.Data.SqlClient.SqlConnection
$CnnString ="Server = 10.0.0.106; User Id = sa; Password = password"
$SqlConnection.ConnectionString = $CnnString
$CC = $SqlConnection.CreateCommand();

$cc.CommandText="INSERT INTO [KysdStatisticsDB].[dbo].[Register1Day]([GamesID],[OSID],[OSVersionID],[ChannelID],[SpreadChannelID],[SpreadSubChannelID],[Date],[RegisterTypeID],[Count]) VALUES $sqlmore"
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