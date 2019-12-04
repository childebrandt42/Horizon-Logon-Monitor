/*
Created By: Chris Hildebrandt
*/

USE [Test]
GO

/****** Object:  Table [dbo].[LogOnPerf]    Script Date: 11/10/2019 4:45:46 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[LogOnPerf](
	[Logon_Date] [date] NOT NULL,
	[Logon_Time_Stamp] [time] NOT NULL,
	[Session_Users] [varchar](50) NOT NULL,
	[Session_FQDN] [varchar](50) NOT NULL,
	[Logon_Total_Time] [decimal](18, 0) NOT NULL,
	[Logon_Start_Hive] [decimal](18, 0) NOT NULL,
	[Logon_Class_Hive] [decimal](18, 0) NOT NULL,
	[Profile_Sync_Time] [decimal](18, 0) NOT NULL,
	[Windows_Folder_Redirection] [decimal](18, 0) NOT NULL,
	[Shell_Load_Time] [decimal](18, 0) NOT NULL,
	[Total_Logon_Script] [decimal](18, 0) NOT NULL,
	[User_Policy_Apply_Time] [decimal](18, 0) NOT NULL,
	[Machine_Policy_Apply_Time] [decimal](18, 0) NOT NULL,
	[Group_Policy_Software_Install_Time] [decimal](18, 0) NOT NULL,
	[Free_Disk_Space_Avail] [decimal](18, 0) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO


