
CREATE VIEW [dbo].[ActionTaskTypeView]
AS
SELECT 
	ATT.[ActionCode]
	,TT.Value as ActionTaskDescription
	,ATT.[IsForDpa]
	,ATT.[IsForFqs]
	,ATT.[GPSUser]
	,ATT.[GPSUpdateTimestamp]
	,ATT.[CreationTimeStamp]
	,ATT.[Duration]
	,ATT.[Type]
	,ATT.[IsClosed]
	,ATT.[IsDealtByCommunicationTeam]
FROM ActionTaskType ATT
JOIN TranslationTerm TT ON ATT.[TagTranslation_Id] = TT.Translation_Id AND TT.CultureCode = 2057