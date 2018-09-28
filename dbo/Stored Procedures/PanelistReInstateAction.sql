GO
CREATE PROCEDURE PanelistReInstateAction
@pBusinessId VARCHAR(100),
@pPanelId UNIQUEIDENTIFIER,
@pFromState NVARCHAR(400), --Dropped Out
@pToStateId UNIQUEIDENTIFIER, -- Live
@pCountryCode VARCHAR(10)=NULL
AS
BEGIN
BEGIN TRY 
	DECLARE @FromStateId UNIQUEIDENTIFIER, --Dropped Out StateId
			@ToState NVARCHAR(400), -- Live StateId
			@CountryId UNIQUEIDENTIFIER
	DECLARE @GetDate DATETIME
	SET @GetDate = (select dbo.GetLocalDateTime(GETDATE(),@pCountryCode))

	SET @CountryId =(SELECT TOP 1 CountryId FROM Country WHERE CountryISO2A=@pCountryCode)
	SET @FromStateId=(SELECT TOP 1 Id FROM StateDefinition Code WHERE Code=@pFromState AND Country_Id=@CountryId)
	SET @ToState=(SELECT TOP 1 Code FROM StateDefinition Code WHERE Id=@pToStateId AND Country_Id=@CountryId)


	IF(@pFromState='PanelistDroppedOffState' AND @ToState='PanelistLiveState')
	BEGIN
	DECLARE @StateDefinitionHistoryID UNIQUEIDENTIFIER,@PanelistId UNIQUEIDENTIFIER
	Declare @NoOfDays INT
	
	SET @PanelistId=(SELECT TOP 1 PL.GUIDReference FROM Panelist PL
	JOIN Panel P ON P.GUIDReference=PL.Panel_Id
	JOIN Individual I ON I.GUIDReference=PL.PanelMember_Id
	JOIN Country C ON C.CountryId=P.Country_Id
	WHERE P.GUIDReference=@pPanelId AND I.IndividualId=@pBusinessId)
	
	IF(@PanelistId IS NULL)
	BEGIN

	SET @PanelistId=(SELECT TOP 1 PL.GUIDReference FROM Panelist PL
	JOIN Panel P ON P.GUIDReference=PL.Panel_Id
	JOIN CollectiveMembership CM ON CM.Group_Id=PL.PanelMember_Id
	JOIN Individual I ON I.GUIDReference=CM.Individual_Id
	JOIN Country C ON C.CountryId=P.Country_Id
	WHERE P.GUIDReference=@pPanelId AND I.IndividualId=@pBusinessId
	)	
	END
	
--SET @NoOfDays=
--				(SELECT TOP 1  DATEDIFF(DD,SDH.CreationDate,@GetDate) FROM StateDefinitionHistory SDH WHERE Panelist_Id=@PanelistId AND To_Id=@FromStateId
--					ORDER BY GPSUpdateTimestamp DESC
--					)

--IF (@NoOfDays<=42)
--BEGIN
	INSERT INTO [UK_StateDefinitionHistory_Reinstatement_Dropouts]
	SELECT TOP 1 *,@GetDate FROM StateDefinitionHistory WHERE Panelist_Id=@PanelistId AND To_Id=@FromStateId
	ORDER BY GPSUpdateTimestamp DESC

	SET @StateDefinitionHistoryID=(
	SELECT TOP 1 GUIDReference FROM StateDefinitionHistory WHERE Panelist_Id=@PanelistId AND To_Id=@FromStateId
	ORDER BY GPSUpdateTimestamp DESC
	)

	DELETE FROM StateDefinitionHistory WHERE Panelist_Id=@PanelistId AND GUIDReference=@StateDefinitionHistoryID

	SET @StateDefinitionHistoryID=(
	SELECT TOP 1 GUIDReference FROM StateDefinitionHistory WHERE Panelist_Id=@PanelistId AND From_Id=@FromStateId
	ORDER BY GPSUpdateTimestamp DESC
	)

	INSERT INTO [UK_StateDefinitionHistory_Reinstatement_Dropouts]
	SELECT TOP 1 *,@GetDate FROM StateDefinitionHistory WHERE Panelist_Id=@PanelistId  AND From_Id=@FromStateId
	ORDER BY GPSUpdateTimestamp DESC

	DELETE FROM StateDefinitionHistory WHERE Panelist_Id=@PanelistId AND GUIDReference=@StateDefinitionHistoryID
	END
END TRY
BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(4000);
		DECLARE @ErrorSeverity INT;
		DECLARE @ErrorState INT;

		SELECT @ErrorMessage = ERROR_MESSAGE(),
			   @ErrorSeverity = ERROR_SEVERITY(),
			   @ErrorState = ERROR_STATE();
	
		RAISERROR (@ErrorMessage, -- Message text.
				   @ErrorSeverity, -- Severity.
				   @ErrorState -- State.
				   );
END CATCH
END

--END
GO