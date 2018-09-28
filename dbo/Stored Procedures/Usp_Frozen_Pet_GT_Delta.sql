CREATE Procedure [dbo].[Usp_Frozen_Pet_GT_Delta]      
(      
@ServerCurrentDate DATETIME,      
@CountryCode VARCHAR(10)      
)      
AS      
BEGIN      
 DECLARE @ViewName VARCHAR(500)='Frozen_Pet_GT',@CountryFromDate DATETIME ,@CountryCurrentDate DATETIME ,@ServerFromDate DATETIME      
 DECLARE @isMatched BIT=0 
 IF @CountryCode IS NULL        
 BEGIN        
 SET @CountryCode='GT'        
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
 
 IF Object_Id('dbo.Frozen_Pet_GT_Delta_Current') IS NOT NULL          
 BEGIN          
 DROP TABLE Frozen_Pet_GT_Delta_Current          
 END       
 IF Object_Id('dbo.FrozenPetChanges') IS NOT NULL          
 BEGIN          
 DROP TABLE FrozenPetChanges          
 END   
 IF Object_Id('Tempdb..#FrozenPetTemp') IS NOT NULL          
 BEGIN          
 DROP TABLE #FrozenPetTemp          
 END  
     
 CREATE TABLE [dbo].[Frozen_Pet_GT_Delta_Current](      
  GroupBusinessId INT,      
  idanimal NVARCHAR(MAX),      
  idtamanho NVARCHAR(800),      
  idtipo_alimentacao NVARCHAR(800),      
  edad NVARCHAR(800),      
  PetNO INT,      
  [Load_date] [datetime] NULL,      
  isUpdated BIT NOT NULL DEFAULT 1,
  [Country_Load_date] [datetime] NULL     
     
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY];      
      
--CREATE TABLE FrozenPetChanges      
--(      
--GroupId INT,  
--PetNo INT ,    
--isDeleted BIT DEFAULT 0      
--)     

--CREATE TABLE #FrozenPetTemp      
--(              
--	GroupId INT ,
--	PetNo INT    
--)     
--INSERT INTO #FrozenPetTemp       
SELECT COL.sequence AS GroupId,B.BelongingCode AS PetNo
INTO #FrozenPetTemp             
       FROM               
       Country C  
       INNER JOIN Attribute A ON C.CountryId=A.Country_Id  
       INNER JOIN GPS_PM_Latam_Audit.audit.AttributeValue AV ON AV.RespondentId IS NOT NULL AND A.GUIDReference=AV.DemographicId  
       INNER JOIN Belonging B ON B.GUIDReference = AV.RespondentId  
       INNER JOIN candidate Can ON Can.GUIDReference=B.CandidateId  
       INNER JOIN Collective Col ON Col.GUIDReference=Can.GUIDReference  
       LEFT JOIN EnumDefinition ED ON ED.Id=AV.EnumDefinition_Id          
       WHERE
       C.CountryISO2A='GT' AND
        AV.AuditOperation IN ('I','N')--,'D'      
    AND AV.AuditDate>= @ServerFromDate       
    AND AV.AuditDate <= @ServerCurrentDate

 
--INSERT INTO FrozenPetChanges(GroupId,PetNo)      
SELECT GroupId,PetNo,0 AS isDeleted 
INTO FrozenPetChanges     
FROM #FrozenPetTemp
UNION         
SELECT [GroupBusinessId],PetNO,0 AS isDeleted        
FROM [Frozen_Pet_GT_DeletedRecords] 
WHERE  GPSUpdateTimeStamp>= @ServerFromDate AND GPSUpdateTimeStamp <= @ServerCurrentDate      
    
    
      
 INSERT INTO Frozen_Pet_GT_Delta_Current (GroupBusinessId,idanimal,idtamanho,idtipo_alimentacao,edad,PetNO,[Load_date],[Country_Load_date])      
 SELECT GroupBusinessId,idanimal,idtamanho,idtipo_alimentacao,edad,T1.PetNO,@ServerCurrentDate,@CountryCurrentDate      
 FROM Frozen_Pet_GT T1      
 JOIN FrozenPetChanges T2 ON T1.GroupBusinessId=T2.GroupId  AND T1.PetNO=T2.PetNo  
     
 UPDATE T1 SET T1.isDeleted=1      
 FROM       
 FrozenPetChanges T1      
 LEFT JOIN Frozen_Pet_GT_Delta_Current T2 ON T2.GroupBusinessId=T1.GroupId AND T1.PetNo=T2.PetNO      
 WHERE T2.GroupBusinessId IS NULL      
       
 DELETE FROM B        
 FROM FrozenPetChanges D        
 JOIN Frozen_Pet_GT_Delta_BackUp B ON B.[GroupBusinessId]=D.GroupId AND B.PetNo=D.PetNO        
 WHERE D.isDeleted=1     
      
 MERGE INTO Frozen_Pet_GT_Delta_Current AS tgt      
USING  Frozen_Pet_GT_Delta_BackUp AS src      
    ON  tgt.GroupBusinessId=src.GroupBusinessId AND tgt.PetNO=src.PetNO       
WHEN MATCHED       
    AND ISNULL(tgt.idanimal,'')=ISNULL(src.idanimal,'') AND ISNULL(tgt.idtamanho,'')=ISNULL(src.idtamanho,'')      
 AND ISNULL(tgt.idtipo_alimentacao,'')=ISNULL(src.idtipo_alimentacao,'') AND ISNULL(tgt.edad,'')=ISNULL(src.edad,'')       
 AND tgt.PetNO=src.PetNO      
 THEN  UPDATE set tgt.isUpdated=0      
--No Source      
WHEN NOT MATCHED  BY SOURCE       
  THEN      
  UPDATE set tgt.isUpdated=1;      
  --No Target      
--WHEN NOT MATCHED BY TARGET      
--  THEN      
--  INSERT (GroupBusinessId,idanimal,idtamanho,idtipo_alimentacao,edad,PetNO,[Load_date],isUpdated)      
--  VALUES (GroupBusinessId,idanimal,idtamanho,idtipo_alimentacao,edad,PetNO,@ServerCurrentDate,1);      
      
INSERT INTO Frozen_Views_Delta_Latam      
 SELECT DISTINCT [GroupBusinessId],@ServerCurrentDate,NULL,@CountryCode,@ViewName       
 FROM Frozen_Pet_GT_Delta_Current T1       
 WHERE isUpdated=1       
  UNION      
  SELECT GroupId,@ServerCurrentDate,NULL,@CountryCode,@ViewName         
 FROM FrozenPetChanges T1         
 WHERE isDeleted=1       
     
 DELETE B FROM         
Frozen_Pet_GT_Delta_BackUp B        
JOIN Frozen_Pet_GT_Delta_Current C ON C.GroupBusinessId=B.GroupBusinessId AND C.PetNO=B.PetNO        
WHERE C.isUpdated=1        
          
  INSERT INTO Frozen_Pet_GT_Delta_BackUp        
  SELECT * FROM Frozen_Pet_GT_Delta_Current        
  WHERE isUpdated=1        
     
  DROP TABLE Frozen_Pet_GT_Delta_Current;    
  DROP TABLE FrozenPetChanges; 
  DROP TABLE #FrozenPetTemp   
      
      
      
 INSERT INTO Frozen_Delta_History(Id,CountryCode,ViewName,LastRunDate,CreationDateTime,GPSUpdateTimeStamp,Country_LastRunDate)        
 SELECT NEWID(),@CountryCode,@ViewName,@ServerCurrentDate,GETDATE(),GETDATE(),@CountryCurrentDate      
      
END    

GO