CREATE PROCEDURE [dbo].[GetSelectedPanelCardMiddleContent] @pPanelistId UNIQUEIDENTIFIER
	,@pScopeReferenceId UNIQUEIDENTIFIER
	,@pCountryId UNIQUEIDENTIFIER
	,@pCultureCode INT
	,@pIsAdmin BIT
AS
BEGIN
	DECLARE @DefGUID UNIQUEIDENTIFIER

	SET @DefGUID = '00000000-0000-0000-0000-000000000000'

	CREATE TABLE #tmphold (
		Code INT
		,NAME NVARCHAR(400)
		,Individual UNIQUEIDENTIFIER
		,[Order] INT
		)

	INSERT INTO #tmphold
	SELECT D.Code
		,dbo.GetTranslationValue(D.Translation_Id, @pCultureCode) AS NAME
		,ISNULL(DA.Candidate_Id, @DefGUID) AS Individual
		,DRC.[Order]
	FROM ConfigurationSet CS
	INNER JOIN Panel P ON CS.PanelId = P.GUIDReference
	INNER JOIN Panelist PL ON PL.Panel_Id = P.GUIDReference
	INNER JOIN DynamicRoleConfiguration DRC ON CS.ConfigurationSetId = DRC.ConfigurationSetId
	INNER JOIN DynamicRole D ON D.DynamicRoleId = DRC.DynamicRoleId
	LEFT JOIN DynamicRoleAssignment DA ON DA.Panelist_Id = @pPanelistId
		AND D.DynamicRoleId = DA.DynamicRole_Id
	WHERE CS.Type = 'Panel'
		AND PL.GUIDReference = @pPanelistId
		ORDER BY NAME
	SELECT DISTINCT I.GUIDReference AS Id
		,I.IndividualId AS BusinessId
		,IIF(i.IsAnonymized = 1, 'XXXXXXXXX', PIdentity.LastOrderedName) AS [LastName]
		,IIF(i.IsAnonymized = 1, 'XXXXXXXXX', PIdentity.MiddleOrderedName) AS MiddleName
		,IIF(i.IsAnonymized = 1, 'XXXXXXXXX', PIdentity.FirstOrderedName) AS [FirstName]
		,dbo.[GetTranslationValue](IT.Translation_Id, @pCultureCode) AS NAME
	FROM Individual I
	INNER JOIN #tmphold T ON T.Individual = I.GUIDReference
	INNER JOIN PersonalIdentification PIdentity ON PIdentity.PersonalIdentificationId = I.PersonalIdentificationId
	INNER JOIN IndividualTitle IT ON IT.GUIDReference = PIdentity.TitleId

	SELECT *
	FROM #tmphold

	declare @pKeyName1 nvarchar(100)
	set @pKeyName1='OrderHistoryPanelName'
	SELECT 
	CASE
	WHEN KV.Value IS NULL THEN KS.DefaultValue
	ELSE KV.Value
	END AS Value
	from KeyAppSetting KS
	LEFT JOIN KeyValueAppSetting KV ON KV.KeyAppSetting_Id=KS.GUIDReference AND KV.Country_Id=@pCountryID
	WHERE KS.KeyName=@pKeyName1

	DROP TABLE #tmphold
END