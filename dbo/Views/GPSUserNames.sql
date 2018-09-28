Go
Create VIEW [dbo].[GPSUserNames]
AS

SELECT      Distinct  F.UserName, F.CountryISO2A, F.GPSUser,STUFF((SELECT ', ' + CAST(SystemRoleTypeId AS VARCHAR(1000)) [text()] 
         FROM GpsUserRoles 
         WHERE UserName = F.UserName
         FOR XML PATH(''), TYPE)
        .value('.','NVARCHAR(MAX)'),1,2,' ') SystemRoleTypeId,
              STUFF((SELECT ', ' + CAST([Description] AS VARCHAR(1000)) [text()] 
         FROM GpsUserRoles 
         WHERE UserName = F.UserName
         FOR XML PATH(''), TYPE)
        .value('.','NVARCHAR(MAX)'),1,2,' ') Description
FROM      GpsUserRoles F  
              
              INNER JOIN dbo.CountryViewAccess ON F.CountryISO2A = dbo.CountryViewAccess.Country
WHERE     (dbo.CountryViewAccess.UserId = SUSER_SNAME()) AND (dbo.CountryViewAccess.AllowPID = 1) 
              AND F.CountryISO2A = dbo.CountryViewAccess.Country 


		