#log
$logs = ((get-date).ToString("yyyyMMddHHmm"))
$logfiles = "c:\logs\frist_login\$logs.txt"

#创建日志目录
if(!(Test-Path c:\logs\frist_login)){New-Item c:\logs\frist_login -type directory -force}


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
[MongoDB.Driver.QueryDocument]$q =@{'registerDate'=@{'$gte'=$d1;'$lt'=$d2}}
$d1,$d2,$q
$all = ($mongo["bzsg"]["users"]).Find($q)
$all.Count()

$sqltmp=@()
$all|%{
    $F=""|select uid,userId,channel,registerDate
    $F.uid = $_["uid"].Value
    $F.userId = $_["userId"].Value
    $F.channel = $_["channel"].Value
    $F.registerDate =$_["registerDate"].Value
    $sqltmp+=$F
}

$sqlmore=($sqltmp|%{
$a=$_.uid
$b=$_.userId
$c=$_.channel
$d=$_.registerDate
"('$a','$b','$c','$d')"
})


#conn stat mssql
$tabletime = ((get-date).adddays(-1)).ToString("yyyy_MM_dd")
$SqlConnection = New-Object System.Data.SqlClient.SqlConnection
$CnnString ="Server = 10.0.0.106; User Id = sa; Password = password"
$SqlConnection.ConnectionString = $CnnString
$CC = $SqlConnection.CreateCommand();
$cc.CommandText="CREATE TABLE [KysdLogDB].[dbo].[frist_login_$tabletime]([uid][varchar](50) NULL,[userId][varchar](50) NULL,[channel][varchar](20) NULL,[registerDate] [datetime] NULL)"
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
        $cc.CommandText="INSERT INTO [KysdLogDB].[dbo].[frist_login_$tabletime] ([uid],[userId],[channel],[registerDate]) VALUES $sql"
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