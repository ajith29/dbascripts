$PatchPath='\\denasaz.intel.com\desupport\SQL Server\Patch\SQLServerPatch\'
$results =@()
foreach($line in Get-Content D:\Work\Powershell\serverlist1152022.txt) {
 #$sqlinstance = Find-DbaInstance -ComputerName $line
 #$instance= $sqlinstance.ComputerName +"\" +$sqlinstance.InstanceName 
 $instance= "$line,3180"
$result = Test-DbaBuild -SqlInstance $instance -Update -MaxBehind 0CU 
#$result | Add-Member -NotePropertyName Computer -NotePropertyValue $line
$results += $result

 }
$results| Select-Object SqlInstance, NameLevel, SPLevel, SPTarget, CULevel, CUTarget, Compliant  | Sort-Object Compliant  #| export-csv -Path c:\resulst.txt

 
 # This loop does the service level patch
 
 foreach ( $result in  $results) {
 if($result.BuildLevel -notlike $result.BuildTarget){
  if($result.SPLevel -notmatch $result.SPTarget) {
  $sqlversion= $result.NameLevel
  $sqltarget = $result.SPTarget
  $pathtofile = $PatchPath +"SQLServer" +$sqlversion +"\" +$sqltarget +"\" +"*.exe"
  #Get-ChildItem $pathtofile
$filename = Get-ChildItem $pathtofile | Select-Object -ExpandProperty Name
$sourfile = $PatchPath +"SQLServer" +$sqlversion +"\" +$sqltarget +"\" +$filename
$destinationfile = "\\" +$result.SqlInstance.Split('\')[0] +"\c$\temp\" +$filename
$computer = $result.SqlInstance.Split('\')[0]
$computer
$patch = "c:\temp\" +$filename
#Copy-Item -Path "Microsoft.PowerShell.Core\FileSystem::$sourfile" -Destination "Microsoft.PowerShell.Core\FileSystem::$destinationfile"
#& D:\pstools\psexec.exe \\$computer "\c$\temp\" +$filename /qs /IAcceptSQLServerLicenseTerms /Action=Patch /AllInstances

$command = "$patch /q /IAcceptSQLServerLicenseTerms /Action=Patch /AllInstances"
Invoke-WmiMethod -class Win32_process -name Create -ArgumentList $command -ComputerName $computer}

 }
 }
  #  this is the path were the log file is generated. @%programfiles%\Microsoft SQL Server\nnn\Setup Bootstrap\Log 

  # This loop does the cumlative patch 

 foreach ( $result in  $results) {
  if($result.SPLevel -match $result.SPTarget) {
  if($result.CULevel -notlike $result.CUTarget){
  $sqlversion= $result.NameLevel
  $CUtarget = $result.CUTarget
  $pathtofile = $PatchPath +"SQLServer" +$sqlversion +"\" +$CUtarget +"\" +"*.exe"
  #Get-ChildItem $pathtofile
$filename = Get-ChildItem $pathtofile | Select-Object -ExpandProperty Name
$sourfile = $PatchPath +"SQLServer" +$sqlversion +"\" +$CUtarget +"\" +$filename
$destinationfile = "\\" +$result.SqlInstance.Split('\')[0] +"\c$\temp\" +$filename
$computer = $result.SqlInstance.Split('\')[0]
$computer
$patch = "c:\temp\" +$filename
Restart-Computer -ComputerName $computer -Wait -For PowerShell -Timeout 120 -Delay 2
Copy-Item -Path "Microsoft.PowerShell.Core\FileSystem::$sourfile" -Destination "Microsoft.PowerShell.Core\FileSystem::$destinationfile"

sleep 10
$command = "$patch /q /IAcceptSQLServerLicenseTerms /Action=Patch /AllInstances"
Invoke-WmiMethod -class Win32_process -name Create -ArgumentList $command -ComputerName $computer

 }
 }
 
 }
 
# Things to do is to caputre the wmi method and then get the process an see if its completed 
# The server need a s reboot check.. 



