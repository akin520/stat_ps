#log
$logs = ((get-date).ToString("yyyyMMddHHmm"))
$logfiles = "c:\logs\login_time\$logs.txt"

#创建日志目录
if(!(Test-Path c:\logs\login_time)){New-Item c:\logs\login_time -type directory -force}


Add-Type -path D:\statscripts\CSharpDriver-1.7.0.4714\MongoDB.Bson.dll
Add-Type -path D:\statscripts\CSharpDriver-1.7.0.4714\MongoDB.Driver.dll
$connectionString = 'mongodb://10.0.1.93';
$mongo=[MongoDB.Driver.Mongoserver]::Create($connectionString)
try{
    $mongo.Connect()    
}
catch{
    $body = $_.Exception.Message 
    $body | out-file -Append -filepath  $logfiles -Force
}

$d1 = Get-Date(((get-date).adddays(-1)).ToString("yyyy-MM-dd"))
$d2 = Get-Date((get-date).ToString("yyyy-MM-dd"))
[MongoDB.Driver.QueryDocument]$q =@{'loginDate'=@{'$gte'=$d1;'$lt'=$d2}}
$q
$all = ($mongo["bzsg"]["user_session_log"]).Find($q)
$all.count()

$sqltmp=@()
$all|%{
    $F=""|select userId,onlinetime
    $F.userId = $_["userId"].Value
    $F.onlinetime = [int]($_["logoutDate"].Value - $_["loginDate"].Value).TotalSeconds
    $sqltmp+=$F
}

$sqlmore=($sqltmp|%{
$a=$_.userId
$b=$_.onlinetime
"('$a','$b')"
})

#conn stat mssql
$tabletime = ((get-date).adddays(-1)).ToString("yyyy_MM_dd")
$SqlConnection = New-Object System.Data.SqlClient.SqlConnection
$CnnString ="Server = 10.0.0.106; User Id = sa; Password = password"
$SqlConnection.ConnectionString = $CnnString
$CC = $SqlConnection.CreateCommand();
$cc.CommandText="CREATE TABLE [KysdLogDB].[dbo].[login_time_tmp_$tabletime]([userId][varchar](50) NULL,[onlinetime] [int] NULL)"
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



#batch insert
$row=$sqlmore.count
$batch=1000

$str_tmp=@()
$tmp_cnt=0
0..($row-1)|%{
    $num=$_
    $str_tmp+=$sqlmore[$num]
    $tmp_cnt=$tmp_cnt+1
    if(($tmp_cnt -eq $batch) -or ($row -eq $tmp_cnt)){
        $sql=$str_tmp -join ","

        #insert
        $cc.CommandText="INSERT INTO [KysdLogDB].[dbo].[login_time_tmp_$tabletime] ([userId],[onlinetime]) VALUES $sql"
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



$cc.CommandText="SELECT userId,sum(onlinetime) as onlinetime INTO [KysdLogDB].[dbo].[login_time_$tabletime] FROM [KysdLogDB].[dbo].[login_time_tmp_$tabletime] group by userId
drop table [KysdLogDB].[dbo].[login_time_tmp_$tabletime]
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

exit