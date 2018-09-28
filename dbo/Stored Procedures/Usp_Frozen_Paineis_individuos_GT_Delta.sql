CREATE PROCEDURE [dbo].[Usp_Frozen_Paineis_individuos_GT_Delta]
(    
	@ServerCurrentDate DATETIME,
	@CountryCode VARCHAR(10)    
)    
AS    
BEGIN    
    
 DECLARE @ViewName VARCHAR(500)='Frozen_Paineis_individuos_GT',@CountryFromDate DATETIME ,@CountryCurrentDate DATETIME ,@ServerFromDate DATETIME    
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
 IF Object_Id('dbo.Frozen_Paineis_individuos_GT_Delta_Current') IS NOT NULL    
 BEGIN    
 DROP TABLE Frozen_Paineis_individuos_GT_Delta_Current    
 END    
 IF Object_Id('dbo.FrozenPaineisindividuosChanges') IS NOT NULL    
 BEGIN    
 DROP TABLE FrozenPaineisindividuosChanges    
 END
 CREATE TABLE [dbo].[Frozen_Paineis_individuos_GT_Delta_Current](    
   idpainel INT,    
   iddomicilio INT,    
   idindividuo BIGINT,    
   Data_Entrada nvarchar(MAX),    
   Data_Saida datetime,    
   Cause_Saida INT,    
   Tipo_Envio varchar(MAX),    
   Censo_Year nvarchar(800),    
   [Load_date] [datetime] NULL,    
   isUpdated BIT NOT NULL DEFAULT 1,
  [Country_Load_date] [datetime] NULL         
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY];    
    
--  CREATE TABLE FrozenPaineisindividuosChanges    
--(    
--idpainel INT,  
--iddomicilio INT,    
--idindividuo BIGINT,  
--isDeleted BIT DEFAULT 0    
--)    
    
--INSERT INTO FrozenPaineisindividuosChanges(idpainel,iddomicilio,idindividuo)    
SELECT idpainel,iddomicilio,idindividuo,0 AS isDeleted
INTO FrozenPaineisindividuosChanges    
FROM Frozen_Paineis_individuos_GT WHERE ((PLGPSUpdateTimeStamp>= @CountryFromDate AND PLGPSUpdateTimeStamp <= @CountryCurrentDate) OR    
  (CMGPSUpdateTimeStamp>= @CountryFromDate AND CMGPSUpdateTimeStamp <= @CountryCurrentDate))        
UNION       
SELECT idpainel,iddomicilio,idindividuo,0 AS isDeleted      
FROM [Frozen_Paineis_individuos_GT_DeletedRecords]  WHERE  ((PLGPSUpdateTimeStamp>= @CountryFromDate AND PLGPSUpdateTimeStamp <= @CountryCurrentDate))    
    
 INSERT INTO Frozen_Paineis_individuos_GT_Delta_Current (idpainel,iddomicilio,idindividuo,Data_Entrada,    
 Data_Saida,Cause_Saida,Tipo_Envio,Censo_Year,[Load_date],[Country_Load_date])    
 SELECT T1.idpainel,T1.iddomicilio,T1.idindividuo,Data_Entrada,    
 Data_Saida,Cause_Saida,Tipo_Envio,Censo_Year,@ServerCurrentDate,@CountryCurrentDate     
 FROM Frozen_Paineis_individuos_GT  T1    
 JOIN FrozenPaineisindividuosChanges T2 ON T1.idpainel=T2.idpainel AND T1.iddomicilio=T2.iddomicilio AND T1.idindividuo=T2.idindividuo    
    
    
 UPDATE T1 SET T1.isDeleted=1    
 FROM     
 FrozenPaineisindividuosChanges T1    
 LEFT JOIN Frozen_Paineis_individuos_GT_Delta_Current T2 ON T1.idpainel=T2.idpainel AND T1.iddomicilio=T2.iddomicilio AND T1.idindividuo=T2.idindividuo     
 WHERE T2.idpainel IS NULL    
   
 DELETE FROM B      
 FROM FrozenPaineisindividuosChanges D      
 JOIN Frozen_Paineis_individuos_GT_Delta_BackUp B ON B.iddomicilio=D.iddomicilio AND B.idpainel = D.idpainel AND B.idindividuo=D.idindividuo  
 WHERE D.isDeleted=1      
     
    
 MERGE INTO Frozen_Paineis_individuos_GT_Delta_Current AS tgt    
USING  Frozen_Paineis_individuos_GT_Delta_BackUp AS src    
    ON  tgt.idpainel=src.idpainel AND tgt.iddomicilio=src.iddomicilio AND tgt.idindividuo=src.idindividuo    
     
WHEN MATCHED     
AND ISNULL(tgt.Data_Entrada,'')=ISNULL(src.Data_Entrada,'') AND ISNULL(tgt.Data_Saida,@ServerCurrentDate)=ISNULL(src.Data_Saida,@ServerCurrentDate) AND ISNULL(tgt.Cause_Saida,-1)=ISNULL(src.Cause_Saida,-1)    
 AND ISNULL(tgt.Tipo_Envio,'')=ISNULL(src.Tipo_Envio,'') AND ISNULL(tgt.Censo_Year,'')=ISNULL(src.Censo_Year,'')    
 THEN  UPDATE set tgt.isUpdated=0    
--No Source    
WHEN NOT MATCHED  BY SOURCE     
  THEN    
  UPDATE set tgt.isUpdated=1;    
  --No Target    
--WHEN NOT MATCHED BY TARGET    
--  THEN    
--  INSERT (idpainel,iddomicilio,idindividuo,Data_Entrada,Data_Saida,Cause_Saida,Tipo_Envio,Censo_Year,[Load_date],isUpdated)    
--  VALUES (idpainel,iddomicilio,idindividuo,Data_Entrada,Data_Saida,Cause_Saida,Tipo_Envio,Censo_Year,@ServerCurrentDate,1);    
    
INSERT INTO Frozen_Views_Delta_Latam    
 SELECT iddomicilio,@ServerCurrentDate,NULL,@CountryCode,@ViewName     
 FROM Frozen_Paineis_individuos_GT_Delta_Current T1     
 WHERE isUpdated=1     
  UNION    
  SELECT iddomicilio,@ServerCurrentDate,NULL,@CountryCode,@ViewName       
 FROM FrozenPaineisindividuosChanges T1       
 WHERE isDeleted=1     
     
DELETE B FROM       
Frozen_Paineis_individuos_GT_Delta_BackUp B      
JOIN Frozen_Paineis_individuos_GT_Delta_Current C ON C.idpainel=B.idpainel AND C.iddomicilio=B.iddomicilio AND C.idindividuo=B.idindividuo     
WHERE C.isUpdated=1      
        
  INSERT INTO Frozen_Paineis_individuos_GT_Delta_BackUp      
  SELECT * FROM Frozen_Paineis_individuos_GT_Delta_Current      
  WHERE isUpdated=1      
    
    
DROP TABLE Frozen_Paineis_individuos_GT_Delta_Current;    
DROP TABLE FrozenPaineisindividuosChanges;       
     
 INSERT INTO Frozen_Delta_History(Id,CountryCode,ViewName,LastRunDate,CreationDateTime,GPSUpdateTimeStamp,Country_LastRunDate)      
 SELECT NEWID(),@CountryCode,@ViewName,@ServerCurrentDate,GETDATE(),GETDATE(),@CountryCurrentDate    
END    

GO