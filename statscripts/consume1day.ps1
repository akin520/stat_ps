#log time
$logs = ((get-date).ToString("yyyyMMddHHmm"))
$logfiles = "c:\logs\consume\$logs.txt"

#创建日志目录
if(!(Test-Path c:\logs\consume)){New-Item c:\logs\consume -type directory -force}


$Date = ((get-date).AddDays(-1)).ToString("yyyy-MM-dd")
$tb = ((get-date).AddDays(-1)).ToString("yyyy_MM_dd")

$SqlConnection = New-Object System.Data.SqlClient.SqlConnection
$CnnString ="Server = 10.0.0.106; User Id = sa; Password = password"
$SqlConnection.ConnectionString = $CnnString
$CC = $SqlConnection.CreateCommand();

$cc.CommandText="
use [KysdLogDB]
select a.number,a.usernumber,a.spendsum,b.id from 
(SELECT id,count(1) number,count(distinct(userId)) usernumber,sum(spendAmount) spendsum from [dbo].[consume_$tb] group by id) a,
(select * from spend_gold_type) b
where a.id=b.goods_id  order by a.id desc 
"
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

$sqlmore=(($dt1|select number,usernumber,spendsum,id)|%{
$a=$_.number
$b=$_.usernumber
$c=$_.spendsum
$d=$_.id
"(1,1,1,1,1,0,1,'$Date',$b,$a,$c,$d)"
}) -join ','

$batch_num = $sqlmore.Length
if($batch_num -ge 0){
$cc.CommandText="INSERT INTO [KysdStatisticsDB].[dbo].[Consume1Day] ([GamesID],[OSID],[OSVersionID],[ChannelID],[SpreadChannelID] ,[SpreadSubChannelID],[PayTypeID],[Date],[ConsumeUsers],[ConsumeTimes],[ConsumeIngot],[ConsumeTypeID])  VALUES $sqlmore"
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
