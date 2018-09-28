CREATE PROCEDURE [dbo].[GetSumarizationInfo] @pBusinessGUID UNIQUEIDENTIFIER
	,@pCountryId UNIQUEIDENTIFIER
	,@pCultureCode INT
AS
BEGIN
	SELECT TOP 1 I.GUIDReference AS Id
		,I.IndividualId AS BusinessId
		,IIF(I.IsAnonymized = 0, PIdentity.LastOrderedName, 'XXXXXXXXX') AS [LastName]
		,IIF(I.IsAnonymized = 0, PIdentity.MiddleOrderedName, 'XXXXXXXXX') AS MiddleName
		,IIF(I.IsAnonymized = 0, PIdentity.FirstOrderedName, 'XXXXXXXXX') AS [FirstName]
		,dbo.[GetTranslationValue](sd.Label_Id, @pCultureCode) AS StateName
			,dbo.[GetTranslationValue](IT.Translation_Id, @pCultureCode) AS NAME
	FROM Individual I
	INNER JOIN PersonalIdentification PIdentity ON PIdentity.PersonalIdentificationId = i.PersonalIdentificationId
		AND i.GUIDReference = @pBusinessGUID
	INNER JOIN Candidate cand ON cand.GUIDReference = i.GUIDReference
	LEFT JOIN StateDefinitionHistory SDH ON sdh.Candidate_Id = cand.GUIDReference
	INNER JOIN StateDefinition SD ON sd.Id = cand.CandidateStatus
	LEFT JOIN IndividualTitle IT ON IT.GUIDReference = PIdentity.TitleId
	LEFT JOIN IndividualSex INS ON INS.GUIDReference = IT.Sex_Id
	WHERE i.GUIDReference = @pBusinessGUID
		AND cand.Country_Id = @pCountryId
	ORDER BY sdh.CreationDate DESC
END