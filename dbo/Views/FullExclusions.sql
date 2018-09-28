
CREATE VIEW [dbo].[FullExclusions]
AS
SELECT Country.CountryISO2A
	,Individual.IndividualId
	,CAST(b.KeyName AS NVARCHAR(255)) AS KeyName
	,Exclusion.Range_From
	,Exclusion.Range_To
	,Exclusion.AllIndividuals
	,Exclusion.AllPanels
	,Exclusion.IsClosed
	,Exclusion.GPSUpdateTimestamp
	,Exclusion.CreationTimeStamp
	,Exclusion.GPSUser
	,p.PanelCode
	,p.Name as PanelName
FROM [dbo].[Exclusion]
INNER JOIN [dbo].ExclusionIndividual ON Exclusion.GUIDReference = ExclusionIndividual.Exclusion_Id
INNER JOIN [dbo].Individual ON Individual.GUIDReference = ExclusionIndividual.Individual_Id
INNER JOIN [dbo].ExclusionType ON Exclusion.[Type_Id] = ExclusionType.GUIDReference
INNER JOIN [dbo].Country ON ExclusionType.Country_Id = Country.CountryId
INNER JOIN [dbo].Translation AS b ON b.TranslationId = ExclusionType.Translation_Id
left join ExclusionPanelist ep on ep.Exclusion_Id=Exclusion.GUIDReference
left join Panelist pl on pl.GUIDReference=ep.Panelist_Id
left join Panel p on p.GUIDReference=pl.Panel_Id