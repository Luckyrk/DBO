CREATE PROCEDURE [dbo].[UpdateCommunicationEventReasonTypeActionTaskType] (
 @pRelatedReson INT,
	@pResonCode INT
	,@pcommunicationEventActionTypeId UNIQUEIDENTIFIER = NULL
	)
AS
BEGIN
BEGIN TRY
	DECLARE @pOldResonTypeId UNIQUEIDENTIFIER
	DECLARE @pNewResonTypeId UNIQUEIDENTIFIER
	DECLARE @pOldCommunicationEventActionTypeReasonId UNIQUEIDENTIFIER

	SET @pOldCommunicationEventActionTypeReasonId = (
			SELECT TOP 1 GUIDReference
			FROM CommunicationEventReasonType
			WHERE RelatedActionType_Id = @pcommunicationEventActionTypeId
			)
	SET @pOldResonTypeId = (
			SELECT TOP 1 CER.GUIDReference AS ReasonTypeId
			FROM CommunicationEventReasonType CER
			INNER JOIN CommunicationEventReasonTypeActionTaskType CERAT ON CER.GUIDReference = CERAT.CommunicationEventReasonType_Id
			INNER JOIN ActionTaskType AT ON CERAT.ActionTaskType_Id = AT.GUIDReference
			WHERE CERAT.ActionTaskType_Id = @pcommunicationEventActionTypeId
			)
	SET @pNewResonTypeId = (
			SELECT TOP 1 GUIDReference
			FROM CommunicationEventReasonType
			WHERE CommEventReasonCode = @pResonCode
			)

	IF @pcommunicationEventActionTypeId IS NOT NULL AND @pRelatedReson =0
	BEGIN
		IF EXISTS (
				SELECT 1
				FROM CommunicationEventReasonTypeActionTaskType
				WHERE ActionTaskType_Id = @pcommunicationEventActionTypeId
					AND CommunicationEventReasonType_Id = @pOldResonTypeId
				)
		BEGIN
			DELETE
			FROM CommunicationEventReasonTypeActionTaskType
			WHERE CommunicationEventReasonType_Id = @pOldResonTypeId
				AND ActionTaskType_Id = @pcommunicationEventActionTypeId
		END
	END

	IF  @pRelatedReson =1
	BEGIN
	IF @pOldResonTypeId IS NOT NULL
		AND @pNewResonTypeId IS NOT NULL
	BEGIN
		IF EXISTS (
				SELECT 1
				FROM CommunicationEventReasonTypeActionTaskType
				WHERE ActionTaskType_Id = @pcommunicationEventActionTypeId
					AND CommunicationEventReasonType_Id = @pOldResonTypeId
				)
		BEGIN
			DELETE
			FROM CommunicationEventReasonTypeActionTaskType
			WHERE CommunicationEventReasonType_Id = @pOldResonTypeId
				AND ActionTaskType_Id = @pcommunicationEventActionTypeId
		END
	END

	IF @pNewResonTypeId IS NOT NULL
	BEGIN
		IF NOT EXISTS (
				SELECT 1
				FROM CommunicationEventReasonTypeActionTaskType
				WHERE ActionTaskType_Id = @pcommunicationEventActionTypeId
					AND CommunicationEventReasonType_Id = @pNewResonTypeId
				)
		BEGIN
			INSERT INTO CommunicationEventReasonTypeActionTaskType (
				CommunicationEventReasonType_Id
				,ActionTaskType_Id
				,GPSUser
				,GPSUpdateTimestamp
				,CreationTimeStamp
				)
			VALUES (
				@pNewResonTypeId
				,@pcommunicationEventActionTypeId
				,'AdminUser'
				,GETDATE()
				,GETDATE()
				)
		END

		UPDATE CommunicationEventReasonType
		SET RelatedActionType_Id = NULL
		WHERE GUIDReference = @pOldCommunicationEventActionTypeReasonId

		UPDATE CommunicationEventReasonType
		SET RelatedActionType_Id = @pcommunicationEventActionTypeId
		WHERE GUIDReference = @pNewResonTypeId
	END
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

