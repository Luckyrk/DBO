CREATE PROCEDURE [dbo].[Usp_Frozen_HouseHold_BR_Delta]          
(          
 @ServerCurrentDate DATETIME,          
 @CountryCode VARCHAR(10)          
)          
AS          
BEGIN          
 DECLARE @ViewName VARCHAR(500)='Frozen_HouseHold_BR',@CountryFromDate DATETIME ,@CountryCurrentDate DATETIME ,@ServerFromDate DATETIME          
 DECLARE @isMatched BIT=0          
 IF @CountryCode IS NULL            
 BEGIN            
 SET @CountryCode='BR'            
 END            
 IF(@ServerCurrentDate IS NULL)            
 BEGIN            
 SET @ServerCurrentDate=GETDATE()            
 END          
 SET @CountryCurrentDate=dbo.GetLocalDateTime(@ServerCurrentDate,@CountryCode)          
             
            
 SELECT TOP 1 @CountryFromDate=Country_LastRunDate,@ServerFromDate=LastRunDate FROM Frozen_Delta_History WHERE ViewName=@ViewName ORDER BY LastRunDate DESC          
           
 IF(@CountryFromDate IS NULL)            
 BEGIN            
  SET @CountryFromDate='1900-01-01'            
 END            
 IF(@ServerFromDate IS NULL)              
 BEGIN              
  SET @ServerFromDate='1900-01-01'              
 END      
       
 SET @ServerFromDate=ISNULL(@ServerFromDate,GETDATE())          
             
          
 IF Object_Id('dbo.Frozen_HouseHold_BR_Delta_Current') IS NOT NULL          
 BEGIN          
 DROP TABLE Frozen_HouseHold_BR_Delta_Current          
 END       
 IF Object_Id('dbo.FrozenHouseHoldChanges') IS NOT NULL          
 BEGIN          
 DROP TABLE FrozenHouseHoldChanges          
 END 
  IF Object_Id('TempDB..#FrozenHouseHoldTemp') IS NOT NULL          
 BEGIN          
 DROP TABLE #FrozenHouseHoldTemp          
 END 
        
 CREATE TABLE [dbo].[Frozen_HouseHold_BR_Delta_Current](          
 [GroupBusinessId] [varchar](100) NOT NULL ,          
 [RegionGroup] [nvarchar](max) NULL,          
 [City code] [nvarchar](max) NULL,          
 [Zone Code] [nvarchar](max) NULL,          
 [County code] [nvarchar](max) NULL,          
 [District code] [nvarchar](max) NULL,          
 [Sub district code] [nvarchar](max) NULL,          
 [Sector code] [nvarchar](max) NULL,          
 [Interviewer code] [nvarchar](max) NULL,          
 [Load_date] [datetime] NULL,          
 isUpdated BIT NOT NULL DEFAULT 1,  
   [Country_Load_date] [datetime] NULL     
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY];          
          
          
--CREATE TABLE FrozenHouseHoldChanges        
--(        
--GroupId INT,        
--isDeleted BIT DEFAULT 0        
--)        
        
--CREATE TABLE #FrozenHouseHoldTemp    
--(            
--GroupId INT    
--)     
    
--DECLARE @ServerFromDate DATETIME=GETDATE()-5,@ServerCurrentDate DATETIME=GETDATE(),@CountryId UNIQUEIDENTIFIER='F65937B8-7600-46AB-BFC1-9C78DBD53ED5'    
    
    
--INSERT INTO #FrozenHouseHoldTemp     
SELECT COL.sequence  AS GroupId         
INTO #FrozenHouseHoldTemp 
       FROM             
       Country C            
       INNER JOIN Attribute A ON C.CountryId=A.Country_Id            
       INNER JOIN GPS_PM_Latam_Audit.audit.Attributevalue AV ON AV.RespondentId IS NOT NULL AND A.GUIDReference=AV.DemographicId            
       JOIN Candidate CA ON CA.GeographicArea_Id=AV.RespondentId            
       INNER JOIN Collective COL ON COL.GUIDReference = CA.GUIDReference         
         LEFT JOIN EnumDefinition ED ON ED.Id=AV.EnumDefinition_Id            
       WHERE  C.CountryISO2A='BR'            
       AND A.[Key] IN ('GDA900','GDA901','GDA902','GDA903','GDA904','GDA905','GDA906')        
       AND AV.AuditOperation IN ('I','N')--,'D'    
    AND AV.AuditDate>= @ServerFromDate     
    AND AV.AuditDate <= @ServerCurrentDate         
       --AND COL.sequence=40          
       UNION            
       SELECT COL.sequence           
       FROM             
       Country C         
       INNER JOIN Attribute A ON C.CountryId=A.Country_Id            
       INNER JOIN GPS_PM_Latam_Audit.audit.Attributevalue AV ON AV.CandidateId IS NOT NULL AND A.GUIDReference=AV.DemographicId            
       INNER JOIN Collective COL ON COL.GUIDReference = AV.CandidateId            
       LEFT JOIN EnumDefinition ED ON ED.Id=AV.EnumDefinition_Id            
  WHERE  C.CountryISO2A='BR'            
       AND A.[Key] ='H450'        
AND AV.AuditOperation IN ('I','N')--,'D'    
AND AV.AuditDate>= @ServerFromDate     
AND AV.AuditDate <= @ServerCurrentDate     
       
--INSERT INTO FrozenHouseHoldChanges(GroupId)        
SELECT GroupId,0 AS isDeleted        
INTO FrozenHouseHoldChanges
FROM #FrozenHouseHoldTemp
UNION           
SELECT [GroupBusinessId],0 AS isDeleted           
FROM [Frozen_HouseHold_BR_DeletedRecords]  WHERE  GPSUpdateTimeStamp>= @ServerFromDate AND GPSUpdateTimeStamp <= @ServerCurrentDate        
        
        
 INSERT INTO Frozen_HouseHold_BR_Delta_Current ([GroupBusinessId],[RegionGroup],[City code],[Zone Code],          
 [County code],[District code],[Sub district code],[Sector code],[Interviewer code],[Load_date],[Country_Load_date])          
 SELECT [GroupBusinessId],[RegionGroup],[City code],[Zone Code],          
 [County code],[District code],[Sub district code],[Sector code],[Interviewer code],@ServerCurrentDate,@CountryCurrentDate          
 FROM Frozen_HouseHold_BR  T1        
 JOIN FrozenHouseHoldChanges T2 ON T1.GroupBusinessId=T2.GroupId        
         
         
 UPDATE T1 SET T1.isDeleted=1        
 FROM         
 FrozenHouseHoldChanges T1        
 LEFT JOIN Frozen_HouseHold_BR_Delta_Current T2 ON T2.GroupBusinessId=T1.GroupId        
 WHERE T2.GroupBusinessId IS NULL        
         
 DELETE FROM B          
 FROM FrozenHouseHoldChanges D          
 JOIN Frozen_HouseHold_BR_Delta_BackUp B ON B.[GroupBusinessId]=D.GroupId           
 WHERE D.isDeleted=1          
         
          
MERGE INTO Frozen_HouseHold_BR_Delta_Current AS tgt          
USING  Frozen_HouseHold_BR_Delta_BackUp AS src          
    ON  tgt.GroupBusinessId=src.GroupBusinessId          
          
WHEN MATCHED           
AND ISNULL(tgt.RegionGroup,'')=ISNULL(src.RegionGroup,'') AND ISNULL(tgt.[City code],'')=ISNULL(src.[City code],'')          
 AND ISNULL(tgt.[Zone Code],'')=ISNULL(src.[Zone Code],'')          
 AND ISNULL(tgt.[County code],'')=ISNULL(src.[County code],'') AND ISNULL(tgt.[District code],'')=ISNULL(src.[District code],'')           
 AND ISNULL(tgt.[Sub district code],'')=ISNULL(src.[Sub district code],'') AND ISNULL(tgt.[Sector code],'')=ISNULL(src.[Sector code],'')          
 AND ISNULL(tgt.[Interviewer code],'')=ISNULL(src.[Interviewer code],'') --AND tgt.Load_date=src.Load_date          
 THEN  UPDATE set tgt.isUpdated=0          
--No Source          
WHEN NOT MATCHED  BY SOURCE           
  THEN          
  UPDATE set tgt.isUpdated=1;          
  --No Target          
--WHEN NOT MATCHED BY TARGET          
--  THEN          
--  INSERT ([GroupBusinessId],[RegionGroup],[City code],[Zone Code],          
--  [County code],[District code],[Sub district code],[Sector code],[Interviewer code],[Load_date],isUpdated)          
--  VALUES ([GroupBusinessId],[RegionGroup],[City code],[Zone Code],          
--  [County code],[District code],[Sub district code],[Sector code],[Interviewer code],@ServerCurrentDate,1);          
INSERT INTO Frozen_Views_Delta_Latam          
 SELECT [GroupBusinessId],@ServerCurrentDate,NULL,@CountryCode,@ViewName           
 FROM Frozen_HouseHold_BR_Delta_Current T1           
 WHERE isUpdated=1          
 UNION        
  SELECT GroupId,@ServerCurrentDate,NULL,@CountryCode,@ViewName           
 FROM FrozenHouseHoldChanges T1           
 WHERE isDeleted=1         
          
DELETE B FROM             
Frozen_HouseHold_BR_Delta_Backup B            
JOIN Frozen_HouseHold_BR_Delta_Current C ON C.[GroupBusinessId]=B.[GroupBusinessId]            
WHERE C.isUpdated=1          
          
  INSERT INTO Frozen_HouseHold_BR_Delta_Backup            
  SELECT * FROM Frozen_HouseHold_BR_Delta_Current            
  WHERE isUpdated=1           
          
DROP TABLE Frozen_HouseHold_BR_Delta_Current;          
           
  INSERT INTO Frozen_Delta_History(Id,CountryCode,ViewName,LastRunDate,CreationDateTime,GPSUpdateTimeStamp,Country_LastRunDate)            
 SELECT NEWID(),@CountryCode,@ViewName,@ServerCurrentDate,GETDATE(),GETDATE(),@CountryCurrentDate          
       
 DROP TABLE FrozenHouseHoldChanges     
 DROP TABLE #FrozenHouseHoldTemp     
          
END 


GO