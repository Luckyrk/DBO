CREATE PROCEDURE [dbo].[Usp_Frozen_Individual_MX_Delta]  
(  
@ServerCurrentDate DATETIME,  
@CountryCode VARCHAR(10)  
)  
AS  
BEGIN  
  
 DECLARE @ViewName VARCHAR(500)='Frozen_Individual_MX',@CountryFromDate DATETIME ,@CountryCurrentDate DATETIME ,@ServerFromDate DATETIME
 DECLARE @CountryId UNIQUEIdentifier 
 SET @CountryId=(SELECT CountryId FROM Country WHERE CountryISO2A=@CountryCode)
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
  
  
 IF Object_Id('dbo.Frozen_Individual_MX_Delta_Current') IS NOT NULL  
 BEGIN  
 DROP TABLE Frozen_Individual_MX_Delta_Current  
 END  
   IF Object_Id('dbo.FrozenIndividualChanges') IS NOT NULL      
 BEGIN      
 DROP TABLE FrozenIndividualChanges      
 END 

 IF Object_Id('TempDB..#FrozenIndividualTemp') IS NOT NULL          
 BEGIN          
 DROP TABLE #FrozenIndividualTemp          
 END 
 CREATE TABLE [dbo].[Frozen_Individual_MX_Delta_Current](  
  idDomicilio int,  
  idIndividuo nvarchar(50),  
  data_Inicial varchar(100),  
  nome_individuo nvarchar(800),  
  Sexo nvarchar(MAX),  
  Data_Nascimento datetime,  
  idInstrucao nvarchar(800),  
  idParentesco nvarchar(800),  
  idEstadoCivil nvarchar(800),  
  DonadeCasa int,  
  ChefedeFamilia int,  
  idAtividade nvarchar(800),  
  flgativo int,  
  peso nvarchar(800),  
  Altura nvarchar(800),  
  Anos_Estudo nvarchar(800),  
  ocupacao nvarchar(800),  
  idTipoEscuela nvarchar(800),  
  Iduso_internet nvarchar(800),  
  Idlocal_internet nvarchar(800),  
  [Load_date] [datetime] NULL,  
  isUpdated BIT NOT NULL DEFAULT 1, 
  [Country_Load_date] [datetime] NULL,
  Chefederenda int,
   TipoSalud nvarchar(800), 
  [Ama De Casa] nvarchar(800)    
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY];  
 
-- CREATE TABLE FrozenIndividualChanges        
--(        
--idDomicilio INT,
--idIndividuo VARCHAR(100),      
--isDeleted BIT DEFAULT 0        
--)
--CREATE TABLE #FrozenIndividualTemp
--(        
--Sequence INT,
--IndividualId VARCHAR(100) collate DATABASE_DEFAULT,      
--) 

--DECLARE @ServerFromDate DATETIME=GETDATE()-5,@ServerCurrentDate DATETIME=GETDATE(),@CountryId UNIQUEIDENTIFIER='F65937B8-7600-46AB-BFC1-9C78DBD53ED5'


--INSERT INTO #FrozenIndividualTemp 
SELECT COL.Sequence,I.IndividualId 
INTO #FrozenIndividualTemp
FROM GPS_PM_Latam_Audit.audit.AttributeValue AV
JOIN Attribute A ON A.GUIDReference=AV.DemographicId
JOIN Individual I ON I.GUIDReference=AV.CandidateId
JOIN CollectiveMembership CM ON CM.Individual_Id=I.GUIDreference  
JOIN Collective COL ON COL.GUIDreference=CM.Group_Id  
WHERE A.Country_Id=@CountryId
AND A.[Key] IN ('I601','I604','I607','I605','I609','I610','I602','I606','I603','I612','I613','I608','Homemaker')  
AND AV.AuditOperation IN ('I','N')--,'D'
AND AV.AuditDate>= @ServerFromDate 
AND AV.AuditDate <= @ServerCurrentDate 
--AND YEAR(AV.AuditDate)>2016

UNION
SELECT COL.Sequence,I.IndividualId FROM GPS_PM_Latam_Audit.audit.Individual  I
JOIN CollectiveMembership CM ON CM.Individual_Id=I.GUIDreference  
JOIN Collective COL ON COL.GUIDreference=CM.Group_Id 
WHERE I.CountryId=@CountryId
AND I.AuditOperation IN ('I','N')--,'D'
AND I.AuditDate>= @ServerFromDate 
AND I.AuditDate <= @ServerCurrentDate
--AND YEAR(I.AuditDate)>2016
UNION
SELECT COL.Sequence,I.IndividualId FROM GPS_PM_Latam_Audit.audit.PersonalIdentification P 
JOIN Individual  I ON I.PersonalIdentificationId=P.PersonalIdentificationId
JOIN CollectiveMembership CM ON CM.Individual_Id=I.GUIDreference  
JOIN Collective COL ON COL.GUIDreference=CM.Group_Id 
WHERE P.Country_Id=@CountryId
AND P.AuditOperation IN ('I','N')--,'D'
AND P.AuditDate>= @ServerFromDate 
AND P.AuditDate <= @ServerCurrentDate
--AND YEAR(P.AuditDate)>2016
UNION
SELECT COL.Sequence,I.IndividualId FROM GPS_PM_Latam_Audit.audit.CollectiveMembership CM
JOIN Individual I ON CM.Individual_Id=I.GUIDreference  
JOIN Collective COL ON COL.GUIDreference=CM.Group_Id 
WHERE CM.Country_Id=@CountryId
AND CM.AuditOperation IN ('I','N') --,'D'
AND CM.AuditDate>= @ServerFromDate 
AND CM.AuditDate <= @ServerCurrentDate
--AND YEAR(CM.AuditDate)>2016
UNION
SELECT COL.Sequence,I.IndividualId FROM  GPS_PM_Latam_Audit.audit.Collective COL 
JOIN CollectiveMembership CM ON COL.GUIDreference=CM.Group_Id 
JOIN Individual I ON CM.Individual_Id=I.GUIDreference  
WHERE COL.CountryId=@CountryId
AND COL.AuditOperation IN ('I','N')--,'D'
AND COL.AuditDate>= @ServerFromDate 
AND COL.AuditDate <= @ServerCurrentDate

  
  
--INSERT INTO FrozenIndividualChanges(idDomicilio,idIndividuo)        
SELECT Sequence AS idDomicilio,IndividualId AS idIndividuo,0 AS isDeleted       
INTO FrozenIndividualChanges
FROM #FrozenIndividualTemp T
UNION           
SELECT idDomicilio,idIndividuo,0 AS isDeleted           
FROM [Frozen_Individual_MX_DeletedRecords]  
WHERE  AVGPSUpdateTimeStamp>= @ServerFromDate 
AND AVGPSUpdateTimeStamp <= @ServerCurrentDate        




INSERT INTO Frozen_Individual_MX_Delta_Current (idDomicilio,idIndividuo,data_Inicial,nome_individuo,Sexo,Data_Nascimento,idInstrucao,
idParentesco,idEstadoCivil,DonadeCasa,ChefedeFamilia,Chefederenda,idAtividade,flgativo,peso,Altura,Anos_Estudo,ocupacao,idTipoEscuela,
Iduso_internet,Idlocal_internet,TipoSalud,[Ama De Casa],Load_date,[Country_Load_date])        
 SELECT T1.idDomicilio,T1.idIndividuo,T1.data_Inicial,T1.nome_individuo,T1.Sexo,T1.Data_Nascimento,T1.idInstrucao,
 T1.idParentesco,T1.idEstadoCivil,T1.DonadeCasa,T1.ChefedeFamilia,T1.Chefederenda,T1.idAtividade,T1.flgativo,T1.peso,T1.Altura,T1.Anos_Estudo,T1.ocupacao
 ,T1.idTipoEscuela,T1.Iduso_internet,T1.Idlocal_internet,T1.TipoSalud,T1.[Ama De Casa],@ServerCurrentDate,@CountryCurrentDate         
 FROM Frozen_Individual_MX T1        
 JOIN FrozenIndividualChanges T2 ON T1.idDomicilio=T2.idDomicilio AND T1.idIndividuo=T2.idIndividuo      
       
 UPDATE T1 SET T1.isDeleted=1        
 FROM         
 FrozenIndividualChanges T1        
 LEFT JOIN Frozen_Individual_MX_Delta_Current T2 ON T1.idDomicilio=T2.idDomicilio AND T1.idIndividuo=T2.idIndividuo       
 WHERE T2.idDomicilio IS NULL        
       
 DELETE FROM B          
 FROM FrozenIndividualChanges D          
 JOIN Frozen_Individual_MX_Delta_BackUp B ON B.idDomicilio=D.idDomicilio AND B.idIndividuo=D.idIndividuo           
 WHERE D.isDeleted=1        
       
  
 MERGE INTO Frozen_Individual_MX_Delta_Current AS tgt  
USING  Frozen_Individual_MX_Delta_BackUp AS src  
    ON  tgt.idDomicilio =src.idDomicilio AND tgt.idIndividuo=src.idIndividuo  
WHEN MATCHED   
AND ISNULL(tgt.data_Inicial,'')=ISNULL(src.data_Inicial,'') AND ISNULL(tgt.nome_individuo,'')=ISNULL(src.nome_individuo,'') AND ISNULL(tgt.Sexo,'')=ISNULL(src.Sexo,'')  
 AND ISNULL(tgt.Data_Nascimento,@ServerCurrentDate)=ISNULL(src.Data_Nascimento,@ServerCurrentDate)  
 AND ISNULL(tgt.idInstrucao,'')=ISNULL(src.idInstrucao,'') AND ISNULL(tgt.idParentesco,'')=ISNULL(src.idParentesco,'') AND ISNULL(tgt.idEstadoCivil,'')=ISNULL(src.idEstadoCivil,'')  
  AND ISNULL(tgt.DonadeCasa,-1)=ISNULL(src.DonadeCasa,-1)  
AND ISNULL(tgt.ChefedeFamilia,-1)=ISNULL(src.ChefedeFamilia,-1) AND ISNULL(tgt.idAtividade,'')=ISNULL(src.idAtividade,'') AND ISNULL(tgt.flgativo,-1)=ISNULL(src.flgativo,-1) AND ISNULL(tgt.peso,'')=ISNULL(src.peso,'')  
AND ISNULL(tgt.Altura,'')=ISNULL(src.Altura,'') AND ISNULL(tgt.Anos_Estudo,'')=ISNULL(src.Anos_Estudo,'')  
AND ISNULL(tgt.ocupacao,'')=ISNULL(src.ocupacao,'') AND ISNULL(tgt.idTipoEscuela,'')=ISNULL(src.idTipoEscuela,'') AND ISNULL(tgt.Iduso_internet,'')=ISNULL(src.Iduso_internet,'')  
 AND ISNULL(tgt.Idlocal_internet,'')=ISNULL(src.Idlocal_internet,'')
 AND ISNULL(tgt.Chefederenda,-1)=ISNULL(src.Chefederenda,-1)
  AND ISNULL(tgt.TipoSalud,'')=ISNULL(src.TipoSalud,'') 
   AND ISNULL(tgt.[Ama De Casa],'')=ISNULL(src.[Ama De Casa],'')   
 THEN  UPDATE set tgt.isUpdated=0  
--No Source  
WHEN NOT MATCHED  BY SOURCE   
  THEN  
  UPDATE set tgt.isUpdated=1;
  --No Target  
--WHEN NOT MATCHED BY TARGET  
--  THEN  
--  INSERT (idDomicilio,idIndividuo,data_Inicial,nome_individuo,Sexo,Data_Nascimento,  
--idInstrucao,idParentesco,idEstadoCivil,DonadeCasa,ChefedeFamilia,idAtividade,flgativo,peso,Altura,Anos_Estudo,ocupacao,  
--idTipoEscuela,Iduso_internet,Idlocal_internet,Load_date,isUpdated)  
--VALUES(idDomicilio,idIndividuo,data_Inicial,nome_individuo,Sexo,Data_Nascimento,  
--idInstrucao,idParentesco,idEstadoCivil,DonadeCasa,ChefedeFamilia,idAtividade,flgativo,peso,Altura,Anos_Estudo,ocupacao,  
--idTipoEscuela,Iduso_internet,Idlocal_internet,@ServerCurrentDate,1);  
  
  
INSERT INTO Frozen_Views_Delta_Latam  
 SELECT DISTINCT idDomicilio,@ServerCurrentDate,NULL,@CountryCode,@ViewName   
 FROM Frozen_Individual_MX_Delta_Current T1   
 WHERE isUpdated=1  
   UNION        
  SELECT idDomicilio,@ServerCurrentDate,NULL,@CountryCode,@ViewName           
 FROM FrozenIndividualChanges T1           
 WHERE isDeleted=1 
  
 DELETE B FROM   
 Frozen_Individual_MX_Delta_BackUp B  
 JOIN Frozen_Individual_MX_Delta_Current C ON C.idDomicilio =B.idDomicilio AND C.idIndividuo=B.idIndividuo  
 WHERE C.isUpdated=1  
    
 INSERT INTO Frozen_Individual_MX_Delta_BackUp  
 SELECT * FROM Frozen_Individual_MX_Delta_Current  
 WHERE isUpdated=1  
  
DROP TABLE Frozen_Individual_MX_Delta_Current;  
DROP TABLE FrozenIndividualChanges;  
DROP TABLE #FrozenIndividualTemp
  
  
INSERT INTO Frozen_Delta_History(Id,CountryCode,ViewName,LastRunDate,CreationDateTime,GPSUpdateTimeStamp,Country_LastRunDate)  
SELECT NEWID(),@CountryCode,@ViewName,@ServerCurrentDate,GETDATE(),GETDATE(),@CountryCurrentDate  

END  

GO
