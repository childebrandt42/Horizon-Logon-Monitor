# Horizon-Logon-Monitor
Horizon Logon Monitor

This script is created to pull data from the VMware Logon Performance Montior files redirected to a network share.

It does require you to set the following Reg Keys to be set:
HKLM:Software\VMware,INC\VMware Logon Monitor\
 Flags
 RemoteLogPath

 Would recomend to set the following keys:
 LogKeepDays
 LogMaxSizeMB

 This script with query all the log files in the directory less than 4 hours old and create a CSV from the performance metric from there.

 This is just built as a stepping block script. From here you can export this data to a SQL table and create a useful Webpage from there with usefull metrics. 