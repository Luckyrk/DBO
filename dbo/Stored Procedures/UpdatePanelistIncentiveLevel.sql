/**************************************************************
Created By	:	Satish
Created On	:	6-Oct-2015
Reason		:	[PBI-35669] -Change Incentive Levels through business rules.


***************************************************************/

GO

CREATE PROCEDURE [dbo].[UpdatePanelistIncentiveLevel] 
	(
	@pCountryCode	VARCHAR(5),
	@pBusinessId		NVARCHAR(50),
	@pPanelCode		INT,
	@pIncentiveCode	INT
	)
AS
BEGIN
	
	SET NOCOUNT ON

	BEGIN TRY

		SET XACT_ABORT ON
		BEGIN TRANSACTION

		DECLARE @PanlistGUID		UNIQUEIDENTIFIER = NULL;
		DECLARE @IncentiveLevelID	UNIQUEIDENTIFIER = NULL;
		DECLARE @CountryID			UNIQUEIDENTIFIER = NULL;
		DECLARE @PanelMemeberID		UNIQUEIDENTIFIER = NULL;
		DECLARE @PanelID			UNIQUEIDENTIFIER = NULL;
		DECLARE @GetDate DATETIME
		SET @GetDate = (select dbo.GetLocalDateTime(GETDATE(),@pCountryCode))

		SELECT TOP 1 @CountryID =  CountryId FROM Country WHERE CountryISO2A = @pCountryCode	
		IF @CountryID IS NOT NULL 	
		BEGIN
		
			SELECT TOP 1 @PanelID = GUIDReference FROM PANEL WHERE PanelCode = @pPanelCode AND Country_Id = @CountryID
			IF @PanelID IS NOT NULL 	
			BEGIN
			
				SELECT @PanelMemeberID = t.panelistId  FROM 
									(SELECT PL.PanelMember_Id AS panelistId, P.PanelCode AS PanelCode FROM Individual Ind
										INNER JOIN CollectiveMembership CM ON
											Ind.GUIDReference = cm.Individual_Id
										INNER JOIN Panelist PL ON
											PL.PanelMember_Id = Ind.GUIDReference
										INNER JOIN Panel P ON
											P.GUIDReference = PL.Panel_Id
										WHERE Ind.IndividualId = @pBusinessId
											AND P.PanelCode = @pPanelCode
											AND P.Country_Id = @CountryID
								
										UNION ALL

										SELECT PL.PanelMember_Id panelistId, P.PanelCode FROM Individual Ind
										INNER JOIN CollectiveMembership CM ON
											Ind.GUIDReference = cm.Individual_Id
										INNER JOIN Panelist PL ON
											PL.PanelMember_Id = CM.Group_Id
										INNER JOIN Panel P ON
											P.GUIDReference = PL.Panel_Id
										WHERE Ind.IndividualId = @pBusinessId
											AND P.PanelCode = @pPanelCode
											AND P.Country_Id = @CountryID
										) t
				IF @PanelMemeberID IS NOT NULL
				BEGIN		
			
					SELECT TOP 1 @PanlistGUID = GUIDReference FROM Panelist WHERE PanelMember_Id = @PanelMemeberID AND Country_Id = @CountryID AND Panel_Id = @PanelID
					IF @PanlistGUID IS NOT NULL 
					BEGIN

						SELECT TOP 1 @IncentiveLevelID = GUIDReference FROM incentivelevel WHERE Code = @pIncentiveCode AND Country_Id = @CountryID AND Panel_Id = @PanelID
						IF @IncentiveLevelID IS NOT NULL 
						BEGIN
							UPDATE Panelist SET IncentiveLevel_Id = @IncentiveLevelID
							,GPSUpdateTimestamp=@GetDate
							 WHERE GUIDReference = @PanlistGUID	
						END
						ELSE
						BEGIN
							DECLARE @IncentiveLevelError VARCHAR(MAX) = 'Incentive level not found for Code : ' + @pIncentiveCode + ' With Panel Id ' + CONVERT(VARCHAR(50), @PanelID)
							RAISERROR (@IncentiveLevelError, 16, 1);							
						END

					END
					ELSE
					BEGIN
						DECLARE @PanlistError VARCHAR(MAX) = 'Panelist not found for PanelMember : ' + CONVERT(VARCHAR(50), @PanelMemeberID) + ' With Panel Id ' + CONVERT(VARCHAR(50), @PanelID)
						RAISERROR (@PanlistError, 16, 1);						
					END

				END
				ELSE
				BEGIN
					DECLARE @pBusinessIdError VARCHAR(MAX) = 'Business Id is not found for Business Id  : ' + CONVERT(VARCHAR(50), @pBusinessId) + ' With Panel Id ' + CONVERT(VARCHAR(50), @PanelID)
					RAISERROR (@pBusinessIdError, 16, 1);						
				END

			END
			ELSE
			BEGIN
				DECLARE @PanelError VARCHAR(MAX) = 'Panel is not found for Country Id  : ' + CONVERT(VARCHAR(50), @CountryID) + ' With Panel Code ' + CONVERT(VARCHAR(50), @pPanelCode)
				RAISERROR (@PanelError, 16, 1);				
			END
		
		END	
		ELSE
		BEGIN
			DECLARE @CountryError VARCHAR(MAX) = 'Country is not found for Country Code  : ' + CONVERT(VARCHAR(50), @pCountryCode);
			RAISERROR (@CountryError, 16, 1);			
		END

		COMMIT TRANSACTION
		SET XACT_ABORT OFF

	END TRY
	BEGIN CATCH

		DECLARE @ErrorNumber INT = ERROR_NUMBER();
		DECLARE @ErrorLine INT = ERROR_LINE();
		DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
		DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
		DECLARE @ErrorState INT = ERROR_STATE();
		RAISERROR (
				@ErrorMessage
				,@ErrorSeverity
				,@ErrorState
				);
		ROLLBACK TRANSACTION
	END CATCH
END

Go