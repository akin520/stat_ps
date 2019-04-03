#时间
$Date = ((get-date).AddDays(-1)).ToString("yyyy-MM-dd")

#错误日志
$logs = ((get-date).ToString("yyyyMMddHHmm"))
$logfiles = "c:\logs\channel\$logs.txt"

#创建日志目录
if(!(Test-Path c:\logs\channel)){New-Item c:\logs\channel -type directory -force}

#conn stat mssql
$SqlConnection = New-Object System.Data.SqlClient.SqlConnection
$CnnString ="Server = 10.0.0.106; User Id = sa; Password = password"
$SqlConnection.ConnectionString = $CnnString
$CC = $SqlConnection.CreateCommand();

#order
$cc.CommandText="SELECT [Date] ,[GamesID],[ChannelID],[PayRMBCents] FROM [KysdStatisticsDB].[dbo].[Pay1Day] where PayRMBCents>0 and Date='$Date'"
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

$sql1=($dt1|select Date,GamesID,ChannelID,PayRMBCents)|%{
$a = $_.Date
$b = $_.GamesID
$c = $_.ChannelID
$d = $_.PayRMBCents
"('$a',$b,$c,$d,0,0)"
}

$sql = $sql1 -join ','

$cc.CommandText="INSERT INTO [KysdStatisticsDB].[dbo].[Channel1Day] ([Date],[GameID],[ChannelID],[SalesCents],[FeeCents],[IncomeCents]) VALUES $sql"
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
exit