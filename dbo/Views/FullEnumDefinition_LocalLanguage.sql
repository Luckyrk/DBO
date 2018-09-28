USE [GPS_PM_Latam]
GO

/****** Object:  View [dbo].[FullEnumDefinition]    Script Date: 10/07/2018 08:57:27 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[FullEnumDefinition_LocalLanguage]
AS


--AR
	SELECT CountryISO2A, a.[Key], tt1.Value AS AttributeDescription, ed.Value AS EnumValue, tt2.Value AS LocalEnumDescription FROM Attribute a
		INNER JOIN TranslationTerm tt1 ON a.Translation_ID = tt1.Translation_Id
		INNER JOIN Country c ON a.Country_ID = c.CountryID
		INNER JOIN EnumDefinition ed ON a.GUIDReference = ed.Demographic_ID
		INNER JOIN TranslationTerm tt2 ON ed.Translation_Id = tt2.Translation_Id
	WHERE [Type] = 'enum'
	AND tt1.CultureCode = 11274
	AND tt2.CultureCode = 11274
	AND [Key] NOT LIKE '%GDA%'
	AND c.CountryID = (SELECT CountryID FROM Country WHERE CountryISO2A = 'AR')
UNION ALL
--BO
	SELECT CountryISO2A, a.[Key], tt1.Value AS AttributeDescription, ed.Value AS EnumValue, tt2.Value AS LocalEnumDescription FROM Attribute a
		INNER JOIN TranslationTerm tt1 ON a.Translation_ID = tt1.Translation_Id
		INNER JOIN Country c ON a.Country_ID = c.CountryID
		INNER JOIN EnumDefinition ed ON a.GUIDReference = ed.Demographic_ID
		INNER JOIN TranslationTerm tt2 ON ed.Translation_Id = tt2.Translation_Id
	WHERE [Type] = 'enum'
	AND tt1.CultureCode = 16394
	AND tt2.CultureCode = 16394
	AND [Key] NOT LIKE '%GDA%'
	AND c.CountryID = (SELECT CountryID FROM Country WHERE CountryISO2A = 'BO')
UNION ALL
--BR
	SELECT CountryISO2A, a.[Key], tt1.Value AS AttributeDescription, ed.Value AS EnumValue, tt2.Value AS LocalEnumDescription FROM Attribute a
		INNER JOIN TranslationTerm tt1 ON a.Translation_ID = tt1.Translation_Id
		INNER JOIN Country c ON a.Country_ID = c.CountryID
		INNER JOIN EnumDefinition ed ON a.GUIDReference = ed.Demographic_ID
		INNER JOIN TranslationTerm tt2 ON ed.Translation_Id = tt2.Translation_Id
	WHERE [Type] = 'enum'
	AND tt1.CultureCode = 1046
	AND tt2.CultureCode = 1046
	AND [Key] NOT LIKE '%GDA%'
	AND c.CountryID = (SELECT CountryID FROM Country WHERE CountryISO2A = 'BR')
UNION ALL
--CL
SELECT CountryISO2A, a.[Key], tt1.Value AS AttributeDescription, ed.Value AS EnumValue, tt2.Value AS LocalEnumDescription FROM Attribute a
	INNER JOIN TranslationTerm tt1 ON a.Translation_ID = tt1.Translation_Id
	INNER JOIN Country c ON a.Country_ID = c.CountryID
	INNER JOIN EnumDefinition ed ON a.GUIDReference = ed.Demographic_ID
	INNER JOIN TranslationTerm tt2 ON ed.Translation_Id = tt2.Translation_Id
WHERE [Type] = 'enum'
AND tt1.CultureCode = 13322
AND tt2.CultureCode = 13322
AND [Key] NOT LIKE '%GDA%'
AND c.CountryID = (SELECT CountryID FROM Country WHERE CountryISO2A = 'CL')
UNION ALL
--CO
SELECT CountryISO2A, a.[Key], tt1.Value AS AttributeDescription, ed.Value AS EnumValue, tt2.Value AS LocalEnumDescription FROM Attribute a
	INNER JOIN TranslationTerm tt1 ON a.Translation_ID = tt1.Translation_Id
	INNER JOIN Country c ON a.Country_ID = c.CountryID
	INNER JOIN EnumDefinition ed ON a.GUIDReference = ed.Demographic_ID
	INNER JOIN TranslationTerm tt2 ON ed.Translation_Id = tt2.Translation_Id
WHERE [Type] = 'enum'
AND tt1.CultureCode = 9226
AND tt2.CultureCode = 9226
AND [Key] NOT LIKE '%GDA%'
AND c.CountryID = (SELECT CountryID FROM Country WHERE CountryISO2A = 'CO')
UNION ALL
--EC
SELECT CountryISO2A, a.[Key], tt1.Value AS AttributeDescription, ed.Value AS EnumValue, tt2.Value AS LocalEnumDescription FROM Attribute a
	INNER JOIN TranslationTerm tt1 ON a.Translation_ID = tt1.Translation_Id
	INNER JOIN Country c ON a.Country_ID = c.CountryID
	INNER JOIN EnumDefinition ed ON a.GUIDReference = ed.Demographic_ID
	INNER JOIN TranslationTerm tt2 ON ed.Translation_Id = tt2.Translation_Id
WHERE [Type] = 'enum'
AND tt1.CultureCode = 12298
AND tt2.CultureCode = 12298
AND [Key] NOT LIKE '%GDA%'
AND c.CountryID = (SELECT CountryID FROM Country WHERE CountryISO2A = 'EC')
UNION ALL
--GT
SELECT CountryISO2A, a.[Key], tt1.Value AS AttributeDescription, ed.Value AS EnumValue, tt2.Value AS LocalEnumDescription FROM Attribute a
	INNER JOIN TranslationTerm tt1 ON a.Translation_ID = tt1.Translation_Id
	INNER JOIN Country c ON a.Country_ID = c.CountryID
	INNER JOIN EnumDefinition ed ON a.GUIDReference = ed.Demographic_ID
	INNER JOIN TranslationTerm tt2 ON ed.Translation_Id = tt2.Translation_Id
WHERE [Type] = 'enum'
AND tt1.CultureCode = 4106
AND tt2.CultureCode = 4106
AND [Key] NOT LIKE '%GDA%'
AND c.CountryID = (SELECT CountryID FROM Country WHERE CountryISO2A = 'GT')
--ORDER BY CountryISO2A, [Key], ed.Value
UNION ALL
--MX
SELECT CountryISO2A, a.[Key], tt1.Value AS AttributeDescription, ed.Value AS EnumValue, tt2.Value AS LocalEnumDescription FROM Attribute a
	INNER JOIN TranslationTerm tt1 ON a.Translation_ID = tt1.Translation_Id
	INNER JOIN Country c ON a.Country_ID = c.CountryID
	INNER JOIN EnumDefinition ed ON a.GUIDReference = ed.Demographic_ID
	INNER JOIN TranslationTerm tt2 ON ed.Translation_Id = tt2.Translation_Id
WHERE [Type] = 'enum'
AND tt1.CultureCode = 2058
AND tt2.CultureCode = 2058
AND [Key] NOT LIKE '%GDA%'
AND c.CountryID = (SELECT CountryID FROM Country WHERE CountryISO2A = 'MX')
UNION ALL
--PE
SELECT CountryISO2A, a.[Key], tt1.Value AS AttributeDescription, ed.Value AS EnumValue, tt2.Value AS LocalEnumDescription FROM Attribute a
	INNER JOIN TranslationTerm tt1 ON a.Translation_ID = tt1.Translation_Id
	INNER JOIN Country c ON a.Country_ID = c.CountryID
	INNER JOIN EnumDefinition ed ON a.GUIDReference = ed.Demographic_ID
	INNER JOIN TranslationTerm tt2 ON ed.Translation_Id = tt2.Translation_Id
WHERE [Type] = 'enum'
AND tt1.CultureCode = 10250
AND tt2.CultureCode = 10250
AND [Key] NOT LIKE '%GDA%'
AND c.CountryID = (SELECT CountryID FROM Country WHERE CountryISO2A = 'PE')
UNION ALL
--VE
SELECT CountryISO2A, a.[Key], tt1.Value AS AttributeDescription, ed.Value AS EnumValue, tt2.Value AS LocalEnumDescription FROM Attribute a
	INNER JOIN TranslationTerm tt1 ON a.Translation_ID = tt1.Translation_Id
	INNER JOIN Country c ON a.Country_ID = c.CountryID
	INNER JOIN EnumDefinition ed ON a.GUIDReference = ed.Demographic_ID
	INNER JOIN TranslationTerm tt2 ON ed.Translation_Id = tt2.Translation_Id
WHERE [Type] = 'enum'
AND tt1.CultureCode = 8202
AND tt2.CultureCode = 8202
AND [Key] NOT LIKE '%GDA%'
AND c.CountryID = (SELECT CountryID FROM Country WHERE CountryISO2A = 'VE')
--ORDER BY CountryISO2A, [Key], ed.Value


GO

GRANT SELECT ON [FullEnumDefinition_LocalLanguage] TO GPSBusiness

GO