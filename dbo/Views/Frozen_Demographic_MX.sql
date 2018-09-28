CREATE VIEW [dbo].[Frozen_Demographic_MX]  
AS  
 SELECT COL.sequence As idDomicilio,A.[Key] AS idPosse_Bem,  
 CAST(YEAR(GETDATE()) AS VARCHAR)+'0101' AS data,  
 CASE  
 WHEN A.[Type]='Enum' THEN ISNULL(ED.Value,'')  
 WHEN A.[Type]='Date' THEN FORMAT(TRY_PARSE(AV.Value AS DATETIME USING 'en-US'), 'yyyy-MM-dd hh:mm:ss')  
 ELSE  AV.Value  
 END AS  Quantidade  
 ,AV.GPSUpdateTimestamp  
 FROM   
 Country C  
 INNER JOIN Attribute A ON C.CountryId=A.Country_Id  
 INNER JOIN Attributevalue AV ON AV.CandidateId IS NOT NULL AND A.GUIDReference=AV.DemographicId  
 INNER JOIN Collective COL ON COL.GUIDReference = AV.CandidateId  
 LEFT JOIN EnumDefinition ED ON ED.Id=AV.EnumDefinition_Id  
 WHERE  C.CountryISO2A='MX'  
 UNION ALL  
 SELECT COL.sequence As idDomicilio,A.[Key] AS idPosse_Bem,  
 CAST(YEAR(GETDATE()) AS VARCHAR)+'0101' AS data,  
 CASE  
 WHEN A.[Type]='Enum' THEN ISNULL(ED.Value,'')  
 WHEN A.[Type]='Date' THEN FORMAT(TRY_PARSE(AV.Value AS DATETIME USING 'en-US'), 'yyyy-MM-dd hh:mm:ss')  
 ELSE  AV.Value  
 END AS  Quantidade  
 ,AV.GPSUpdateTimestamp  
 FROM   
 Country C  
 INNER JOIN Attribute A ON C.CountryId=A.Country_Id  
 INNER JOIN Attributevalue AV ON AV.RespondentId IS NOT NULL AND A.GUIDReference=AV.DemographicId  
 INNER JOIN Collective COL ON COL.GUIDReference = AV.RespondentId  
 LEFT JOIN EnumDefinition ED ON ED.Id=AV.EnumDefinition_Id  
 WHERE  C.CountryISO2A='MX' 

GO

--GRANT SELECT ON [Frozen_Demographic_MX] TO GPSBusiness

--GO