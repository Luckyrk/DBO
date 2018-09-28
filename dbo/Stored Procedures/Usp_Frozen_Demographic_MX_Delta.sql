CREATE PROCEDURE [dbo].[Usp_Frozen_Demographic_MX_Delta]      
(      
@ServerCurrentDate DATETIME,      
@CountryCode VARCHAR(10)      
)      
AS      
BEGIN      
      
 DECLARE @ViewName VARCHAR(500)='Frozen_Demographic_MX',@CountryFromDate DATETIME ,@CountryCurrentDate DATETIME ,@ServerFromDate DATETIME      
 DECLARE @isMatched BIT=0      
 IF @CountryCode IS NULL        
 BEGIN        
 SET @CountryCode='MX'        
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
         
 IF Object_Id('dbo.Frozen_Demographic_MX_Delta_Current') IS NOT NULL      
 BEGIN      
 DROP TABLE Frozen_Demographic_MX_Delta_Current      
 END   
 IF Object_Id('dbo.FrozenDemographicChanges') IS NOT NULL      
 BEGIN      
 DROP TABLE FrozenDemographicChanges      
 END      
 CREATE TABLE [dbo].[Frozen_Demographic_MX_Delta_Current](      
 idDomicilio [varchar](100) NOT NULL ,        
 idPosse_Bem [nvarchar](800) NULL,        
 data [nvarchar](800) NULL,        
 Quantidade [nvarchar](800) NULL,        
 [Load_date] [datetime] NULL,        
 isUpdated BIT NOT NULL DEFAULT 1, 
  [Country_Load_date] [datetime] NULL       
    
)       
--CREATE TABLE FrozenDemographicChanges        
--(        
--idDomicilio INT,        
--isDeleted BIT DEFAULT 0        
--)       
      
--INSERT INTO FrozenDemographicChanges(idDomicilio)        
SELECT idDomicilio ,0 AS isDeleted
INTO FrozenDemographicChanges      
FROM Frozen_Demographic_MX WHERE GPSUpdateTimeStamp>= @CountryFromDate AND GPSUpdateTimeStamp <= @CountryCurrentDate          
UNION           
SELECT idDomicilio ,0 AS isDeleted          
FROM [Frozen_Demographic_MX_DeletedRecords]  WHERE  GPSUpdateTimeStamp>= @ServerFromDate AND GPSUpdateTimeStamp <= @ServerCurrentDate        
        
      
 INSERT INTO Frozen_Demographic_MX_Delta_Current (idDomicilio,idPosse_Bem,data,Quantidade,[Load_date],[Country_Load_date])        
 SELECT T1.idDomicilio,T1.idPosse_Bem,T1.data,Quantidade,@ServerCurrentDate,@CountryCurrentDate         
 FROM Frozen_Demographic_MX T1        
 JOIN FrozenDemographicChanges T2 ON T1.idDomicilio=T2.idDomicilio      
       
 UPDATE T1 SET T1.isDeleted=1        
 FROM         
 FrozenDemographicChanges T1        
 LEFT JOIN Frozen_Demographic_MX_Delta_Current T2 ON T2.idDomicilio=T1.idDomicilio        
 WHERE T2.idDomicilio IS NULL        
       
  DELETE FROM B          
 FROM FrozenDemographicChanges D          
 JOIN Frozen_Demographic_MX_Delta_BackUp B ON B.idDomicilio=D.idDomicilio           
 WHERE D.isDeleted=1        
       
       
 MERGE INTO Frozen_Demographic_MX_Delta_Current AS tgt        
USING  Frozen_Demographic_MX_Delta_BackUp AS src        
    ON  tgt.idDomicilio=src.idDomicilio        
WHEN MATCHED         
AND ISNULL(tgt.idPosse_Bem,'')=ISNULL(src.idPosse_Bem,'') AND ISNULL(tgt.data,'')=ISNULL(src.data,'') AND ISNULL(tgt.Quantidade,'')=ISNULL(src.Quantidade,'')         
 THEN  UPDATE set tgt.isUpdated=0        
--No Source        
WHEN NOT MATCHED  BY SOURCE         
  THEN        
  UPDATE set tgt.isUpdated=1  ;      
  --No Target      
--WHEN NOT MATCHED BY TARGET      
--  THEN      
--  INSERT (idDomicilio,idPosse_Bem,data,Quantidade,[Load_date],isUpdated)      
--  VALUES (idDomicilio,idPosse_Bem,data,Quantidade,@GetDate,1);      
      
INSERT INTO Frozen_Views_Delta_Latam        
 SELECT idDomicilio,@ServerCurrentDate,NULL,@CountryCode,@ViewName         
 FROM Frozen_Demographic_MX_Delta_Current T1         
 WHERE isUpdated=1         
  UNION        
  SELECT idDomicilio,@ServerCurrentDate,NULL,@CountryCode,@ViewName           
 FROM FrozenDemographicChanges T1           
 WHERE isDeleted=1         
 
 
          
DELETE B FROM         
Frozen_Demographic_MX_Delta_BackUp B        
JOIN Frozen_Demographic_MX_Delta_Current C ON C.idDomicilio=B.idDomicilio        
WHERE C.isUpdated=1        
          
  INSERT INTO Frozen_Demographic_MX_Delta_BackUp        
  SELECT * FROM Frozen_Demographic_MX_Delta_Current        
  WHERE isUpdated=1        
                
DROP TABLE Frozen_Demographic_MX_Delta_Current;       
DROP TABLE FrozenDemographicChanges;        
       
 --EXEC SP_Rename 'dbo.Frozen_Demographic_MX_Delta_Current','Frozen_Demographic_MX_Delta_BackUp'      
 INSERT INTO Frozen_Delta_History(Id,CountryCode,ViewName,LastRunDate,CreationDateTime,GPSUpdateTimeStamp,Country_LastRunDate)        
 SELECT NEWID(),@CountryCode,@ViewName,@ServerCurrentDate,GETDATE(),GETDATE(),@CountryCurrentDate      
      
END 

GO