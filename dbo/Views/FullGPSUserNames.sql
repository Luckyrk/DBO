Go
Create VIEW [dbo].[FullGPSUserNames]
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
              
