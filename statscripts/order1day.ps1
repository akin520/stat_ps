#时间
$Date = ((get-date).AddDays(-1)).ToString("yyyy-MM-dd")
$d1 = ((get-date).AddDays(-1)).ToString("yyyy-MM-dd 00:00:00")
$d2 = ((get-date).AddDays(-1)).ToString("yyyy-MM-dd 23:59:59")

#错误日志
$logs = ((get-date).ToString("yyyyMMddHHmm"))
$logfiles = "c:\logs\order\$logs.txt"

#创建日志目录
if(!(Test-Path c:\logs\order)){New-Item c:\logs\order -type directory -force}

$SqlConnection = New-Object System.Data.SqlClient.SqlConnection
$CnnString ="Server = 124.202.152.104; User Id =stat_reader ; Password = stat_reader123"
$SqlConnection.ConnectionString = $CnnString
$CC = $SqlConnection.CreateCommand();

#order
$cc.CommandText="SELECT UpdateDate,RechargeServiceId,0,AnySDKOrderNO,cast(Amount*100 as int) Amount,0,'SUCCESS' FROM [KysdPlatPay].[dbo].[RechargeOrder] where status='SUCCESS' and UpdateDate between '$d1' and '$d2'"
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

$sql1=($dt1|select UpdateDate,RechargeServiceId,Column1,AnySDKOrderNO,Amount,Column2,Column3)|%{
$UpdateDate = $_.UpdateDate
$RechargeServiceId = $_.RechargeServiceId
$Column1 = $_.Column1
$AnySDKOrderNO = $_.AnySDKOrderNO
$Amount = $_.Amount
$Column2 = $_.Column2
$Column3 = $_.Column3
if($RechargeServiceId -eq 7){
    $PayTypeId =2
}else{
    $PayTypeId =1
}
"('$UpdateDate',$PayTypeId,$RechargeServiceId,'$Column1','$AnySDKOrderNO',$Amount,$Column2,'$Column3')"
}




#conn stat mssql
$SqlConnection = New-Object System.Data.SqlClient.SqlConnection
$CnnString ="Server = 10.0.0.106; User Id = sa; Password = password"
$SqlConnection.ConnectionString = $CnnString
$CC = $SqlConnection.CreateCommand();


#batch insert
$row=$sql1.count
$batch=1000

$str_tmp=@()
$tmp_cnt=0
0..($row-1)|%{
    $num=$_
    $str_tmp+=$sql1[$num]
    $tmp_cnt=$tmp_cnt+1
    if(($tmp_cnt -eq $batch) -or ($row -eq $tmp_cnt)){
        $sql=$str_tmp -join ","

        #insert
        $cc.CommandText="INSERT INTO [KysdStatisticsDB].[dbo].[OrderDetail] ([DateTime],[PayTypeId],[SubPayTypeId],[OrderNo],[KyOrderNo],[MoneyCent],[FeeCent],[OrderStatus]) VALUES $sql"
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

        $row=$row - $batch
        $tmp_cnt=0
        $str_tmp=@()
    }
}

exit