<#
.SYNOPSIS
    VMWare Horizon Logon Performance Metrics
.DESCRIPTION
    Script to gather VMware Logon Performance Metric using Performance Monitor data and exporting it to CSV as an example. 
    
.Requirments
    Requires VMware Logon Montior being installed as part of Horizon Agent, also requires that the RemoteLog Path has been set, with Unique Log Key being set.

.NOTES
    Version:          1.0.0
    Author:           Chris Hildebrandt
    Twitter:          @childebrandt42
#>

#---------------------------------------------------------------------------------------------#
#                                  Script Varribles                                           #
#---------------------------------------------------------------------------------------------#

$LogFolderLocation = "C:\Temp\LogonProfileLogs" #Location for Remote Logon Monitor Path
$LogonFileOutPut = "C:\Temp\LogData.csv" #Location and file name for Output CSV file.

#---------------------------------------------------------------------------------------------#
#                      Script Do not edit Varribles                                           #
#---------------------------------------------------------------------------------------------#
$LogFolder = Get-item "$LogFolderLocation\*" | where {$_.Lastwritetime -gt (date).addhours(-4)}
$LogData =@('')

#---------------------------------------------------------------------------------------------#
#                                  Script Body                                                #
#---------------------------------------------------------------------------------------------#

# For Each Log file in Log folder repository
#__________________________________________________________________________________________________________

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

    $date = ($LogonFile.LastWriteTime -split ' ')[0]
    $time = ($LogonFile.LastWriteTime -split ' ')[1]

    # Create Table
    $LogData += [pscustomobject]@{
        Logon_Date = $date
        Logon_Time_Stamp = $time
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
$LogData | Select-Object ('Logon_Date','Logon_Time_Stamp','Session_Users','Session_FQDN','Logon_Total_Time','Logon_Start_Hive','Logon_Class_Hive','Profile_Sync_Time','Windows_Folder_Redirection','Shell_Load_Time','Total_Logon_Script','User_Policy_Apply_Time','Machine_Policy_Apply_Time','Group_Policy_Software_Install_Time') | Export-Csv $LogonFileOutPut -notypeinformation