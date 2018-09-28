CREATE PROCEDURE [dbo].[ValidateAnonymization] (
	 @pHouseholdCodes StringIdTableType READONLY
	,@pIndividualCodes StringIdTableType READONLY
	,@pCountryId UNIQUEIDENTIFIER
	,@pCultureCode INT = 2057
	,@pUser NVARCHAR(200) = ''
	)
AS
BEGIN

	SET NOCOUNT ON;

	
	DECLARE @Household TABLE (
		GUIDReference UNIQUEIDENTIFIER NOT NULL,
		GroupId NVARCHAR(200) NULL,
		Ok BIT NOT NULL DEFAULT(0),
		[Status] NVARCHAR(200) NULL
	)

	DECLARE @Indiv TABLE (
		GUIDReference UNIQUEIDENTIFIER NOT NULL,
		IndividualId NVARCHAR(200) NULL,
		Ok BIT NOT NULL DEFAULT(0),
		[Status] NVARCHAR(200) NULL
	)
	
	INSERT INTO @Household
	SELECT GUIDReference, hc.Id AS GroupId, 1, ''
	FROM Collective c
	JOIN @pHouseholdCodes hc 
		ON c.CountryId=@pCountryId AND hc.Id NOT LIKE '%[^0-9]%' 
	WHERE CAST(hc.Id AS INT)=c.Sequence

	
	INSERT INTO @Indiv	
		SELECT DISTINCT i.GUIDReference, i.IndividualId, 1, '' as [Status]
	FROM Individual i	
	JOIN CollectiveMembership cm ON cm.Individual_Id=i.GUIDReference
	JOIN @Household h ON h.GUIDReference=cm.Group_Id
	JOIN StateDefinition sd ON sd.Id=cm.State_Id AND sd.InactiveBehavior=0	
	UNION	
		SELECT i.GUIDReference, i.IndividualId, 
		IIF(h.GroupContact_Id=i.GUIDReference, 0, 1), 
		IIF(h.GroupContact_Id=i.GUIDReference, 'IndividualCannotBeAnonymizedGroupContact', '') as [Status]
	FROM Individual i
	JOIN CollectiveMembership cm ON cm.Individual_Id=i.GUIDReference
	JOIN Collective h ON h.GUIDReference=cm.Group_Id
	JOIN StateDefinition sd ON sd.Id=cm.State_Id AND sd.InactiveBehavior=0
	JOIN @pIndividualCodes ic ON i.CountryId=@pCountryId AND ic.Id=i.IndividualId


	IF OBJECT_ID('tempdb..#ActiveIndividuals') IS NOT NULL
		DROP TABLE #ActiveIndividuals

	SELECT DISTINCT i.GUIDReference, i.IndividualId
	INTO #ActiveIndividuals
	FROM @Indiv vi
	JOIN Individual i ON vi.GUIDReference=i.GUIDReference
	JOIN Panelist p ON p.PanelMember_Id=i.GUIDReference
	JOIN StateDefinition sd ON sd.Id=p.State_Id
	WHERE
		sd.Code <> 'PanelistDroppedOffState'

	-- Remove non dropped off panelists.
	UPDATE vi SET Ok=0, [Status] = 'IndividualCannotBeAnonymizedNotDroppedOff'
	FROM @Indiv vi
	JOIN #ActiveIndividuals ai ON ai.GUIDReference=vi.GUIDReference

	SELECT
		IIF(ISNULL(origin.GroupId, '')<>'', origin.GroupId, CONCAT(c.sequence, '')) AS GroupId, 
		IIF(origin.IndividualId <> '', origin.IndividualId, vi.IndividualId) AS IndividualId,
		IIF(vi.Ok IS NULL,'IndividualCannotBeAnonymizedNotFound', IIF(vi.Ok=1, '', vi.[Status])) AS [Status],
		vi.GUIDReference AS IndividualGuid,
		IIF(ISNULL(origin.GroupId, '')<>'', c.GUIDReference, NULL) AS GroupGuid
	INTO #TempResult
	FROM 
		(SELECT 1 as a) a
	LEFT JOIN @Household vh	ON 1=1
	LEFT JOIN (SELECT cm.* 
				FROM CollectiveMembership cm
				JOIN StateDefinition sd ON sd.Id=cm.State_Id AND InactiveBehavior=0 ) AS cm ON vh.GUIDReference=cm.Group_Id
	LEFT JOIN @Indiv vi ON ISNULL(cm.Individual_Id, vi.GUIDReference) = vi.GUIDReference	
	LEFT JOIN Collective c ON c.GUIDReference IN (cm.Group_Id, vh.GUIDReference)
	LEFT JOIN (SELECT hc.Id AS GroupId, '' AS IndividualId FROM @pHouseholdCodes hc 
				UNION
				SELECT '' AS GroupId, ic.Id FROM @pIndividualCodes ic) AS origin ON vh.GroupId=origin.GroupId OR vi.IndividualId=origin.IndividualId


	UPDATE tr
		SET [Status] = ISNULL(tt.Value, CONCAT('{{', tr.[Status], '}}'))
	FROM #TempResult tr
	LEFT JOIN Translation t ON t.KeyName=tr.[Status]
	LEFT JOIN TranslationTerm tt ON t.TranslationId=tt.Translation_Id AND tt.CultureCode=@pCultureCode
	WHERE ISNULL(tr.[Status], '')<>''

	SELECT * FROM #TempResult
	DROP TABLE #TempResult
END
