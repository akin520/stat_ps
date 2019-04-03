#时间
$Date = ((get-date).AddDays(-1)).ToString("yyyy-MM-dd")
$d1 = ((get-date).AddDays(-1)).ToString("yyyy-MM-dd 00:00:00")
$d2 = ((get-date).AddDays(-1)).ToString("yyyy-MM-dd 23:59:59")

#错误日志
$logs = ((get-date).ToString("yyyyMMddHHmm"))
$logfiles = "c:\logs\pay\$logs.txt"

#创建日志目录
if(!(Test-Path c:\logs\pay)){New-Item c:\logs\pay -type directory -force}

$SqlConnection = New-Object System.Data.SqlClient.SqlConnection
$CnnString ="Server = 124.202.152.104; User Id =stat_reader ; Password = stat_reader123"
$SqlConnection.ConnectionString = $CnnString
$CC = $SqlConnection.CreateCommand();

#总付费
$cc.CommandText="select ChannelId,count(distinct(ChannelUserId)) PayUsers,count(1) PayTimes,cast(sum(RealAmount*100) as int) PayRMBCents from [KysdAnySdkDB].[dbo].[ChangeOrder] where UpdateDate between '$d1' and '$d2' and OrderStatus='SUCCESS' group by ChannelId
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


#首登付费统计
$cc.CommandText="SELECT ChannelId,count(distinct(ChannelUserId)) FirstLoginPayUsers,sum(FirstChargeCent) FirstLoginPayRMBCents
	FROM [KysdAnySdkDB].[dbo].[ChannelUser] where createTime between '$d1' and '$d2' and convert(varchar(10),CreateTime, 20)=convert(varchar(10),FirstChargeTime, 20)
	group by ChannelId
"

$da=New-Object System.Data.SqlClient.SqlDataAdapter($cc)
$dt2=New-Object System.Data.DataTable
try{
    $num=$da.Fill($dt2)
     
}
catch{
    Write-Host "操作错误！"
    $body = $_.Exception.Message 
    $body | out-file -Append -filepath  $logfiles -Force
    $cc.CommandText | out-file -Append -filepath  "$logfiles" -Force

}


#首充付费统计
<#08.08
$cc.CommandText="SELECT ChannelId,count(distinct(ChannelUserId)) FirstPayUsers,sum(FirstChargeCent) FirstPayRMBCents
	FROM [KysdAnySdkDB].[dbo].[ChannelUser] where FirstChargeTime between '$d1' and '$d2' and convert(varchar(10),CreateTime, 20)!=convert(varchar(10),FirstChargeTime, 20)
	group by ChannelId
"
#>
$cc.CommandText="SELECT ChannelId,count(distinct(ChannelUserId)) FirstPayUsers,sum(FirstChargeCent) FirstPayRMBCents
	FROM [KysdAnySdkDB].[dbo].[ChannelUser] where FirstChargeTime between '$d1' and '$d2' group by ChannelId
"

$da=New-Object System.Data.SqlClient.SqlDataAdapter($cc)
$dt3=New-Object System.Data.DataTable
try{
    $num=$da.Fill($dt3)
     
}
catch{
    Write-Host "操作错误！"
    $body = $_.Exception.Message 
    $body | out-file -Append -filepath  $logfiles -Force
    $cc.CommandText | out-file -Append -filepath  "$logfiles" -Force

}


#$qq=""|select ChannelId,PayUsers,PayTimes,PayRMBCents,FirstLoginPayRMBCents,FirstLoginPayUsers,FirstPayUsers,FirstPayRMBCents
$sql1=@()

#更新后要添加
1000..1003|%{
    $cid=""|select ChannelId
    $cid.ChannelId = $_
    $sql1+=$cid
}

$sql1=$sql1|select *,PayUsers,PayTimes,PayRMBCents
foreach($i in $sql1){
    $i.PayUsers = ($dt1|?{$_.ChannelId -eq $i.ChannelId}).PayUsers
    $i.PayTimes = ($dt1|?{$_.ChannelId -eq $i.ChannelId}).PayTimes
    $i.PayRMBCents = ($dt1|?{$_.ChannelId -eq $i.ChannelId}).PayRMBCents
}


$sql1=$sql1|select ChannelId,PayUsers,PayTimes,PayRMBCents,FirstLoginPayRMBCents,FirstLoginPayUsers
foreach($i in $sql1){
    $i.FirstLoginPayRMBCents = ($dt2|?{$_.ChannelId -eq $i.ChannelId}).FirstLoginPayRMBCents
    $i.FirstLoginPayUsers = ($dt2|?{$_.ChannelId -eq $i.ChannelId}).FirstLoginPayUsers
}

$sql1=$sql1|select *,FirstPayUsers,FirstPayRMBCents
foreach($i in $sql1){
    $i.FirstPayUsers = ($dt3|?{$_.ChannelId -eq $i.ChannelId}).FirstPayUsers
    $i.FirstPayRMBCents = ($dt3|?{$_.ChannelId -eq $i.ChannelId}).FirstPayRMBCents
}


$sqlpay=($sql1|%{
    $b = $_.ChannelId
    switch ($b)
    {      
        1000 { $ChannelId = 1 }
        1001 { $ChannelId = 3 }
        1002 { $ChannelId = 2 }
        1003 { $ChannelId = 4 }
        default { $ChannelId = 0 }
    }
    $SpreadChannelID=$ChannelId
    $PayUsers = if($_.PayUsers -eq $null){0}else{$_.PayUsers}
    $PayTimes = if($_.PayTimes -eq $null){0}else{$_.PayTimes}
    $PayRMBCents = if($_.PayRMBCents  -eq $null){0}else{$_.PayRMBCents}
    $FirstLoginPayRMBCents =  if($_.FirstLoginPayRMBCents -eq $null){0}else{$_.FirstLoginPayRMBCents}
    $FirstLoginPayUsers = if($_.FirstLoginPayUsers -eq $null){0}else{$_.FirstLoginPayUsers}
    $FirstPayUsers = if($_.FirstPayUsers -eq $null){0}else{$_.FirstPayUsers}
    $FirstPayRMBCents = if($_.FirstPayRMBCents -eq $null){0}else{$_.FirstPayRMBCents}
    $FirstPayUsers = if($_.FirstPayUsers -eq $null){0}else{$_.FirstPayUsers }
    $FirstPayRMBCents = if($_.FirstPayRMBCents -eq $null){0}else{$_.FirstPayRMBCents}
    "(1,1,1,$ChannelId,$SpreadChannelID,0,'$Date',$PayUsers,$PayTimes,$PayRMBCents,$FirstLoginPayUsers,$FirstLoginPayRMBCents,$FirstPayUsers,$FirstPayRMBCents)"
})



#conn stat mssql
$tabletime = ((get-date).adddays(-1)).ToString("yyyy_MM_dd")
$SqlConnection = New-Object System.Data.SqlClient.SqlConnection
$CnnString ="Server = 10.0.0.106; User Id = sa; Password = password"
$SqlConnection.ConnectionString = $CnnString
$CC = $SqlConnection.CreateCommand();

$sqlmore = $sqlpay -join ','
#入库
$cc.CommandText="INSERT INTO [KysdStatisticsDB].[dbo].[Pay1Day] ([GamesID],[OSID],[OSVersionID],[ChannelID],[SpreadChannelID],[SpreadSubChannelID],[Date],[PayUsers] ,[PayTimes],[PayRMBCents],[FirstLoginPayUsers],[FirstLoginPayRMBCents],[FirstPayUsers],[FirstPayRMBCents]) VALUES $sqlmore"
$da=New-Object System.Data.SqlClient.SqlDataAdapter($cc)
$dt1=New-Object System.Data.DataTable

$batch_num = $sqlmore.Length
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
