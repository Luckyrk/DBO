GO
--EXEC [Usp_Frozen_Paineis_Domicilios_CL_Delta]

CREATE PROCEDURE [dbo].[Usp_Frozen_Paineis_Domicilios_CL_Delta]  
(  
@ServerCurrentDate DATETIME,  
@CountryCode VARCHAR(10)  
)  
AS  
BEGIN  
  
  
 DECLARE @ViewName VARCHAR(500)='Frozen_Paineis_Domicilios_CL',@CountryFromDate DATETIME ,@CountryCurrentDate DATETIME ,@ServerFromDate DATETIME  
 DECLARE @isMatched BIT=0  
 IF @CountryCode IS NULL    
 BEGIN    
 SET @CountryCode='CL'    
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
 
  
 IF Object_Id('dbo.Frozen_Paineis_Domicilios_CL_Delta_Current') IS NOT NULL  
 BEGIN  
 DROP TABLE Frozen_Paineis_Domicilios_CL_Delta_Current  
 END  
  IF Object_Id('dbo.FrozenPaineisDomiciliosChanges') IS NOT NULL    
 BEGIN    
 DROP TABLE FrozenPaineisDomiciliosChanges    
 END
 CREATE TABLE [dbo].[Frozen_Paineis_Domicilios_CL_Delta_Current](  
   idpainel INT,  
   iddomicilio INT,  
   Data_Entrada DATETIME,  
   Data_Saida DATETIME,  
   Cause_Saida INT,  
   Tipo_Envio NVARCHAR(MAX),  
   [Load_date] [datetime] NULL,  
    isUpdated BIT NOT NULL DEFAULT 1,  
  [Country_Load_date] [datetime] NULL 
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY];  
  
--  CREATE TABLE FrozenPaineisDomiciliosChanges  
--(  
--idpainel VARCHAR(100),
--iddomicilio VARCHAR(100),  
--isDeleted BIT DEFAULT 0  
--) 

--INSERT INTO FrozenPaineisDomiciliosChanges(idpainel,iddomicilio)  
SELECT idpainel,iddomicilio ,0 AS isDeleted
INTO FrozenPaineisDomiciliosChanges
FROM Frozen_Paineis_Domicilios_CL WHERE GPSUpdateTimeStamp>= @CountryFromDate AND GPSUpdateTimeStamp <= @CountryCurrentDate      
UNION     
SELECT idpainel,iddomicilio ,0 AS isDeleted    
FROM [Frozen_Paineis_Domicilios_CL_DeletedRecords]  WHERE GPSUpdateTimeStamp>= @ServerFromDate AND GPSUpdateTimeStamp <= @ServerCurrentDate 
  
  
 INSERT INTO Frozen_Paineis_Domicilios_CL_Delta_Current (idpainel,iddomicilio,Data_Entrada,Data_Saida,Cause_Saida,Tipo_Envio,[Load_date],[Country_Load_date])  
 SELECT T1.idpainel,T1.iddomicilio,Data_Entrada,Data_Saida,Cause_Saida,Tipo_Envio,@ServerCurrentDate,@CountryCurrentDate  
 FROM Frozen_Paineis_Domicilios_CL T1  
 JOIN FrozenPaineisDomiciliosChanges T2 ON T1.idpainel=T2.idpainel AND T1.iddomicilio=T2.iddomicilio
    
    
     UPDATE T1 SET T1.isDeleted=1  
 FROM   
 FrozenPaineisDomiciliosChanges T1  
 LEFT JOIN Frozen_Paineis_Domicilios_CL_Delta_Current T2 ON T2.iddomicilio=T1.iddomicilio AND T1.idpainel=T2.idpainel  
 WHERE T2.iddomicilio IS NULL 
 
  DELETE FROM B    
 FROM FrozenPaineisDomiciliosChanges D    
 JOIN Frozen_Paineis_Domicilios_CL_Delta_BackUp B ON D.iddomicilio=B.iddomicilio  AND D.idpainel=B.idpainel 
 WHERE D.isDeleted=1  
    
    
 MERGE INTO Frozen_Paineis_Domicilios_CL_Delta_Current AS tgt  
USING  Frozen_Paineis_Domicilios_CL_Delta_BackUp AS src  
    ON  tgt.iddomicilio=src.iddomicilio  AND tgt.idpainel=src.idpainel  
WHEN MATCHED   
AND ISNULL(tgt.Data_Entrada,@ServerCurrentDate)=ISNULL(src.Data_Entrada,@ServerCurrentDate) AND ISNULL(tgt.Data_Saida,@ServerCurrentDate)=ISNULL(src.Data_Saida,@ServerCurrentDate) AND ISNULL(tgt.Cause_Saida,-1)=ISNULL(src.Cause_Saida,-1)  
 AND ISNULL(tgt.Tipo_Envio,'')=ISNULL(src.Tipo_Envio,'')  
 THEN  UPDATE set tgt.isUpdated=0  
--No Source  
WHEN NOT MATCHED  BY SOURCE   
  THEN  
  UPDATE set tgt.isUpdated=1;  
  --No Target  
--WHEN NOT MATCHED BY TARGET  
--  THEN  
--  INSERT ([idpainel],iddomicilio,Data_Entrada,Data_Saida,Cause_Saida,Tipo_Envio,[Load_date],isUpdated)  
--  VALUES ([idpainel],iddomicilio,Data_Entrada,Data_Saida,Cause_Saida,Tipo_Envio,@ServerCurrentDate,1);  
  
INSERT INTO Frozen_Views_Delta_Latam  
 SELECT iddomicilio,@ServerCurrentDate,NULL,@CountryCode,@ViewName   
 FROM Frozen_Paineis_Domicilios_CL_Delta_Current T1   
 WHERE isUpdated=1  
 UNION  
  SELECT iddomicilio,@ServerCurrentDate,NULL,@CountryCode,@ViewName     
 FROM FrozenPaineisDomiciliosChanges T1     
 WHERE isDeleted=1  
  

  
 DELETE B FROM     
Frozen_Paineis_Domicilios_CL_Delta_BackUp B    
JOIN Frozen_Paineis_Domicilios_CL_Delta_Current C ON C.iddomicilio=B.iddomicilio  AND C.idpainel=B.idpainel    
WHERE C.isUpdated=1    
      
  INSERT INTO Frozen_Paineis_Domicilios_CL_Delta_BackUp    
  SELECT * FROM Frozen_Paineis_Domicilios_CL_Delta_Current    
  WHERE isUpdated=1    
  
DROP TABLE Frozen_Paineis_Domicilios_CL_Delta_Current; 
DROP TABLE FrozenPaineisDomiciliosChanges;  
   
  
  INSERT INTO Frozen_Delta_History(Id,CountryCode,ViewName,LastRunDate,CreationDateTime,GPSUpdateTimeStamp,Country_LastRunDate)    
 SELECT NEWID(),@CountryCode,@ViewName,@ServerCurrentDate,GETDATE(),GETDATE(),@CountryCurrentDate  
  
END  

GO