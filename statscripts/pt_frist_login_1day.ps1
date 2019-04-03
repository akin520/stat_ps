#时间
$Date = ((get-date).AddDays(-1)).ToString("yyyy-MM-dd")
$d1 = ((get-date).AddDays(-1)).ToString("yyyy-MM-dd 00:00:00")
$d2 = ((get-date).AddDays(-1)).ToString("yyyy-MM-dd 23:59:59")

#错误日志
$logs = ((get-date).ToString("yyyyMMddHHmm"))
$logfiles = "c:\logs\login\$logs.txt"

#创建日志目录
if(!(Test-Path c:\logs\login)){New-Item c:\logs\login -type directory -force}

$SqlConnection = New-Object System.Data.SqlClient.SqlConnection
$CnnString ="Server = 124.202.152.104; User Id =stat_reader ; Password = stat_reader123"
$SqlConnection.ConnectionString = $CnnString
$CC = $SqlConnection.CreateCommand();

#login
$cc.CommandText="USE [KysdAnySdkDB]
select a.UserId,b.ChannelId,b.GameId,min(a.CreateDate) Date from 
(select * from [dbo].[LoginLogUserInfo] where CreateDate between '$d1' and '$d2') a,
(select * from [dbo].[LoginLog]) b
where a.loginlogid=b.id 
group by a.UserId,b.ChannelId,b.GameId
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

$sql1=($dt1|select UserId,ChannelId,GameId,Date)|%{
$a = $_.UserId
$b = $_.ChannelId
$c = $_.GameId
$d = $_.Date
"($a,$b,$c,'$d')"
}


#frist login
$cc.CommandText="USE [KysdAnySdkDB]
SELECT  [ChannelId],[ChannelUserId],[CreateTime] FROM [dbo].[ChannelUser] where CreateTime between '$d1' and '$d2'"

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

$sql2=($dt2|select ChannelId,ChannelUserId,CreateTime)|%{
$a = $_.ChannelId
$b = $_.ChannelUserId
$c = $_.CreateTime
"($a,$b,'$c')"
}



#conn stat mssql
$tabletime = ((get-date).adddays(-1)).ToString("yyyy_MM_dd")
$SqlConnection = New-Object System.Data.SqlClient.SqlConnection
$CnnString ="Server = 10.0.0.106; User Id = sa; Password = password"
$SqlConnection.ConnectionString = $CnnString
$CC = $SqlConnection.CreateCommand();


<#
$cc.CommandText="drop table [KysdLogDB].[dbo].[pt_login_$tabletime]
drop table [KysdLogDB].[dbo].[pt_frist_$tabletime]
CREATE TABLE [KysdLogDB].[dbo].[pt_login_$tabletime]([UserId] [int] NULL,[ChannelId] [int] NULL,[GameId] [int]NULL,[Date] [datetime] NULL)
CREATE TABLE [KysdLogDB].[dbo].[pt_frist_$tabletime]([ChannelId] [int] NULL,[ChannelUserId] [varchar](50) NULL,[CreateTime] [datetime] NULL)
"
#>
$cc.CommandText="CREATE TABLE [KysdLogDB].[dbo].[pt_login_$tabletime]([UserId] [int] NULL,[ChannelId] [int] NULL,[GameId] [int]NULL,[Date] [datetime] NULL)
CREATE TABLE [KysdLogDB].[dbo].[pt_frist_$tabletime]([ChannelId] [int] NULL,[ChannelUserId] [varchar](50) NULL,[CreateTime] [datetime] NULL)
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
        $cc.CommandText="INSERT INTO [KysdLogDB].[dbo].[pt_login_$tabletime] ([userId],[ChannelId],[GameId],[Date]) VALUES $sql"
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



$row=$sql2.count
$batch=1000

$str_tmp=@()
$tmp_cnt=0
0..($row-1)|%{
    $num=$_
    $str_tmp+=$sql2[$num]
    $tmp_cnt=$tmp_cnt+1
    if(($tmp_cnt -eq $batch) -or ($row -eq $tmp_cnt)){
        $sql=$str_tmp -join ","

        #insert
        $cc.CommandText="INSERT INTO [KysdLogDB].[dbo].[pt_frist_$tabletime] ([ChannelId],[ChannelUserId],[CreateTime]) VALUES $sql"
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



#游戏内用户统计，加载到100
$cc.CommandText="SELECT count(distinct(uid)) users,channel FROM [KysdLogDB].[dbo].[login_tmp_$tabletime] where tutorialStep >1 group by channel"
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

$sqlmore=@()
$sql1=($dt1|select users,channel)|%{
$a = $_.users
$b = $_.channel
switch ($b)
{      
    1000 { $ChannelId = 1 }
    1001 { $ChannelId = 3 }
    1002 { $ChannelId = 2 }
    1003 { $ChannelId = 4 }
    default { $ChannelId = 0 }
}
$SpreadChannelID=$ChannelId

"(1,1,1,$ChannelId,$SpreadChannelID,0,'$Date',3,$a)"
}
$sqlmore+=$sql1

#平台登录
$cc.CommandText="SELECT count(distinct(UserId)) users,ChannelId channel FROM [KysdLogDB].[dbo].[pt_login_$tabletime] group by ChannelId"
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

$sql2=($dt1|select users,channel)|%{
$a = $_.users
$b = $_.channel
switch ($b)
{      
    1000 { $ChannelId = 1 }
    1001 { $ChannelId = 3 }
    1002 { $ChannelId = 2 }
    1003 { $ChannelId = 4 }
    default { $ChannelId = 0 }
}
$SpreadChannelID=$ChannelId

"(1,1,1,$ChannelId,$SpreadChannelID,0,'$Date',2,$a)"
}
$sqlmore+=$sql2

#首次登录
$cc.CommandText="SELECT count(distinct(ChannelUserId)) users,ChannelId channel FROM [KysdLogDB].[dbo].[pt_frist_$tabletime] group by ChannelId"
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

$sql3=($dt1|select users,channel)|%{
$a = $_.users
$b = $_.channel
switch ($b)
{      
    1000 { $ChannelId = 1 }
    1001 { $ChannelId = 3 }
    1002 { $ChannelId = 2 }
    1003 { $ChannelId = 4 }
    default { $ChannelId = 0 }
}
$SpreadChannelID=$ChannelId

"(1,1,1,$ChannelId,$SpreadChannelID,0,'$Date',1,$a)"
}
$sqlmore+=$sql3


$sqltmp = $sqlmore -join ','
#入库
$cc.CommandText="INSERT INTO [KysdStatisticsDB].[dbo].[Login1Day] ([GamesID],[OSID],[OSVersionID],[ChannelID],[SpreadChannelID],[SpreadSubChannelID],[Date],[LoginTypeID],[Count]) VALUES $sqltmp"
$da=New-Object System.Data.SqlClient.SqlDataAdapter($cc)
$dt1=New-Object System.Data.DataTable

$batch_num = $sqlmore.count
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
