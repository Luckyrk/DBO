CREATE VIEW [dbo].[Frozen_Pet_CL_DeletedRecords]  
AS  
SELECT   
PetNO,  
Sequence AS GroupBusinessId,  
[H700] AS idanimal,  
[H701] AS idtamanho,  
[H703] AS [idtipo_alimentacao],  
[H702] AS [edad],  
GPSUpdateTimestamp  
FROM   
(  
       SELECT   
          B.BelongingCode AS PetNO,  
          COL.sequence,A.[Key],  
       CASE  
       WHEN A.[Type]='Enum' THEN ISNULL(ED.Value,'')  
       WHEN A.[Type]='Date' THEN FORMAT(TRY_PARSE(AV.Value AS DATETIME USING 'en-US'), 'yyyy-MM-dd hh:mm:ss')  
       ELSE  AV.Value  
       END AS  Value  
       ,AV.AuditDate AS GPSUpdateTimestamp  
       FROM   
       Country C  
       INNER JOIN Attribute A ON C.CountryId=A.Country_Id  
       INNER JOIN (SELECT * FROM GPS_PM_Latam_Audit.audit.AttributeValue WHERE __$operation=1 AND AuditOperation='D') AV ON AV.RespondentId IS NOT NULL AND A.GUIDReference=AV.DemographicId AND AV.__$operation=1 AND AV.AuditOperation='D'  
       INNER JOIN Belonging B ON B.GUIDReference = AV.RespondentId  
       INNER JOIN candidate Can ON Can.GUIDReference=B.CandidateId  
       INNER JOIN Collective Col ON Col.GUIDReference=Can.GUIDReference  
       LEFT JOIN EnumDefinition ED ON ED.Id=AV.EnumDefinition_Id  
       WHERE  C.CountryISO2A='CL'  
          AND A.[Key] IN ('H701','H703','H702','H700')  
          AND AV.__$operation=1 AND AV.AuditOperation='D'  
) src  
PIVOT  
(  
       MAX(src.Value)  
       FOR src.[Key] IN ([H701],[H703],[H702],[H700])  
) PVT;  
  
  GO