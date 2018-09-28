GO

CREATE VIEW [dbo].[FullIndividualAttributesAE] AS 

SELECT *

FROM (	SELECT [CountryISO2A], [IndividualId], A.[Key], ISNULL(AV.Value, ED.Value) AS Value

		FROM Country

		JOIN Individual C on C.CountryId=Country.CountryId

		LEFT JOIN AttributeValue AV ON AV.CandidateID=C.GuidReference OR AV.RespondentID=C.GuidReference

		LEFT JOIN EnumDefinition ED ON ED.Id = AV.EnumDefinition_Id	

		LEFT JOIN Attribute A WITH (NOLOCK) ON AV.DemographicId=A.GUIDReference

		WHERE CountryISO2A = 'AE'

) AS Source PIVOT (MAX([Value]) FOR [Key] IN ( [BACHELORSSHARINGRESOURCE], 
[BACHELORTYPE], 
[EDUCATIONLEVEL], 
[EDUCATIONLEVELMAINWAGEEARNER], 
[LUMIUSERNAME], 
[NATIONALITY], 
[OCCUPATION], 
[OCCUPATIONMAINWAGEEARNER], 
[OTHERNATIONALITY], 
[SEC], 
[SELFAGE], 
[SELFGENDER], 
[SELFMAINWAGEEARNER])) AS PivotTable
GO


EXEC sys.sp_addextendedproperty @name=N'Associated Views', @value=N'Holds details of the associated Views.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'FullIndividualAttributesAE'
GO

EXEC sys.sp_addextendedproperty @name=N'Business Area', @value=N'Holds details of the Business Area of data in the View.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'FullIndividualAttributesAE'
GO

EXEC sys.sp_addextendedproperty @name=N'Description', @value=NULL , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'FullIndividualAttributesAE'
GO

--GRANT SELECT ON [GetViewColumnExtendedProperties] TO GPSBusiness

--GO
