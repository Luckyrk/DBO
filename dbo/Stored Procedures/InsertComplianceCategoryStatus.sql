/*##########################################################################
-- Name				: InsertComplianceCategoryStatus
-- Date             : 2015-09-15
-- Author           : 
-- Purpose          : 
-- Usage            : 
-- Impact           : 
-- Required grants  : 
-- Called by        : 
-- PARAM Definitions
     @pCategoryName		--	CategoryName from ComplianceCategory 
	 @pSignalColor		--	SignalColor from ComplianceCategoryStatus
	 @pBusinessId		--	IndividualId from Individual
	 @pCountryCode		--	CountryISO2A from Country
	 @pPanelcode		--	PanelCode from Panel
	 @pGpsUser			--	GPSUser

-- Sample Execution :

--EXEC	[dbo].[InsertComplianceCategoryStatus]
--		@pCategoryName = N'Packs',
--		@pSignalColor = N'YellowTrafficLight',
--		@pBusinessId = '000002-00',
--		@pCountryCode = 'GB',
--		@pPanelcode = 27,
--		@pGpsUser = N'KT\DasariJ'

##########################################################################
-- version  user						date        change 
-- 1.0  Jagadesh Dasari				  2015-09-15	Initial
##########################################################################*/

CREATE PROCEDURE [dbo].[InsertComplianceCategoryStatus] (
	@pCategoryName	NVARCHAR(100) 
	,@pSignalColor	NVARCHAR(100) 
	,@pBusinessId	NVARCHAR(50)
	,@pCountryCode	NVARCHAR(80) 
	,@pPanelcode	INT  
	,@pGpsUser		NVARCHAR(100)
	)
AS
BEGIN
	SET NOCOUNT ON

		BEGIN TRY

			SET XACT_ABORT ON
			BEGIN TRANSACTION

			DECLARE @getDate DATETIME 
			SET @getDate = (select dbo.GetLocalDateTime(GETDATE(),@pCountryCode))
			DECLARE @complianceCategoryStatusId UNIQUEIDENTIFIER
			DECLARE @panelistId UNIQUEIDENTIFIER
			DECLARE @countryId UNIQUEIDENTIFIER = (SELECT TOP 1 CountryId FROM Country WHERE CountryISO2A = @pCountryCode)


			SET @panelistId = (SELECT TOP 1 t.PanelistId FROM (SELECT PL.GUIDReference AS PanelistId FROM Individual Ind
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
								SELECT PL.GUIDReference AS PanelistId FROM Individual Ind
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


			IF (@panelistId IS NOT NULL)

				BEGIN
					DECLARE @complianceCategoryId UNIQUEIDENTIFIER = 
						(SELECT TOP 1 GUIDReference FROM ComplianceCategory CC JOIN Translation T 
							ON CC.Translation_Id = T.TranslationId WHERE CC.KeyName = @pCategoryName AND CC.Country_Id = @countryId)
					
					IF (@complianceCategoryId IS NOT NULL)
						BEGIN
							set @complianceCategoryStatusId = 
									(SELECT TOP 1 GUIDReference FROM ComplianceCategoryStatus WHERE ComplianceCategory_Id = @complianceCategoryId AND Panelist_Id = @panelistId)
							
							IF (@complianceCategoryStatusId IS NOT NULL)
								BEGIN
									UPDATE ComplianceCategoryStatus SET SignalColor = @pSignalColor, GPSUpdateTimestamp = @getDate WHERE GUIDReference = @complianceCategoryStatusId
								END
							ELSE
								BEGIN
									SET @complianceCategoryStatusId = NEWID()

									INSERT INTO ComplianceCategoryStatus 
										(GUIDReference, ComplianceCategory_Id, Panelist_Id, SignalColor, GPSUser, CreationTimeStamp, GPSUpdateTimestamp) 
									VALUES 
										(@complianceCategoryStatusId, @complianceCategoryId, @panelistId,  @pSignalColor, @pGpsUser, @getDate, @getDate)		
								END

							
						END
					ELSE
						BEGIN
							DECLARE @assignmentError VARCHAR(MAX) = 'Category : ' + @pCategoryName + ' is not available for the Country ' + CONVERT(VARCHAR(10), @pCountryCode)
							RAISERROR (@assignmentError, 16, 1);
						END
				END
			ELSE
				BEGIN
					DECLARE @PanelistError VARCHAR(MAX) = 'Panelist Not Found for Indivdiual : ' + @pBusinessId + ' With Panel Code ' + CONVERT(VARCHAR(10), @pPanelCode)
					RAISERROR (@PanelistError, 16, 1);
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