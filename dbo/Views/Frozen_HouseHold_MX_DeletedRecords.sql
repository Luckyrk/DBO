CREATE VIEW [dbo].[Frozen_HouseHold_MX_DeletedRecords]  
AS  
SELECT   
Sequence AS GroupBusinessId,  
[GDA900] AS RegionGroup,  
[GDA901] AS [City code],  
[GDA902] AS [Zone Code],  
[GDA903] AS [County code],  
[GDA904] AS [District code],  
[GDA905] AS [Sub district code],  
[GDA906] AS [Sector code],  
[H450] AS [Interviewer code],  
GPSUpdateTimestamp  
FROM   
(  
       SELECT COL.sequence,A.[Key],  
       CASE  
       WHEN A.[Type]='Enum' THEN ISNULL(ED.Value,'')  
       WHEN A.[Type]='Date' THEN FORMAT(TRY_PARSE(AV.Value AS DATETIME USING 'en-US'), 'yyyy-MM-dd hh:mm:ss')  
       ELSE  AV.Value  
       END AS  Value  
       ,AV.AuditDate AS GPSUpdateTimestamp  
       FROM   
       Country C  
       INNER JOIN Attribute A ON C.CountryId=A.Country_Id  
       INNER JOIN GPS_PM_Latam_Audit.audit.AttributeValue  AV ON AV.RespondentId IS NOT NULL AND A.GUIDReference=AV.DemographicId AND AV.__$operation=1 AND AV.AuditOperation='D'       
       JOIN Candidate CA ON CA.GeographicArea_Id=AV.RespondentId  
       INNER JOIN Collective COL ON COL.GUIDReference = CA.GUIDReference  
       LEFT JOIN EnumDefinition ED ON ED.Id=AV.EnumDefinition_Id  
       WHERE  C.CountryISO2A='MX'  
       AND A.[Key] IN ('GDA900','GDA901','GDA902','GDA903','GDA904','GDA905','GDA906')  
       AND AV.__$operation=1 AND AV.AuditOperation='D'       
       UNION  
       SELECT COL.sequence,A.[Key],  
       CASE  
       WHEN A.[Type]='Enum' THEN ISNULL(ED.Value,'')  
       WHEN A.[Type]='Date' THEN FORMAT(TRY_PARSE(AV.Value AS DATETIME USING 'en-US'), 'yyyy-MM-dd hh:mm:ss')  
       ELSE  AV.Value  
       END AS  Value  
       ,AV.AuditDate AS GPSUpdateTimestamp  
       FROM   
       Country C  
       INNER JOIN Attribute A ON C.CountryId=A.Country_Id  
       INNER JOIN GPS_PM_Latam_Audit.audit.AttributeValue AV ON AV.CandidateId IS NOT NULL AND A.GUIDReference=AV.DemographicId AND AV.__$operation=1 AND AV.AuditOperation='D'       
       INNER JOIN Collective COL ON COL.GUIDReference = AV.CandidateId  
       LEFT JOIN EnumDefinition ED ON ED.Id=AV.EnumDefinition_Id  
       WHERE  C.CountryISO2A='MX'  
       AND A.[Key] ='H450'  
       AND AV.__$operation=1 AND AV.AuditOperation='D'       
) src  
PIVOT   
(  
MAX(src.Value)  
FOR src.[Key] IN ([GDA900],[GDA901],[GDA902],[GDA903],[GDA904],[GDA905],[GDA906],[H450])  
) PVT; 

GO
