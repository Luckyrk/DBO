CREATE VIEW [dbo].[QBAuditFullIndividualDetails]
AS

SELECT     dbo.Country.CountryISO2A, ind.IndividualId, dbo.PersonalIdentification.DateOfBirth, dbo.IndividualSex.Code SexCode, CAST ( SEXTRAN.Keyname AS NVARCHAR(255) ) as SexDescription,
           dbo.IndividualTitle.Code TitleCode, CAST ( TITTRAN.KeyName AS NVARCHAR(255) ) as TitleDescription, dbo.PersonalIdentification.FirstOrderedName,
           dbo.PersonalIdentification.MiddleOrderedName, dbo.PersonalIdentification.LastOrderedName, dbo.StateDefinition.Code StateCode, dbo.Candidate.EnrollmentDate, dbo.GeographicArea.Code GeographicAreaCode, ic.Comment
           ,sd.Code as MembershipState, coll.Sequence as GroupId
		   ,Ind.GPSUser, Ind.CreationTimeStamp, Ind.GPSUpdateTimestamp, Ind.AuditOperation
FROM       dbo.Country  INNER JOIN
           dbo.Candidate ON dbo.Candidate.Country_Id = dbo.Country.CountryId INNER JOIN
           [GPS_PM_FRA_Audit].[audit].[Individual] Ind ON dbo.Candidate.GUIDReference = Ind.GUIDReference INNER JOIN
           dbo.PersonalIdentification ON Ind.PersonalIdentificationId = dbo.PersonalIdentification.PersonalIdentificationId INNER JOIN
           dbo.IndividualSex ON Ind.Sex_Id = dbo.IndividualSex.GUIDReference LEFT JOIN
           dbo.IndividualTitle ON dbo.PersonalIdentification.TitleId = dbo.IndividualTitle.GUIDReference INNER JOIN
           dbo.Translation as SEXTRAN ON dbo.IndividualSex.Translation_Id = SEXTRAN.TranslationId LEFT JOIN
           dbo.Translation as TITTRAN ON dbo.IndividualTitle.Translation_Id = TITTRAN.TranslationId inner join
           dbo.StateDefinition on dbo.Candidate.CandidateStatus = dbo.StateDefinition.Id left join
           dbo.GeographicArea on dbo.Candidate.GeographicArea_Id = dbo.GeographicArea.GUIDReference left join
           dbo.IndividualComment ic on ic.Individual_Id = Ind.GUIDReference
           and ic.Id = (select top 1 ( ic2.Id) from [dbo].[IndividualComment] ic2 where ic2.Individual_Id = ic.Individual_Id order by GPSUpdateTimestamp desc)
                 Join CollectiveMembership coms on coms.Individual_Id = Ind.GUIDReference
                 Join StateDefinition sd on sd.Id = coms.State_Id
                 Join Collective coll on coll.GUIDReference = coms.Group_Id
  where Ind.GPSUser in ('QBImport','QBFRImport')
  and Ind.AuditOperation in ('I','N')

GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'CountryISO2A  - Holds the ISO value for each GPS Country eg: VN, CL, TW. Could be used as a filter on the Full Views.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditFullIndividualDetails', @level2type=N'COLUMN',@level2name=N'CountryISO2A'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'IndividualId  - Holds the Business ID for the Individual, based on the format specified by a Country eg: 1234567-01.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditFullIndividualDetails', @level2type=N'COLUMN',@level2name=N'IndividualId'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'DateOfBirth  - Date of birth, when born.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditFullIndividualDetails', @level2type=N'COLUMN',@level2name=N'DateOfBirth'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'SexCode  - Holds the GenderID for the Individual. 1 = Male, 2 = Female and 3 = Unknown.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditFullIndividualDetails', @level2type=N'COLUMN',@level2name=N'SexCode'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'SexDescription  - Holds the Gender for the Individual.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditFullIndividualDetails', @level2type=N'COLUMN',@level2name=N'SexDescription'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'TitleCode  - Title code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditFullIndividualDetails', @level2type=N'COLUMN',@level2name=N'TitleCode'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'TitleDescription  - Holds the Title of an Individual, where specified.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditFullIndividualDetails', @level2type=N'COLUMN',@level2name=N'TitleDescription'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'FirstOrderedName  - Holds the first name of an Individual. Some countries may not use this value' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditFullIndividualDetails', @level2type=N'COLUMN',@level2name=N'FirstOrderedName'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'MiddleOrderedName  - middle name of an individual.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditFullIndividualDetails', @level2type=N'COLUMN',@level2name=N'MiddleOrderedName'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'LastOrderedName  - last name of an individual.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditFullIndividualDetails', @level2type=N'COLUMN',@level2name=N'LastOrderedName'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'StateCode  - Individual state, participant, non-participant etc.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditFullIndividualDetails', @level2type=N'COLUMN',@level2name=N'StateCode'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'EnrollmentDate  - Holds description of column.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditFullIndividualDetails', @level2type=N'COLUMN',@level2name=N'EnrollmentDate'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'GeographicAreaCode  - Geographic Area code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditFullIndividualDetails', @level2type=N'COLUMN',@level2name=N'GeographicAreaCode'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'Comment  - Comment held against the individual.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditFullIndividualDetails', @level2type=N'COLUMN',@level2name=N'Comment'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'MembershipState  - relationship of individual to group, resident, non-resident, deceased.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditFullIndividualDetails', @level2type=N'COLUMN',@level2name=N'MembershipState'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'GroupId  - Holds the Business ID for the Group eg: 123456.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditFullIndividualDetails', @level2type=N'COLUMN',@level2name=N'GroupId'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'GPSUser  - the GPS user.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditFullIndividualDetails', @level2type=N'COLUMN',@level2name=N'GPSUser'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'GPSUpdateTimestamp  - update timestamp.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditFullIndividualDetails', @level2type=N'COLUMN',@level2name=N'GPSUpdateTimestamp'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'CreationTimeStamp  - creation timestamp.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditFullIndividualDetails', @level2type=N'COLUMN',@level2name=N'CreationTimeStamp'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'AuditOperation  - audit operation.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditFullIndividualDetails', @level2type=N'COLUMN',@level2name=N'AuditOperation'
GO

EXEC sys.sp_addextendedproperty @name=N'Associated Views', @value=N'QBAuditFullIndividualDetails,' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditFullIndividualDetails'
GO

EXEC sys.sp_addextendedproperty @name=N'Business Area', @value=N'Individual' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditFullIndividualDetails'
GO

EXEC sys.sp_addextendedproperty @name=N'Description', @value=N'Shows changes made by the Questback import. Provides details of Individuals'' names, gender, DoB, IndividualID, Group and Individual states, enrollment date etc. Data is shown for all Countries' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditFullIndividualDetails'
GO

