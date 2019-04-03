#发送邮件
function sendmail{param([string]$mailaddr,[string]$body)
    $msg=New-Object System.Net.Mail.MailMessage
    $msg.To.Add($mailaddr)
    $msg.From = New-Object System.Net.Mail.MailAddress("zmy@kysd.com", "北京快鱼时代技术有限公司",[system.Text.Encoding]::GetEncoding("GB2312")) 
    $msg.Subject = "订单详情"
    $msg.SubjectEncoding = [system.Text.Encoding]::GetEncoding("GB2312")
    $msg.Body =$body
    $msg.BodyEncoding = [system.Text.Encoding]::GetEncoding("GB2312")
    #$msg.IsBodyHtml = $true
    $msg.Priority = [System.Net.Mail.MailPriority]::High
    $client = New-Object System.Net.Mail.SmtpClient("192.168.200.100")
    $client.UseDefaultCredentials = $false
    $client.Credentials=New-Object System.Net.NetworkCredential("zmy", "123")
    try {$client.Send($msg)}
     catch [Exception]{$($_.Exception.Message)
     $mailaddr
     }
}


$Date = ((get-date).AddDays(-1)).ToString("yyyy-MM-dd")
$d1 = ((get-date).AddDays(-1)).ToString("yyyy-MM-dd 00:00:00")
$d2 = ((get-date).AddDays(-1)).ToString("yyyy-MM-dd 23:59:59")

$SqlConnection = New-Object System.Data.SqlClient.SqlConnection
$CnnString ="Server = 124.202.152.104; User Id =stat_reader ; Password = stat_reader123"
$SqlConnection.ConnectionString = $CnnString
$CC = $SqlConnection.CreateCommand();

$cc.CommandText="select [OrderNO],[ServiceName],[Amount],[UpdateDate] 
from KysdPlatPay.[dbo].[RechargeOrder] a, KysdPlatPay.dbo.RechargeService b 
where a.RechargeServiceId = b.Code and a.Status = 'success' 
and a.UpdateDate between '$d1' and '$d2' order by 4 asc
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


$cc.CommandText="select [ChannelOrderNo],[ChannelName],[RealAmount],[UpdateDate]
from [KysdAnySdkDB].[dbo].[ChangeOrder] a,[KysdAnySdkDB].[dbo].[Channels] b
where a.[ChannelId] = b.[Id] and a.OrderStatus = 'success'
and a.UpdateDate between '$d1' and '$d2' order by 4 asc"
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


function Add-Zip
{
	param([string]$zipfilename)
	if(-not (test-path($zipfilename)))
	{
		set-content $zipfilename ("PK" + [char]5 + [char]6 + ("$([char]0)" * 18))
		(dir $zipfilename).IsReadOnly = $false	
	}
	$shellApplication = new-object -com shell.application
	$zipPackage = $shellApplication.NameSpace($zipfilename)
	
	foreach($file in $input) 
	{ 
            $zipPackage.CopyHere($file.FullName)
            Start-sleep -milliseconds 500
	}
}

$dt1|Export-Csv D:\scripts\csv\bzsg\支付方式$Date.csv -notype  -Encoding oem
$dt2|Export-Csv D:\scripts\csv\bzsg\平台$Date.csv -notype  -Encoding oem

dir @("D:\scripts\csv\bzsg\支付方式$Date.csv",
"D:\scripts\csv\bzsg\平台$Date.csv")|add-zip "D:\scripts\csv\bzsg\不只三国订单数据$Date.zip"

sleep 5
$msg=New-Object System.Net.Mail.MailMessage
$msg.To.Add("gaoling@kysd.com")
#$msg.To.Add("zmy@kysd.com")
$msg.From = New-Object System.Net.Mail.MailAddress("zmy@kysd.com", "数据统计",[system.Text.Encoding]::GetEncoding("GB2312")) 
$msg.Subject = "不只三国订单详请$Date"
$msg.SubjectEncoding = [system.Text.Encoding]::GetEncoding("GB2312")
$msg.Body ="不只三国订单详请"
$Attachments=New-Object System.Net.Mail.Attachment("D:\scripts\csv\bzsg\不只三国订单数据$Date.zip")
$msg.Attachments.add($Attachments)
$msg.BodyEncoding = [system.Text.Encoding]::GetEncoding("GB2312")
$msg.IsBodyHtml = $false
$msg.Priority = [System.Net.Mail.MailPriority]::High
$client = New-Object System.Net.Mail.SmtpClient("192.168.200.100")
$client.UseDefaultCredentials = $false
$client.Credentials=New-Object System.Net.NetworkCredential("zmy", "123")
try {$client.Send($msg)}
    catch [Exception]{$($_.Exception.Message)
    $mailaddr
    } 
