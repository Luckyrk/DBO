/*##########################################################################
-- Name				: UpdateAssetDetails
-- Date             : 2015-09-07
-- Author           : 
-- Purpose          : 
-- Usage            : 
-- Impact           : 
-- Required grants  : 
-- Called by        : 
-- PARAM Definitions
     @pSerialNumber		--	Serial Number from StockItem
	 @pAssetTypeCode	--	Code from StockType
	 @pStateCode		--	Code from StateDefinition
	 @pBusinessId		--	IndividualId from Individual
	 @pCountryCode		--	CountryISO2A from Country
	 @pPanelcode		--	PanelCode from Panel
	 @pGPSUser			--	GPSUser
	 @pLocation			--	Location from GenericStockLocation

-- Sample Execution :
--EXEC	[dbo].[UpdateAssetDetails]
--		@pSerialNumber = N'OK0000000000034789',
--		@pAssetTypeCode = 17,
--		@pStateCode = N'AssetDelivered',
--		@pBusinessId = '772721-00',
--		@pCountryCode = 'GB',
--		@pPanelcode = 27,
--		@pGPSUser = N'KT\DasariJ'
--		@pLocation = N'BUILDING'

##########################################################################
-- version  user						date        change 
-- 1.0  Jagadesh Dasari				  2015-09-07	Initial
##########################################################################*/

CREATE PROCEDURE [dbo].[UpdateAssetDetails] (
	@pSerialNumber NVARCHAR(80) 
	,@pAssetTypeCode INT 
	,@pStateCode NVARCHAR(80) 
	,@pBusinessId NVARCHAR(80)  
	,@pCountryCode NVARCHAR(80) 
	,@pPanelcode INT 
	,@pGPSUser NVARCHAR(100)
	,@pLocation NVARCHAR(100)
	)
AS
BEGIN
	SET NOCOUNT ON

		BEGIN TRY

			SET XACT_ABORT ON
			BEGIN TRANSACTION

			DECLARE @countryId UNIQUEIDENTIFIER = (SELECT TOP 1 CountryId FROM Country WHERE CountryISO2A = @pCountryCode)
			DECLARE @individualId UNIQUEIDENTIFIER = (SELECT TOP 1 GUIDReference FROM Individual WHERE IndividualId = @pBusinessId AND CountryId = @countryId)
			DECLARE @stateDefinitionHistoryId UNIQUEIDENTIFIER = NEWID() 
			DECLARE @stockItemTypeId UNIQUEIDENTIFIER = (SELECT GUIDReference FROM StockType WHERE Code = @pAssetTypeCode AND CountryId = @countryId)
			DECLARE @stockItemId UNIQUEIDENTIFIER 
			DECLARE @locationId UNIQUEIDENTIFIER 			
			DECLARE @toId  UNIQUEIDENTIFIER = (SELECT TOP 1 Id FROM StateDefinition WHERE Code = @pStateCode and Country_Id = @countryId)
			DECLARE @panelistId UNIQUEIDENTIFIER 
			DECLARE @getDate DATETIME 
			SET @getDate = (select dbo.GetLocalDateTime(GETDATE(),@pCountryCode))
			DECLARE @searchWord NVARCHAR(10) = 'panelist'


			SELECT @StockItemId = GUIDReference FROM stockitem WHERE SerialNumber = @pSerialNumber AND [Type_Id] = @stockItemTypeId
			DECLARE @fromId UNIQUEIDENTIFIER = (SELECT State_Id FROM StockItem WHERE GUIDReference = @StockItemId)

			SET @panelistId = (SELECT TOP 1 t.panelistId FROM (SELECT PL.GUIDReference AS panelistId FROM Individual Ind
								INNER JOIN CollectiveMembership CM ON
									Ind.GUIDReference = cm.Individual_Id
								INNER JOIN Panelist PL ON
									PL.PanelMember_Id = Ind.GUIDReference
								INNER JOIN Panel P ON
									P.GUIDReference = PL.Panel_Id
								WHERE Ind.IndividualId = @pBusinessId
									AND P.PanelCode = @pPanelcode
									AND P.Country_Id = @countryId
								
								UNION ALL
								SELECT PL.GUIDReference panelistId FROM Individual Ind
								INNER JOIN CollectiveMembership CM ON
									Ind.GUIDReference = cm.Individual_Id
								INNER JOIN Panelist PL ON
									PL.PanelMember_Id = CM.Group_Id
								INNER JOIN Panel P ON
									P.GUIDReference = PL.Panel_Id
								WHERE Ind.IndividualId = @pBusinessId
									AND P.PanelCode = @pPanelcode
									AND P.Country_Id = @countryId
								) t)

			IF EXISTS (SELECT 1 FROM StockItem WHERE SerialNumber = @pSerialNumber AND [Type_Id] = @stockItemTypeId)
				BEGIN
					IF EXISTS(SELECT 1 FROM StateTransition WHERE FromState_Id = @fromId AND ToState_Id = @toId)					
						BEGIN
							INSERT INTO StateDefinitionHistory 
								(GUIDReference, GPSUser, CreationDate, GPSUpdateTimestamp, CreationTimeStamp, Comments, CollaborateInFuture, 
									From_Id, To_Id, ReasonForchangeState_Id, Country_Id, Candidate_Id, GroupMembership_Id, Belonging_Id, 
									Panelist_Id, Order_Id, Order_Country_Id, Package_Id, ImportFile_Id, ImportFilePendingRecord_Id, Action_Id)
							VALUES 
								(@stateDefinitionHistoryId, @pGPSUser, @getDate, @getDate, @getDate, NULL, 0, @fromId, @toId, NULL, 
									@countryId, NULL, NULL, NULL, @panelistId, NULL, NULL, NULL, NULL, NULL, NULL)
					
							IF CHARINDEX(@searchWord,@pLocation) > 0
								BEGIN 
									SELECT TOP 1 @locationId = GUIDReference FROM StockPanelistLocation WHERE Panelist_Id = @panelistId									
								END
							ELSE
								BEGIN
									SELECT TOP 1 @locationId = gsl.GUIDReference FROM GenericStockLocation gsl
									JOIN StockLocation sl ON sl.GUIDReference=gsl.GUIDReference
									JOIN Country  c ON c.CountryId=sl.Country_Id
									 WHERE gsl.Location = @pLocation AND c.CountryId=@countryId
								END
								
							IF (@locationId IS NOT NULL)
								BEGIN
									IF EXISTS(SELECT 1 FROM StockItem SI INNER JOIN StockType ST 
												ON SI.[Type_Id] = ST.GUIDReference 
												WHERE SI.SerialNumber = @pSerialNumber)
																		
										BEGIN											
											IF NOT EXISTS(SELECT 1 FROM StockLocation WHERE GUIDReference = @locationId)
												BEGIN
													INSERT INTO StockLocation 
															(GUIDReference, GPSUser, GPSUpdateTimestamp, CreationTimeStamp, Country_Id) 
														VALUES
															(@locationId, @pGPSUser,  @getDate,  @getDate, @countryId)
												END
											INSERT INTO StockStateDefinitionHistory (GUIDReference,	Location_Id, StockItem_Id,GPSUser,GPSUpdateTimestamp,CreationTimeStamp) 
												VALUES (@stateDefinitionHistoryId, @locationId, @stockItemId,@pGPSUser,@getDate,@getDate)

											UPDATE StockItem set [State_Id] = @toId, [Location_Id] = @locationId
												,GPSUpdateTimestamp=@getDate,GPSUser=@pGPSUser
												WHERE GUIDReference = @StockItemId 
										END
									ELSE
										BEGIN
											DECLARE @assignmentError VARCHAR(MAX) = 'Asset with Serial Number : ' + @pSerialNumber + ' is not available for the Panel Code ' + CONVERT(VARCHAR(10), @pPanelCode)
									 		RAISERROR (@assignmentError, 16, 1);
										END
								END
							ELSE
								BEGIN
									SELECT @locationId = NEWID()

									INSERT INTO StockLocation 
										(GUIDReference, GPSUser, GPSUpdateTimestamp, CreationTimeStamp, Country_Id) 
									VALUES
										(@locationId, @pGPSUser,  @getDate,  @getDate, @countryId)
									INSERT INTO StockPanelistLocation (GUIDReference, Panelist_Id,GPSUser,GPSUpdateTimestamp,CreationTimeStamp) VALUES (@locationId, @panelistId,@pGPSUser,@getDate,@getDate)

									

									INSERT INTO StockStateDefinitionHistory (GUIDReference,	Location_Id, StockItem_Id,GPSUser,GPSUpdateTimestamp,CreationTimeStamp) 
											VALUES (@stateDefinitionHistoryId, @locationId, @stockItemId,@pGPSUser,@getDate,@getDate)

									UPDATE StockItem set [State_Id] = @toId, [Location_Id] = @locationId
											,GPSUpdateTimestamp=@getDate,GPSUser=@pGPSUser
												WHERE GUIDReference = @StockItemId 
								END
						END

						If(@panelistId is not null)
						       update StockItem set Panelist_Id=@panelistId  ,GPSUpdateTimestamp=@getDate,GPSUser=@pGPSUser
							   WHERE SerialNumber = @pSerialNumber AND [Type_Id] = @stockItemTypeId
					ELSE
						BEGIN
							DECLARE @stateChangeError VARCHAR(MAX) = 'Asset can not be changed to ' + @pStateCode + ' for Indivdiual : ' + @pBusinessId + ' With Panel Code ' + CONVERT(VARCHAR(10), @pPanelCode)
							RAISERROR (@stateChangeError, 16, 1);
						END
				END
			ELSE
				BEGIN
					DECLARE @stockError VARCHAR(MAX) = 'No Asset found with the serial number: ' + @pSerialNumber + ' for Indivdiual : ' + @pBusinessId + ' With Panel Code ' + CONVERT(VARCHAR(10), @pPanelCode)
					RAISERROR (@stockError, 16, 1);
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