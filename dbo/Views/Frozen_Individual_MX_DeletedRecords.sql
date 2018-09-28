CREATE VIEW [dbo].[Frozen_Individual_MX_DeletedRecords]    
AS    
WITH TEMP AS    
(    
SELECT DRA.Candidate_Id FROM DynamicRoleAssignment DRA    
JOIN DynamicRole DR ON DR.DynamicRoleId=DRA.DynamicRole_Id    
JOIN Translation T ON T.TranslationId=DR.Translation_Id    
Join TranslationTerm TT ON TT.Translation_Id=T.TranslationId AND CultureCode=2057    
INNER JOIN Country C ON C.CountryId=DR.Country_Id    
WHERE REPLACE(TT.Value,' ','')  LIKE '%HeadOfHousehold%'    
AND C.CountryISO2A='MX'    
)
,TEMP2 AS      
(      
SELECT DRA.Candidate_Id FROM DynamicRoleAssignment DRA      
JOIN DynamicRole DR ON DR.DynamicRoleId=DRA.DynamicRole_Id      
INNER JOIN Country C ON C.CountryId=DR.Country_Id      
WHERE Dr.Code=4    
AND C.CountryISO2A='MX'      
)    
  
SELECT     
idDomicilio, idIndividuo, data_Inicial, (ISNULL(firstname+' ','')+ISNULL(middilename+' ','')+ISNULL(Lastname,'')) as nome_individuo,Sexo    
,Data_Nascimento, [I601] as idInstrucao, [I604] as idParentesco,[I607] as idEstadoCivil,     
 DonadeCasa, ChefedeFamilia,Chefederenda,[I605] as idAtividade, flgativo, [I609] as peso,    
[I610] as Altura, [I602] as Anos_Estudo, [I606] as ocupacao, [I603] as idTipoEscuela,     
[I612] as Iduso_internet, [I613] as Idlocal_internet ,[I608] AS  TipoSalud,[Homemaker] AS [Ama De Casa]  
,AVGPSUpdateTimeStamp    
FROM     
(    
select COL.Sequence AS idDomicilio, I.IndividualId AS idIndividuo, CAST(YEAR(GETDATE()) AS VARCHAR)+'-01-01 00:00:00.000' as data_Inicial    
,dbo.GetTranslationValue(ISE.Translation_Id,2057) as Sexo    
,PIden.DateOfBirth as Data_Nascimento,     
PIden.FirstOrderedName AS firstname,    
PIden.MiddleOrderedName as middilename,
PIden.LastOrderedName as Lastname,     
CASE    
WHEN  COL.GroupContact_Id=I.GUIDreference THEN 1    
ELSE 0 END AS DonadeCasa,    
CASE    
WHEN  T.Candidate_Id=I.GUIDreference THEN 1    
ELSE 0 END AS ChefedeFamilia,
CASE      
WHEN  T2.Candidate_Id=I.GUIDreference THEN 1      
ELSE 0 END AS Chefederenda,     
CASE    
WHEN  PL.PanelMember_Id=COL.GUIDreference THEN 1    
ELSE 0 END  AS flgativo    
,CASE    
WHEN A.[Type]='Enum' THEN ISNULL(ED.Value,'')    
WHEN A.[Type]='Date' THEN FORMAT(TRY_PARSE(AV.Value AS DATETIME USING 'en-US'), 'yyyy-MM-dd hh:mm:ss')    
ELSE  AV.Value    
END AS  Value,A.[Key]       
,AV.AuditDate AS AVGPSUpdateTimeStamp    
FROM Individual I    
JOIN PersonalIdentification PIden ON Piden.PersonalIdentificationId=I.PersonalIdentificationId    
JOIN IndividualSex ISE ON ISE.GUIDReference=I.Sex_Id    
JOIN CollectiveMembership CM ON CM.Individual_Id=I.GUIDreference    
JOIN Collective COL ON COL.GUIDreference=CM.Group_Id    
INNER JOIN Country C ON C.CountryId=COL.CountryId    
INNER JOIN Attribute A ON COL.CountryId=A.Country_Id    
LEFT JOIN TEMP T ON T.Candidate_Id=I.GUIDReference
LEFT JOIN TEMP2 T2 ON T2.Candidate_Id=I.GUIDReference     
LEFT JOIN (    
SELECT PL.PanelMember_Id FROM panelist PL    
JOIN Panel P ON P.GUIDReference=PL.Panel_Id    
WHERE P.Name='PNC'    
) PL ON PL.PanelMember_Id=COL.GUIDreference    
LEFT JOIN GPS_PM_Latam_Audit.audit.AttributeValue av    
ON av.__$operation=1 AND av.AuditOperation='D' AND AV.CandidateId=I.GUIDReference  AND A.GUIDReference=AV.DemographicId   
--AND I.CountryId=AV.Country_Id   
--LEFT JOIN Attributevalue AV ON AV.CandidateId=I.GUIDReference  AND A.GUIDReference=AV.DemographicId AND I.CountryId=AV.Country_Id    
LEFT JOIN EnumDefinition ED ON ED.Id=AV.EnumDefinition_Id    
WHERE  C.CountryISO2A='MX'    
AND A.[Key] IN ('I601','I604','I607','I605','I609','I610','I602','I606','I603','I612','I613','I608','Homemaker')    
) src    
PIVOT     
(    
MAX(src.Value)    
FOR src.[Key] IN ([I601],[I604],[I607],[I605],[I609],[I610],[I602],[I606],[I603],[I612],[I613],[I608],[Homemaker])    
) PVT;  

GO
