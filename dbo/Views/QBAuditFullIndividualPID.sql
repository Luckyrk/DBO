

CREATE VIEW [dbo].[QBAuditFullIndividualPID]
AS

	SELECT dbo.Country.CountryISO2A
	,Ind.IndividualId
	,dbo.PersonalIdentification.DateOfBirth
	,dbo.IndividualSex.Code SexCode
	,CAST(SEXTRAN.Keyname AS NVARCHAR(255)) AS SexDescription
	,dbo.IndividualTitle.Code TitleCode
	,CAST(TITTRAN.KeyName AS NVARCHAR(255)) AS TitleDescription
	,dbo.PersonalIdentification.FirstOrderedName
	,dbo.PersonalIdentification.MiddleOrderedName
	,dbo.PersonalIdentification.LastOrderedName
	,dbo.StateDefinition.Code StateCode
	,dbo.Candidate.EnrollmentDate
	,dbo.GeographicArea.Code GeographicAreaCode
	,ic.Comment
	,Ind.GPSUser
	,Ind.GPSUpdateTimestamp
	,Ind.CreationTimeStamp
	,Ind.[AuditOperation]
FROM dbo.Country
INNER JOIN dbo.Candidate ON dbo.Candidate.Country_Id = dbo.Country.CountryId
INNER JOIN [GPS_PM_FRA_Audit].[audit].[Individual] Ind ON dbo.Candidate.GUIDReference = Ind.GUIDReference
INNER JOIN dbo.PersonalIdentification ON Ind.PersonalIdentificationId = dbo.PersonalIdentification.PersonalIdentificationId
INNER JOIN dbo.IndividualSex ON Ind.Sex_Id = dbo.IndividualSex.GUIDReference
LEFT JOIN dbo.IndividualTitle ON dbo.PersonalIdentification.TitleId = dbo.IndividualTitle.GUIDReference
INNER JOIN dbo.Translation AS SEXTRAN ON dbo.IndividualSex.Translation_Id = SEXTRAN.TranslationId
LEFT JOIN dbo.Translation AS TITTRAN ON dbo.IndividualTitle.Translation_Id = TITTRAN.TranslationId
INNER JOIN dbo.StateDefinition ON dbo.Candidate.CandidateStatus = dbo.StateDefinition.Id
LEFT JOIN dbo.GeographicArea ON dbo.Candidate.GeographicArea_Id = dbo.GeographicArea.GUIDReference
LEFT JOIN dbo.IndividualComment ic ON ic.Individual_Id = Ind.GUIDReference
	AND ic.Id = (
		SELECT TOP 1 (ic2.Id)
		FROM [dbo].[IndividualComment] ic2
		WHERE ic2.Individual_Id = ic.Individual_Id
		ORDER BY GPSUpdateTimestamp DESC
		)
where Ind.GPSUser in ('QBImport','QBFRImport')
and Ind.AuditOperation in ('I', 'N')

GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'CountryISO2A  - Holds the ISO value for each GPS Country eg: VN, CL, TW. Could be used as a filter on the Full Views.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditFullIndividualPID', @level2type=N'COLUMN',@level2name=N'CountryISO2A'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'IndividualId  - Holds the Business ID for the Individual, based on the format specified by a Country eg: 1234567-01.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditFullIndividualPID', @level2type=N'COLUMN',@level2name=N'IndividualId'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'DateOfBirth - when born.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditFullIndividualPID', @level2type=N'COLUMN',@level2name=N'DateOfBirth'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'SexCode  - Holds the GenderID for the Individual. 1 = Male, 2 = Female and 3 = Unknown.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditFullIndividualPID', @level2type=N'COLUMN',@level2name=N'SexCode'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'SexDescription  - Holds the Gender for the Individual.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditFullIndividualPID', @level2type=N'COLUMN',@level2name=N'SexDescription'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'TitleCode  - Title code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditFullIndividualPID', @level2type=N'COLUMN',@level2name=N'TitleCode'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'TitleDescription  - Holds the Title of an Individual, where specified.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditFullIndividualPID', @level2type=N'COLUMN',@level2name=N'TitleDescription'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'FirstOrderedName  - Holds the first name of an Individual. Some countries may not use this value' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditFullIndividualPID', @level2type=N'COLUMN',@level2name=N'FirstOrderedName'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'MiddleOrderedName  - middle name of an individual.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditFullIndividualPID', @level2type=N'COLUMN',@level2name=N'MiddleOrderedName'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'LastOrderedName  - Last name of an individual.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditFullIndividualPID', @level2type=N'COLUMN',@level2name=N'LastOrderedName'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'StateCode  - Individual state, e.g. participant, non-participant, deceased.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditFullIndividualPID', @level2type=N'COLUMN',@level2name=N'StateCode'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'EnrollmentDate  - date associated to Kantar.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditFullIndividualPID', @level2type=N'COLUMN',@level2name=N'EnrollmentDate'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'GeographicAreaCode  - The code for a Geographic Area.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditFullIndividualPID', @level2type=N'COLUMN',@level2name=N'GeographicAreaCode'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'Comment  - comment held against the individual.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditFullIndividualPID', @level2type=N'COLUMN',@level2name=N'Comment'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'GPSUser  - the GPS user.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditFullIndividualPID', @level2type=N'COLUMN',@level2name=N'GPSUser'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'GPSUpdateTimestamp  - update timestamp.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditFullIndividualPID', @level2type=N'COLUMN',@level2name=N'GPSUpdateTimestamp'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'CreationTimeStamp  - creation timestamp.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditFullIndividualPID', @level2type=N'COLUMN',@level2name=N'CreationTimeStamp'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'AuditOperation  - audit operation.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditFullIndividualPID', @level2type=N'COLUMN',@level2name=N'AuditOperation'
GO

EXEC sys.sp_addextendedproperty @name=N'Associated Views', @value=N'QBAuditFullIndividualPID, IndividualPID,' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditFullIndividualPID'
GO

EXEC sys.sp_addextendedproperty @name=N'Business Area', @value=N'Individuals' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditFullIndividualPID'
GO

EXEC sys.sp_addextendedproperty @name=N'Description', @value=N'Personal Identifiable Data (PID) - Individual Names, Gender, Title, Date of Birth etc. ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditFullIndividualPID'
GO
