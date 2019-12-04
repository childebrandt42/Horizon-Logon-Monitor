
<#
.SYNOPSIS
    VMWare Horizon Logon Performance Metrics
.DESCRIPTION
    Script to gather VMware Logon Performance Metric using Performance Monitor data and exporting it to CSV as an example. 
    
.Requirments
    Requires VMware Logon Montior being installed as part of Horizon Agent, also requires that the RemoteLog Path has been set, with Unique Log Key being set. Requires you to install
    the Powershell module for SQL Server. This can be done by running: Install-Module -Name SqlServer
.ChangeLog
    Added Email Function with built in graph to show the last 14 days AVG of each days log on times. 

.NOTES
    Version:          1.3.0
    Author:           Chris Hildebrandt
    Twitter:          @childebrandt42
#>

#---------------------------------------------------------------------------------------------#
#                                  Script Varribles                                           #
#---------------------------------------------------------------------------------------------#


$LogFolderLocation = "\\Remoteserverpath\Temp\LogonProfileLogs" #Location for Remote Logon Monitor Path
$LogonFileOutLocation = "C:\Reports\LogonMonitorReports" #Only give the path where you would like to save the CSV

#Frequency in how often to run the script.
$ScriptRunFeqHour = '24' # In hours (If you are using task scheduler you can only run a script once a day) 

#Set value as 1 if you want to delete old log files older than $ScriptRunFeqHour. 
$DeleteOldReports = '1'

#Set this if you wish send the data to a SQL server
$SendtoSQL = '1'

#SQL Server Info
$SQLServer = 'SQLServer@domain.com' #SQL Server Address
$SQLTable = 'LogOnPerf' #SQL Server Table
$DBName = 'DBTableName' #SQL Server Data Base name.

#Set value to 1 if you would like to send a email with time period worth of data with chart and the csv file.
$SendEmail = '1'

# Email Varibles
$EmailFrom = 'VDILogOnPerformanceReport@domain.com'
$EmailTo = 'youremail@domain.com'
$EmailServer = 'emailserver@domain.com'

#---------------------------------------------------------------------------------------------#
#                      Script Do not edit Varribles                                           #
#---------------------------------------------------------------------------------------------#
$LogFolder =''
$LogFolder = Get-item "$LogFolderLocation\*" | Where-Object {$_.Lastwritetime -gt (Get-Date).addhours(-$ScriptRunFeqHour)}
$LogData =@('')
$Date = Get-Date -format 'yyyy-MM-dd-HH-mm-ss'
$StartDate = (Get-Date).AddHours(-$ScriptRunFeqHour).ToString(‘yyyy-MM-dd HH:mm:ss’)
$EndDate = (Get-Date).ToString(‘yyyy-MM-dd HH:mm:ss’)

$Export = "$LogonFileOutlocation\LogonPerfData-$Date.csv"

$ExportLogPerfDataAvg = "$LogonFileOutlocation\LogonPerfDataAvg.csv"

$ExportLogPerfDataJPG = "$LogonFileOutlocation\14DayLogonTime.jpg"

$EmailSubject = ""
$EmailBody = @('')

#---------------------------------------------------------------------------------------------#
#                                  Script Body                                                #
#---------------------------------------------------------------------------------------------#

# For Each Log file in Log folder repository
#__________________________________________________________________________________________________________

$count = 1

foreach ($LogonFile in $LogFolder) {

    # Get Content of LogonFile
    $LogFileContent = Get-Content -Path $LogonFile

    # Need to Add Data and Time.

    # Session FQDN: 
    $SessionFQDN = $LogFileContent | Select-String  -Pattern "FQDN:"
    $SessionFQDN = $SessionFQDN | Out-String
    $SessionFQDN = $SessionFQDN.Split(':')[$($SessionFQDN.Split(':').Count-1)]
    $SessionFQDN = $SessionFQDN.Trim(' ')
    $SessionFQDN = $SessionFQDN -replace "`t|`n|`r",""

    # Session Summary (User:
    $SessionUser = $LogFileContent | Select-String  -Pattern "Session Summary \(User:"
    $SessionUser = $SessionUser | Out-String
    $SessionUser = $SessionUser.Split(':')[$($SessionUser.Split(':').Count-2)]
    $SessionUser = $SessionUser.Trim(' ')
    $SessionUser = $SessionUser -replace ', Session'

    # LogOn Time
    $LogonTime = $LogFileContent | Select-String  -Pattern "Logon Time:"
    $LogonTime = $LogonTime | Out-String
    $LogonTime = $LogonTime.Split(':')[$($LogonTime.Split(':').Count-1)]
    $LogonTime = $LogonTime.Trim(' ')
    $LogonTime = $LogonTime -replace ' seconds'
    $LogonTime = $LogonTime -replace "`t|`n|`r",""

    # Logon Start To Hive Loaded Time
    $LogonStartHive = $LogFileContent | Select-String  -Pattern "Logon Start To Hive Loaded Time:"
    $LogonStartHive = $LogonStartHive | Out-String
    $LogonStartHive = $LogonStartHive.Split(':')[$($LogonStartHive.Split(':').Count-1)]
    $LogonStartHive = $LogonStartHive.Trim(' ')
    $LogonStartHive = $LogonStartHive -replace ' seconds'
    $LogonStartHive = $LogonStartHive -replace "`t|`n|`r",""

    # Logon Start To Classes Hive Loaded Time:
    $LogonClassHive = $LogFileContent | Select-String  -Pattern "Logon Start To Classes Hive Loaded Time:"
    $LogonClassHive = $LogonClassHive | Out-String
    $LogonClassHive = $LogonClassHive.Split(':')[$($LogonClassHive.Split(':').Count-1)]
    $LogonClassHive = $LogonClassHive.Trim(' ')
    $LogonClassHive = $LogonClassHive -replace ' seconds'
    $LogonClassHive = $LogonClassHive -replace "`t|`n|`r",""

    # Profile Sync Time
    $ProfileSyncTime = $LogFileContent | Select-String  -Pattern "Profile Sync Time:"
    $ProfileSyncTime = $ProfileSyncTime | Out-String
    $ProfileSyncTime = $ProfileSyncTime.Split(':')[$($ProfileSyncTime.Split(':').Count-1)]
    $ProfileSyncTime = $ProfileSyncTime.Trim(' ')
    $ProfileSyncTime = $ProfileSyncTime -replace ' seconds'
    $ProfileSyncTime = $ProfileSyncTime -replace "`t|`n|`r",""

    # Windows Folder Redirection Apply Time
    $WindowsFolderRedirection = $LogFileContent | Select-String  -Pattern "Windows Folder Redirection Apply Time:"
    $WindowsFolderRedirection = $WindowsFolderRedirection | Out-String
    $WindowsFolderRedirection = $WindowsFolderRedirection.Split(':')[$($WindowsFolderRedirection.Split(':').Count-1)]
    $WindowsFolderRedirection = $WindowsFolderRedirection.Trim(' ')
    $WindowsFolderRedirection = $WindowsFolderRedirection -replace ' seconds'
    $WindowsFolderRedirection = $WindowsFolderRedirection -replace "`t|`n|`r",""

    # Shell Load Time
    $ShellLoadTime = $LogFileContent | Select-String  -Pattern "Shell Load Time:"
    $ShellLoadTime = $ShellLoadTime | Out-String
    $ShellLoadTime = $ShellLoadTime.Split(':')[$($ShellLoadTime.Split(':').Count-1)]
    $ShellLoadTime = $ShellLoadTime.Trim(' ')
    $ShellLoadTime = $ShellLoadTime -replace ' seconds'
    $ShellLoadTime = $ShellLoadTime -replace "`t|`n|`r",""

    # Total Logon Script Time
    $TotalLogonScript = $LogFileContent | Select-String  -Pattern "Total Logon Script Time:"
    $TotalLogonScript = $TotalLogonScript | Out-String
    $TotalLogonScript = $TotalLogonScript.Split(':')[$($TotalLogonScript.Split(':').Count-1)]
    $TotalLogonScript = $TotalLogonScript.Trim(' ')
    $TotalLogonScript = $TotalLogonScript -replace ' seconds'
    $TotalLogonScript = $TotalLogonScript -replace "`t|`n|`r",""

    # User Policy Apply Time
    $UserPolicyApplyTime = $LogFileContent | Select-String  -Pattern "User Policy Apply Time:"
    $UserPolicyApplyTime = $UserPolicyApplyTime | Out-String
    $UserPolicyApplyTime = $UserPolicyApplyTime.Split(':')[$($UserPolicyApplyTime.Split(':').Count-1)]
    $UserPolicyApplyTime = $UserPolicyApplyTime.Trim(' ')
    $UserPolicyApplyTime = $UserPolicyApplyTime -replace ' seconds'
    $UserPolicyApplyTime = $UserPolicyApplyTime -replace "`t|`n|`r",""

    # Machine Policy Apply Time
    $MachinePolicyApplyTime = $LogFileContent | Select-String  -Pattern "Machine Policy Apply Time:"
    $MachinePolicyApplyTime = $MachinePolicyApplyTime | Out-String
    $MachinePolicyApplyTime = $MachinePolicyApplyTime.Split(':')[$($MachinePolicyApplyTime.Split(':').Count-1)]
    $MachinePolicyApplyTime = $MachinePolicyApplyTime.Trim(' ')
    $MachinePolicyApplyTime = $MachinePolicyApplyTime -replace ' seconds'
    $MachinePolicyApplyTime = $MachinePolicyApplyTime -replace "`t|`n|`r",""

    # Group Policy Software Install Time
    $GroupPolicySoftwareInstallTime = $LogFileContent | Select-String  -Pattern "Group Policy Software Install Time:"
    $GroupPolicySoftwareInstallTime = $GroupPolicySoftwareInstallTime | Out-String
    $GroupPolicySoftwareInstallTime = $GroupPolicySoftwareInstallTime.Split(':')[$($GroupPolicySoftwareInstallTime.Split(':').Count-1)]
    $GroupPolicySoftwareInstallTime = $GroupPolicySoftwareInstallTime.Trim(' ')
    $GroupPolicySoftwareInstallTime = $GroupPolicySoftwareInstallTime -replace ' seconds'
    $GroupPolicySoftwareInstallTime = $GroupPolicySoftwareInstallTime -replace "`t|`n|`r",""

    # Free Disk Space Available To User
    $FreeDiskSpaceAvail = $LogFileContent | Select-String  -Pattern "Free Disk Space Available To User:"
    $FreeDiskSpaceAvail = $FreeDiskSpaceAvail | Out-String
    $FreeDiskSpaceAvail = $FreeDiskSpaceAvail.Split(':')[$($FreeDiskSpaceAvail.Split(':').Count-1)]
    $FreeDiskSpaceAvail = $FreeDiskSpaceAvail.Trim(' ')
    $FreeDiskSpaceAvail = $FreeDiskSpaceAvail -replace ' GB'
    $FreeDiskSpaceAvail = $FreeDiskSpaceAvail -replace "`t|`n|`r",""

    $LogOndate = ($LogonFile.LastWriteTime -split ' ')[0]
    $Logontimestamp = ($LogonFile.LastWriteTime -split ' ')[1]

    if ($SendtoSQL -eq '1') {
        $query = "INSERT INTO $SQLTable (Logon_Date,Logon_Time_Stamp,Session_Users,Session_FQDN,Logon_Total_Time,Logon_Start_Hive,Logon_Class_Hive,Profile_Sync_Time,Windows_Folder_Redirection,Shell_Load_Time,Total_Logon_Script,User_Policy_Apply_Time,Machine_Policy_Apply_Time,Group_Policy_Software_Install_Time,Free_Disk_Space_Avail) 
                    VALUES ('$LogOndate','$Logontimestamp','$SessionUser','$SessionFQDN','$LogonTime','$LogonStartHive','$LogonClassHive','$ProfileSyncTime','$WindowsFolderRedirection','$ShellLoadTime','$TotalLogonScript','$UserPolicyApplyTime','$MachinePolicyApplyTime','$GroupPolicySoftwareInstallTime','$FreeDiskSpaceAvail')" 
        invoke-sqlcmd -Database $DBName -Query $query -serverinstance $SQLServer 

        write-host "Processing row ..........$count" -foregroundcolor green 
        $count  = $count + 1 
    }

    # Create Table
    $LogData += [pscustomobject]@{
        Logon_Date = $LogOndate
        Logon_Time_Stamp = $Logontimestamp
        Session_Users = $SessionUser
        Session_FQDN = $SessionFQDN
        Logon_Total_Time = $LogonTime
        Logon_Start_Hive = $LogonStartHive
        Logon_Class_Hive = $LogonClassHive
        Profile_Sync_Time = $ProfileSyncTime
        Windows_Folder_Redirection = $WindowsFolderRedirection
        Shell_Load_Time = $ShellLoadTime
        Total_Logon_Script = $TotalLogonScript
        User_Policy_Apply_Time = $UserPolicyApplyTime
        Machine_Policy_Apply_Time = $MachinePolicyApplyTime
        Group_Policy_Software_Install_Time = $GroupPolicySoftwareInstallTime
        Free_Disk_Space_Avail = $FreeDiskSpaceAvail
    }
}

# Export data to CSV File
#__________________________________________________________________________________________________________
$LogData | Select-Object ('Logon_Date','Logon_Time_Stamp','Session_Users','Session_FQDN','Logon_Total_Time','Logon_Start_Hive','Logon_Class_Hive','Profile_Sync_Time','Windows_Folder_Redirection','Shell_Load_Time','Total_Logon_Script','User_Policy_Apply_Time','Machine_Policy_Apply_Time','Group_Policy_Software_Install_Time','Free_Disk_Space_Avail') | Export-Csv $Export -notypeinformation

if ($DeleteOldReports -eq '1') {    
    Get-item "$LogFolderLocation\*" | Where-Object {$_.Lastwritetime -lt (Get-Date).addhours(-$ScriptRunFeqHour)} | Remove-Item -Confirm:$false
}

if ($SendEmail -eq '1') {

    #Create Avarage Times
    $LogonTimeAvg = $LogData.Logon_Total_Time | Measure-Object -Average
    $LogonStartHiveAvg = $LogData.Logon_Start_Hive | Measure-Object -Average
    $LogonClassHiveAvg = $LogData.Logon_Class_Hive | Measure-Object -Average
    $ProfileSyncTimeAVG = $LogData.Profile_Sync_Time | Measure-Object -Average
    $WindowsFolderRedirectionAvg = $LogData.Windows_Folder_Redirection | Measure-Object -Average
    $ShellLoadTimeAvg = $LogData.Shell_Load_Time | Measure-Object -Average
    $TotalLogonScriptAvg = $LogData.Total_Logon_Script | Measure-Object -Average
    $UserPolicyApplyTimeAvg = $LogData.User_Policy_Apply_Time | Measure-Object -Average
    $MachinePolicyApplyTimeAvg = $LogData.Machine_Policy_Apply_Time | Measure-Object -Average
    $GroupPolicySoftwareInstallTimeAvg = $LogData.Group_Policy_Software_Install_Time | Measure-Object -Average
    $FreeDiskSpaceAvailAvg = $LogData.Free_Disk_Space_Avail | Measure-Object -Average

    #Round the Avarage Numbers
    $LogonTimeAvgRnd = [math]::Round($LogonTimeAvg.Average,2)
    $LogonStartHiveAvgRnd = [math]::Round($LogonStartHiveAvg.Average,2)
    $LogonClassHiveAvgRnd = [math]::Round($LogonClassHiveAvg.Average,2)
    $ProfileSyncTimeAvgRnd = [math]::Round($ProfileSyncTimeAvg.Average,2)
    $WindowsFolderRedirectionAvgRnd = [math]::Round($WindowsFolderRedirectionAvg.Average,2)
    $ShellLoadTimeAvgRnd = [math]::Round($ShellLoadTimeAvg.Average,2)
    $TotalLogonScriptAvgRnd = [math]::Round($TotalLogonScriptAvg.Average,2)
    $UserPolicyApplyTimeAvgRnd = [math]::Round($UserPolicyApplyTimeAvg.Average,2)
    $MachinePolicyApplyTimeAvgRnd = [math]::Round($MachinePolicyApplyTimeAvg.Average,2)
    $GroupPolicySoftwareInstallTimeAvgRnd = [math]::Round($GroupPolicySoftwareInstallTimeAvg.Average,2)
    $FreeDiskSpaceAvailAvgRnd = [math]::Round($FreeDiskSpaceAvailAvg.Average,2)


    # Create Avg Table
    $LogDataAvg += [pscustomobject]@{
        Logon_Date_Avg = $EndDate
        Logon_Total_Time_Avg = $LogonTimeAvgRnd
        Logon_Start_Hive_Avg = $LogonStartHiveAvgRnd
        Logon_Class_Hive_Avg = $LogonClassHiveAvgRnd
        Profile_Sync_Time_Avg = $ProfileSyncTimeAvgRnd
        Windows_Folder_Redirection_Avg = $WindowsFolderRedirectionAvgRnd
        Shell_Load_Time_Avg = $ShellLoadTimeAvgRnd
        Total_Logon_Script_Avg = $TotalLogonScriptAvgRnd
        User_Policy_Apply_Time_Avg = $UserPolicyApplyTimeAvgRnd
        Machine_Policy_Apply_Time_Avg = $MachinePolicyApplyTimeAvgRnd
        Group_Policy_Software_Install_Time_Avg = $GroupPolicySoftwareInstallTimeAvgRnd
        Free_Disk_Space_Avail_Avg = $FreeDiskSpaceAvailAvgRnd
    }

    # Export data to CSV File
    #__________________________________________________________________________________________________________
    $LogDataAvg | Select-Object ('Logon_Date_Avg','Logon_Total_Time_Avg','Logon_Start_Hive_Avg','Logon_Class_Hive_Avg','Profile_Sync_Time_Avg','Windows_Folder_Redirection_Avg','Shell_Load_Time_Avg','Total_Logon_Script_Avg','User_Policy_Apply_Time_Avg','Machine_Policy_Apply_Time_Avg','Group_Policy_Software_Install_Time_Avg','Free_Disk_Space_Avail_Avg') | Export-Csv $ExportLogPerfDataAvg -notypeinformation -Append

    #---------------------------------------------------------------------------------------------#
    #                                  Create Grapsh                                              #
    #---------------------------------------------------------------------------------------------#

    $ImportAVGCSV = Import-CSV $ExportLogPerfDataAvg | Select-Object Logon_Date_Avg, Logon_Total_Time_Avg -Last 85

    # load the appropriate assemblies
    [void][Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
    [void][Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms.DataVisualization")

    # create chart object
    $Chart = New-object System.Windows.Forms.DataVisualization.Charting.Chart
    $Chart.Width = 1600
    $Chart.Height = 800
    $Chart.Left = 40
    $Chart.Top = 30

    # create a chartarea to draw on and add to chart
    $ChartArea = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
    $Chart.ChartAreas.Add($ChartArea)

    #Set Chart Data
    [void]$Chart.Series.Add("Data")
    $Chart.Series["Data"].Points.DataBindXY($ImportAVGCSV.Logon_Date_Avg, $ImportAVGCSV.Logon_Total_Time_Avg)

    #Set Title and Axis 
    [void]$Chart.Titles.Add("Horizon Logon Time Avarage Chart for last two weeks")
    $ChartArea.AxisX.Title = "Pull Time Date and Time"
    $ChartArea.AxisY.Title = "Logon Time in Seconds"

    $ChartArea.AxisX.LabelStyle.Angle = -90
    $ChartArea.AxisX.Interval = 1
    $Chart.Series["Data"]["DrawingStyle"] = "Cylinder"

    # Find point with max/min values and change their colour
    $maxValuePoint = $Chart.Series["Data"].Points.FindMaxByValue()
    $maxValuePoint.Color = [System.Drawing.Color]::Red
    $minValuePoint = $Chart.Series["Data"].Points.FindMinByValue()
    $minValuePoint.Color = [System.Drawing.Color]::Green

    # save chart to file
    $Chart.SaveImage($ExportLogPerfDataJPG, "PNG")



    ################################################################################################################################
    #--------------------------------------------Build Email-----------------------------------------------------------------------#
    ################################################################################################################################

    $LogonTimeJPG = $ExportLogPerfDataJPG

    $EmailSubject = "Horizon Performance Stats for last $ScriptRunFeqHour Hours: $($StartDate) to $($EndDate)"

    $EmailBody = ("
<html><body>
<p>Below is the Avarage Logon Times for the last 14 days.<br></P><br>
<br><img src=`"14DayLogonTime.jpg`">

<p>Below are the Avarages of the Logon Performance Monitor Reports for the last $ScriptRunFeqHour Hours.<br>
Avarage Logon Time = $LogonTimeAvgRnd Seconds.<br>
Avarage Start Hive Time = $LogonStartHiveAvgRnd Seconds.<br>
Avarage Class Hive Time = $LogonClassHiveAvgRnd Seconds.<br>
Avarage Profile Sync Time = $ProfileSyncTimeAvgRnd Seconds.<br>
Avarage Filder Redirection Time = $WindowsFolderRedirectionAvgRnd Seconds.<br>
Avarage Shell Load Time = $ShellLoadTimeAvgRnd Seconds.<br>
Avarage User Group Policy Time = $UserPolicyApplyTimeAvgRnd Seconds.<br>
Avarage Machine Group Policy Time = $MachinePolicyApplyTimeAvgRnd Seconds.<br>
Avarage Group Policy Software Install Time = $GroupPolicySoftwareInstallTimeAvgRnd Seconds.<br>
Avarage Free Disak Space Available = $FreeDiskSpaceAvailAvgRnd GB.

</body></html>
")

    ################################################################################################################################
    #--------------------------------------------Send Email------------------------------------------------------------------------#
    ################################################################################################################################


    Send-MailMessage -From $EmailFrom -To $EmailTo -Subject $EmailSubject -Body $EmailBody -SmtpServer $EmailServer -Attachments $Export,$LogonTimeJPG -BodyAsHtml

}
