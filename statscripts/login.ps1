#log
$logs = ((get-date).ToString("yyyyMMddHHmm"))
$logfiles = "c:\logs\login\$logs.txt"

#创建日志目录
if(!(Test-Path c:\logs\login)){New-Item c:\logs\login -type directory -force}

#conn stat mssql
$dt1=$null
$tabletime = ((get-date).adddays(-1)).ToString("yyyy_MM_dd")
$SqlConnection = New-Object System.Data.SqlClient.SqlConnection
$CnnString ="Server = 10.0.0.106; User Id = sa; Password = password"
$SqlConnection.ConnectionString = $CnnString
$CC = $SqlConnection.CreateCommand();
$cc.CommandText="select * FROM [KysdLogDB].[dbo].[login_time_$tabletime]"
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

$sqlarry=@()
($dt1|select userId)|%{
$a=$_.userId
$sqlarry+=$a
}


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


[MongoDB.Driver.QueryDocument]$q =@{'userId'=@{'$in'=$sqlarry}}
$all = ($mongo["bzsg"]["users"]).Find($q)
$all.count()

$sqltmp=@()
$all|%{
    $F=""|select platformId,platformName,gold,level,uid,userId,channel,registerDate,tutorialStep
    $F.platformId=$_["platformId"].Value
    $F.platformName=$_["platformName"].Value
    $F.gold=$_["gold"].Value
    $F.level=$_["level"].Value
    $F.uid = $_["uid"].Value
    $F.userId = $_["userId"].Value
    $F.channel = $_["channel"].Value
    $F.registerDate =$_["registerDate"].Value
    $F.tutorialStep=$_["tutorialStep"].Value
    $sqltmp+=$F
}


$sqlmore=($sqltmp|%{
$a=$_.platformId
$b=$_.platformName
$c=$_.gold
$d=$_.level
$e=$_.uid
$f=$_.userId
$g=$_.channel
$h=$_.registerDate
$i=$_.tutorialStep
"('$a','$c','$d','$e','$f','$g','$h','$i')"
})


$cc.CommandText="CREATE TABLE [KysdLogDB].[dbo].[login_tmp_$tabletime]([platformId][varchar](50) NULL,[gold][int] NULL,level[int] NULL,[uid][int] NULL,[userId][varchar](50) NULL,[channel][varchar](50) NULL,[registerDate][datetime] NULL,[tutorialStep][int] NULL)"
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
        $cc.CommandText="INSERT INTO [KysdLogDB].[dbo].[login_tmp_$tabletime] ([platformId],[gold],[level],[uid],[userId],[channel],[registerDate],[tutorialStep]) VALUES $sql"
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