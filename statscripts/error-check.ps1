#错误日志检测脚本

$file = (Get-ChildItem  -Recurse C:\logs | ForEach-Object -Process{
if($_ -is [System.IO.FileInfo])
{
$_.FullName
}
})

if($file -ne $null){

$msg=New-Object System.Net.Mail.MailMessage
$msg.To.Add("zmy@kysd.cn")
$msg.From = New-Object System.Net.Mail.MailAddress("kysd_cn@126.com", "错误日志",[system.Text.Encoding]::GetEncoding("GB2312")) 
$msg.Subject = "错误日志$Date"
$msg.SubjectEncoding = [system.Text.Encoding]::GetEncoding("GB2312")
$msg.Body ="错误路径：
$file
"
#$Attachments=New-Object System.Net.Mail.Attachment("D:\scripts\csv\bzsg\不只三国订单数据$Date.zip")
#$msg.Attachments.add($Attachments)
$msg.BodyEncoding = [system.Text.Encoding]::GetEncoding("GB2312")
$msg.IsBodyHtml = $false
$msg.Priority = [System.Net.Mail.MailPriority]::High
$client = New-Object System.Net.Mail.SmtpClient("smtp.126.com")
$client.UseDefaultCredentials = $false
$client.Credentials=New-Object System.Net.NetworkCredential("kysd_cn@126.com", "kysd123")
try {$client.Send($msg)}
    catch [Exception]
{$($_.Exception.Message)
    $msg.To.address
} 

}


