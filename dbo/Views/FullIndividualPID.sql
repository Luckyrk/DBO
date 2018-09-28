CREATE VIEW [dbo].[FullIndividualPID]  
AS  
SELECT dbo.Country.CountryISO2A  
 ,dbo.Individual.IndividualId  
 ,dbo.PersonalIdentification.DateOfBirth  
 ,dbo.IndividualSex.Code SexCode  
 ,CAST(SEXTRAN.Keyname AS NVARCHAR(255)) AS SexDescription  
 ,dbo.IndividualTitle.Code TitleCode  
 ,CAST(TITTRAN.KeyName AS NVARCHAR(255)) AS TitleDescription  
 ,dbo.PersonalIdentification.FirstOrderedName  
 ,dbo.PersonalIdentification.MiddleOrderedName  
 ,dbo.PersonalIdentification.LastOrderedName  
 ,dbo.StateDefinition.Code StateCode  
 ,sdh.CreationDate as StateChangeDate  
 ,dbo.Candidate.EnrollmentDate  
 ,dbo.GeographicArea.Code GeographicAreaCode  
 ,ic.Comment  
FROM dbo.Country  
INNER JOIN dbo.Candidate ON dbo.Candidate.Country_Id = dbo.Country.CountryId  
INNER JOIN dbo.Individual ON dbo.Candidate.GUIDReference = dbo.Individual.GUIDReference  
INNER JOIN dbo.PersonalIdentification ON dbo.Individual.PersonalIdentificationId = dbo.PersonalIdentification.PersonalIdentificationId  
INNER JOIN dbo.IndividualSex ON dbo.Individual.Sex_Id = dbo.IndividualSex.GUIDReference  
LEFT JOIN dbo.IndividualTitle ON dbo.PersonalIdentification.TitleId = dbo.IndividualTitle.GUIDReference  
INNER JOIN dbo.Translation AS SEXTRAN ON dbo.IndividualSex.Translation_Id = SEXTRAN.TranslationId  
LEFT JOIN dbo.Translation AS TITTRAN ON dbo.IndividualTitle.Translation_Id = TITTRAN.TranslationId  
INNER JOIN dbo.StateDefinition ON dbo.Candidate.CandidateStatus = dbo.StateDefinition.Id  
--left join  StateDefinitionHistory sdh on sdh.To_Id=Candidate.CandidateStatus 
--and sdh.Candidate_Id=Individual.GUIDReference and sdh.CreationDate =(select top 1 max(CreationDate) from   
--  StateDefinitionHistory sdh1 where sdh1.Candidate_Id=Individual.GUIDReference  
--  group by To_Id,CreationDate  
--  order by max(creationdate) desc) 
left join  (select  max(CreationDate) AS CreationDate,To_Id,Candidate_Id from   
  StateDefinitionHistory sdh1 --where sdh1.Candidate_Id=Individual.GUIDReference  
  group by Candidate_Id,To_Id 
  ) sdh on sdh.To_Id=Candidate.CandidateStatus AND sdh.Candidate_Id=Individual.GUIDReference
LEFT JOIN dbo.GeographicArea ON dbo.Candidate.GeographicArea_Id = dbo.GeographicArea.GUIDReference  
LEFT JOIN dbo.IndividualComment ic ON ic.Individual_Id = dbo.Individual.GUIDReference  
 AND ic.Id = (  
  SELECT TOP 1 (ic2.Id)  
  FROM [dbo].[IndividualComment] ic2  
  WHERE ic2.Individual_Id = ic.Individual_Id  
  ORDER BY GPSUpdateTimestamp DESC  
  )