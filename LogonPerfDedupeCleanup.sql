/*
Created By: Chris Hildebrandt
*/

WITH cte AS (
    SELECT 
        Logon_Date, 
        Logon_Time_Stamp, 
        Session_Users,
        ROW_NUMBER() OVER (
            PARTITION BY 
                Logon_Date, 
                Logon_Time_Stamp, 
                Session_Users
            ORDER BY 
                Logon_Date, 
                Logon_Time_Stamp, 
                Session_Users
        ) row_num
     FROM 
        dbo.LogOnPerf
)
DELETE FROM cte
WHERE row_num > 1;