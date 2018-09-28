CREATE PROCEDURE [dbo].[GetUndoClaimRecords]
@pDiaryDateYear	INT,
@pDiaryDatePeriod	INT,
@pDiaryDateWeek	INT,
@pDiarySourceFull	NVARCHAR(50),
@pPanelName	NVARCHAR(100),
@pPanelId	UNIQUEIDENTIFIER,
@pGpsUser	NVARCHAR(100),
@pGetDate DATETIME,
@pCountryId UNIQUEIDENTIFIER,
@pParametersTable dbo.GridParametersTable READONLY
AS
BEGIN
BEGIN TRY
	SELECT 
	CASE
	WHEN COUNT(0) > 0 THEN 1
	ELSE 0
	END
	AS TotalNoOfRecords FROM UndoClaimData
	WHERE ISNULL(UndoClaimFlag,0)=0 AND PanelId = @pPanelId
	
	--SELECT 1
	
	Declare @Getrecords INT
	SET @Getrecords=(SELECT 
	CASE
	WHEN KV.Value IS NOT NULL THEN KV.Value
	ELSE KA.DefaultValue
	END
	 FROM KeyAppSetting KA
	LEFT JOIN KeyValueAppSetting KV ON KV.KeyAppSetting_Id=KA.GUIDReference AND KV.Country_Id=@pCountryId
	WHERE KA.KeyName='UndoClaimGridCount' )

	IF(@Getrecords IS NULL)
	BEGIN
	SET @Getrecords=1
	END

	SELECT TOP (@Getrecords)
		Id AS Id,
		DiaryDateYear,
		DiaryDatePeriod,
		DiaryDateWeek,
		DiarySourceFull AS DiarySource,
		PanelName,
		PanelId,
		UndoClaimFlag,
		GPSUser AS GpsUser,
		GPSUpdateTimestamp AS UpdatedOn,
		CreationTimeStamp AS CreatedOn
	FROM UndoClaimData
	WHERE ISNULL(UndoClaimFlag,0)=0 AND PanelId = @pPanelId ORDER BY CreationTimeStamp DESC
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