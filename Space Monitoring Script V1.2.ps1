$disk = Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='G:'" |
Select-Object Size,FreeSpace

$FullDir = 'Your folder path'
#Number of days that should be retained
$DaysRefLogs = (Get-Date).AddDays("-7")

#Get Disk Size
$DiskSize = ($disk.Size).ToString("00")
#Get Free Space
$Freespace = $disk.FreeSpace
#Get the limit of the free space. Free spess Must never be less than this.(Set in bytes)
$FreespaceG = 53689975000

#gets today Date for the Email Subject.
$DateT = Get-Date 
#Set The path for logs
$PathLog = 'C:\Program Files (x86)\Space Monitoring\Log\'


#For Emailing
$EmailFrom = "From@example.com"
$EmailTo = "T@example.com"  
$Subject = "Backup Space Monitoring $DateT"
$Body = ""
$SMTPServer = "smtp.example.com"
$SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer, 587)  # Port 
$SMTPClient.EnableSsl = $true    
$SMTPClient.Credentials = New-Object System.Net.NetworkCredential("Username@example.com", "Your Password")    


#Check if space is available
if($Freespace -lt $FreespaceG )
{
#Get Current Date
Write-Output "As at: $DateT" >> $PathLog

#$Body = $null

Write-Warning "Creating Space"


#Delete Logs older than 7 Days
Get-ChildItem $LogDir | Where-Object {$_.PSIsContainer -eq $FALSE} >> $PathLog 
Get-ChildItem $LogDir | Where-Object {$_.PSIsContainer -eq $TRUE -AND $_.LastWriteTime -le $DaysRef} | Remove-Item -Recurse -Force >> $PathLog
Get-ChildItem $LogDir | Where-Object {$_.PSIsContainer -eq $FALSE -AND $_.LastWriteTime -le $DaysRef} | Remove-Item -Recurse -Force >> $PathLog 

#Delete Full older than 3 days
Get-ChildItem $FullDir | Where-Object {$_.PSIsContainer -eq $FALSE} >> $PathLog
Get-ChildItem $FullDir | Where-Object {$_.PSIsContainer -eq $TRUE -AND $_.LastWriteTime -le $DaysRefFull} | Remove-Item -Recurse -Force  >> $PathLog 
Get-ChildItem $FullDir | Where-Object {$_.PSIsContainer -eq $FALSE -AND $_.LastWriteTime -le $DaysRefFull} | Remove-Item -Recurse -Force  >> $PathLog 

#$Gb = ($Freespace/1Gb).ToString("00")
$Gb = (($disk.Freespace)/1Gb).ToString("00")

Write-Output "$Gb GB Space Currently Available" >> $PathLog 
$Body = "Dear Sirs, `n`nSpace has been freed. Current free space is: $Gb GB. You have The last 3 full backup and 7 days Transactional Logs"
$SMTPClient.Send($EmailFrom, $EmailTo, $Subject, $Body)
}
else {
#If There is enough space
$Gb = (($disk.Freespace)/1Gb).ToString("00")
Write-Output "As at: $DateT" >> $PathLog
Write-Output "Free Space available" >> $PathLog 
$Body = $null
$Body = "Dear Sirs, `n`nYou have enough space for the next backup. Current free space is: $Gb GB"
$SMTPClient.Send($EmailFrom, $EmailTo, $Subject, $Body)
}
