GO
CREATE VIEW [dbo].[FullIndividualDetails]
AS
SELECT     dbo.Country.CountryISO2A, dbo.Individual.IndividualId, dbo.PersonalIdentification.DateOfBirth, dbo.IndividualSex.Code SexCode, CAST ( SEXTRAN.Keyname AS NVARCHAR(255) ) as SexDescription,
           dbo.IndividualTitle.Code TitleCode, CAST ( TITTRAN.KeyName AS NVARCHAR(255) ) as TitleDescription, dbo.PersonalIdentification.FirstOrderedName,
           dbo.PersonalIdentification.MiddleOrderedName, dbo.PersonalIdentification.LastOrderedName, dbo.StateDefinition.Code StateCode, dbo.Candidate.EnrollmentDate, dbo.GeographicArea.Code GeographicAreaCode, ic.Comment
                 ,sd.Code as MembershipState, coll.Sequence as GroupId
FROM       dbo.Country  INNER JOIN
           dbo.Candidate ON dbo.Candidate.Country_Id = dbo.Country.CountryId INNER JOIN
           dbo.Individual ON dbo.Candidate.GUIDReference = dbo.Individual.GUIDReference INNER JOIN
           dbo.PersonalIdentification ON dbo.Individual.PersonalIdentificationId = dbo.PersonalIdentification.PersonalIdentificationId INNER JOIN
           dbo.IndividualSex ON dbo.Individual.Sex_Id = dbo.IndividualSex.GUIDReference LEFT JOIN
           dbo.IndividualTitle ON dbo.PersonalIdentification.TitleId = dbo.IndividualTitle.GUIDReference INNER JOIN
           dbo.Translation as SEXTRAN ON dbo.IndividualSex.Translation_Id = SEXTRAN.TranslationId LEFT JOIN
           dbo.Translation as TITTRAN ON dbo.IndividualTitle.Translation_Id = TITTRAN.TranslationId inner join
           dbo.StateDefinition on dbo.Candidate.CandidateStatus = dbo.StateDefinition.Id left join
           dbo.GeographicArea on dbo.Candidate.GeographicArea_Id = dbo.GeographicArea.GUIDReference left join
           dbo.IndividualComment ic on ic.Individual_Id = dbo.Individual.GUIDReference
           and ic.Id = (select top 1 ( ic2.Id) from [dbo].[IndividualComment] ic2 where ic2.Individual_Id = ic.Individual_Id order by GPSUpdateTimestamp desc)
                 Join CollectiveMembership coms on coms.Individual_Id = Individual.GUIDReference
                 Join StateDefinition sd on sd.Id = coms.State_Id
                 Join Collective coll on coll.GUIDReference = coms.Group_Id
 

GO