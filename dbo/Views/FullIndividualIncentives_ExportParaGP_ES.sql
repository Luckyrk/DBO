CREATE VIEW FullIndividualIncentives_ExportParaGP_ES
AS
SELECT 'ES' CountryISO2A  
 ,a.IndividualId  
 ,col.sequence GroupId  
 ,c.TransactionDate  
 ,c.Comments  
 ,d.Ammount Amount  
 ,i.Value AS Description_Local  
 ,c.SynchronisationDate 
FROM dbo.Candidate  
INNER JOIN dbo.Country ON dbo.Candidate.Country_ID = dbo.Country.CountryId AND Country.CountryISO2A='ES' 
INNER JOIN dbo.Individual AS a ON dbo.Candidate.GUIDReference = a.GUIDReference AND a.CountryId=Country.CountryId
INNER JOIN IncentiveAccount AS b ON b.IncentiveAccountId = a.GUIDReference  
 AND b.Country_Id = a.CountryId  
INNER JOIN IncentiveAccountTransaction AS c ON c.Account_Id = b.IncentiveAccountId  
 AND c.Country_Id = b.Country_Id  
 AND c.Type = 'credit'  
INNER JOIN IncentiveAccountTransactionInfo AS d ON d.IncentiveAccountTransactionInfoId = c.TransactionInfo_Id  
 AND d.Country_Id = c.Country_Id  
INNER JOIN IncentivePoint AS f ON f.GUIDReference = d.Point_Id  
INNER JOIN CollectiveMembership cmem ON cmem.Individual_Id = a.GuidReference  
INNER JOIN Collective col ON col.GuidReference = cmem.Group_Id  
INNER JOIN Translation AS h ON h.TranslationId = f.Description_Id  
LEFT JOIN ( 
SELECT * FROM ( 
 SELECT ROW_NUMBER() OVER(Partition By Translation_Id ORDER BY CultureCode) SNO,Translation_Id  
  ,Value  
 FROM dbo.TranslationTerm  
 WHERE CultureCode IN ('3082','1086') 
 ) TT WHERE SNO=1
 ) AS i ON i.Translation_Id = h.TranslationId  
 WHERE dbo.Country.CountryISO2A='ES'
 GO

--GRANT SELECT ON FullIndividualIncentives_ExportParaGP_ES TO GPSBusiness
--GRANT SELECT ON FullIndividualIncentives_ExportParaGP_ES TO GPSBusiness_Full
--GO