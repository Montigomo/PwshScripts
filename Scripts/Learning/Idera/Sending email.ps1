
$TLS12Protocol = [System.Net.SecurityProtocolType] 'Ssl3 , Tls12'
[System.Net.ServicePointManager]::SecurityProtocol = $TLS12Protocol 


# must match your email address
# Most hosters do not accept email addresses with a different domain
$from = 'sunika@gmail.com' 
# send email to:
$to = 'agitech@gmail.com'
# if you want to add attachments, specify here and use -Attachments 
# else, remove that parameter
$file = 'c:\path\to\attachment.txt'
$subject = 'Mail from PowerShell'
$body = 'Here is the content'
$smtp = 'some.smtpserver'  
# your username (sometimes your internal mailbox name), prompts for password:
$cred = Get-Credential -Message 'Enter your email username or email address'
 
# send mail (one line without line break):
Send-MailMessage -From $from -To $to -Attachments $file -Subject $subject -Body $body -Encoding UTF8 -SmtpServer $smtp -UseSsl -Port 587 -Credential $cred