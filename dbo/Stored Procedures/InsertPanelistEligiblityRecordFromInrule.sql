/*##########################################################################    

-- Name    : InsertPanelistEligiblityRecordFromInrule.sql    

-- Date             : 2014-11-27

-- Author           : Kattamuri Sunil Kumar    

-- Company          : Cognizant Technology Solution    

-- Purpose          : Inserts data to Diary Entry Screen

-- Usage   : From the Inrule 

-- Impact   : Change on this procedure SaveDiaryEntry Rule gets impacted.    

-- Required grants  :     

-- Called by        : Inrule      

-- Params Defintion :    

   @pBusinessId VARCHAR(10) -- We have to send businessid from inrule

	,@pCalendarId UNIQUEIDENTIFIER -- calendarid has to send from inrule

	,@pPeriodId UNIQUEIDENTIFIER -- periodid has to send from inrule

	,@pPanelCode int -- panelcode has to send from inrule

	,@pIsEligible BIT -- iseligibile has to send from inrule

	,@pEligibilityFailureReason VARCHAR(100) -- eiligbilityfailurereason has to send

	,@pCountryCode VARCHAR(10) -- country code has to send from inrule

	,@pUser VARCHAR(40) -- logged in user id has to send from inrule.

  

-- Sample Execution :

set statistics time on   

 EXEC	[dbo].[InsertPanelistEligiblityRecordFromInrule]

		@pBusinessId = N'5006344-01',

		@pCalendarId = 'A331A0C7-236D-4900-872D-991C9CE36189',

		@pPeriodId = '7889A403-804B-4FEB-A9FC-4DAFDF818553',

		@pPanelCode = 4,

		@pIsEligible = 1,

		@pEligibilityFailureReason = N'InRule',

		@pCountryCode = N'TW',

		@pUser = N'InRule'  

	set statistics time off  

##########################################################################    

-- ver  user			date        change     

-- 1.0  Kattamuri     2014-11-26   initial    

##########################################################################*/

GO
CREATE PROCEDURE [dbo].[InsertPanelistEligiblityRecordFromInrule] (
	@pBusinessId VARCHAR(10)
	,@pCalendarId UNIQUEIDENTIFIER
	,@pPeriodId UNIQUEIDENTIFIER
	,@pPanelCode INT
	,@pIsEligible BIT
	,@pEligibilityFailureReason VARCHAR(100)
	,@pCountryCode VARCHAR(10)
	,@pUser VARCHAR(40)
	)
AS
BEGIN
	BEGIN TRY
		DECLARE @paneltype VARCHAR(10)
		DECLARE @panelid UNIQUEIDENTIFIER
		DECLARE @panelist UNIQUEIDENTIFIER
		DECLARE @eligibilityfailurereasonid UNIQUEIDENTIFIER
		DECLARE @countryId UNIQUEIDENTIFIER
		DECLARE @PanelistNotFoundError VARCHAR(400) = 'Panelist Not Found for Panel: ' + convert(VARCHAR(10), @pPanelCode) + ' for Business Id: ' + convert(VARCHAR(10), @pBusinessId)
		DECLARE @PaneliElibilityRecordExist VARCHAR(400) = 'PanelistEligbility record already exist for CalendarId: ' + convert(VARCHAR(80), @pCalendarId) + ' Period : ' + convert(VARCHAR(80), @pPeriodId) + ' Business Id : ' + convert(VARCHAR(30), @pBusinessId) + ' Panel Code : ' + Convert(VARCHAR(30), @pPanelCode)
		DECLARE @GetDate DATETIME

		SET @GetDate = (
				SELECT dbo.GetLocalDateTime(GETDATE(), @pCountryCode)
				)
		SET @countryId = (
				SELECT TOP 1 countryid
				FROM Country
				WHERE CountryISO2A = @pCountryCode
				)
		SET @paneltype = (
				SELECT TOP 1 p.[Type]
				FROM Panel p
				WHERE p.Country_Id = @countryId
					AND p.PanelCode = @pPanelCode
				)
		SET @panelid = (
				SELECT TOP 1 p.GUIDReference
				FROM Panel p
				WHERE p.Country_Id = @countryId
					AND p.PanelCode = @pPanelCode
				)

		BEGIN TRY
			IF (@paneltype = 'HouseHold')
			BEGIN
				SET @panelist = (
						SELECT TOP 1 pl.GUIDReference
						FROM Panelist pl
						INNER JOIN CollectiveMembership cm ON cm.Group_Id = pl.PanelMember_Id
						INNER JOIN panel p ON p.GUIDReference = pl.Panel_Id
						INNER JOIN Individual i ON i.GUIDReference = cm.Individual_Id
						INNER JOIN Country C ON c.CountryId = pl.Country_id
						WHERE i.IndividualId = @pBusinessId
							AND p.PanelCode = @pPanelCode
							AND c.CountryISO2A = @pCountryCode
						)
			END
			ELSE
				SET @panelist = (
						SELECT TOP 1 pl.GUIDReference
						FROM Panelist pl
						INNER JOIN panel p ON p.GUIDReference = pl.Panel_Id
						INNER JOIN Individual i ON i.GUIDReference = pl.PanelMember_Id
						INNER JOIN Country C ON c.CountryId = pl.Country_id
						WHERE i.IndividualId = @pBusinessId
							AND p.PanelCode = @pPanelCode
							AND c.CountryISO2A = @pCountryCode
						)

			IF (
					@panelist IS NULL
					OR LTRIM(RTRIM(LEN(@panelist))) <= 0
					)
			BEGIN
				RAISERROR (
						@PanelistNotFoundError
						,16
						,1
						);
			END

			IF EXISTS (
					SELECT 1
					FROM EligibilityFailureReason e
					INNER JOIN country c ON c.CountryId = e.Country_Id
					WHERE c.CountryISO2A = @pCountryCode
						AND e.Description = @pEligibilityFailureReason
					)
			BEGIN
				SET @eligibilityfailurereasonid = (
						SELECT TOP 1 e.EligibilityFailureReasonId
						FROM EligibilityFailureReason e
						INNER JOIN country c ON c.CountryId = e.Country_Id
						WHERE c.CountryISO2A = @pCountryCode
							AND e.Description = @pEligibilityFailureReason
						)
			END
			ELSE
				INSERT INTO [dbo].[EligibilityFailureReason] (
					[EligibilityFailureReasonId]
					,[Description]
					,[Country_Id]
					,[GPSUser]
					,[GPSUpdateTimestamp]
					,[CreationTimeStamp]
					)
				VALUES (
					newid()
					,@pEligibilityFailureReason
					,@countryId
					,USER
					,@GetDate
					,@GetDate
					)

			SET @eligibilityfailurereasonid = (
					SELECT TOP 1 EligibilityFailureReasonId
					FROM EligibilityFailureReason E
					INNER JOIN country c ON c.CountryId = e.Country_Id
					WHERE c.CountryISO2A = @pCountryCode
						AND Description = @pEligibilityFailureReason
					)

			DECLARE @insertedDate DATETIME = @GetDate

			IF EXISTS (
					SELECT 1
					FROM PanelistEligibility
					WHERE CalendarPeriod_PeriodId = @pPeriodId
						AND CalendarPeriod_CalendarId = @pCalendarId
						AND Panel_Id = @panelid
						AND PanelistId = @panelist
					)
			BEGIN
				UPDATE PanelistEligibility
				SET IsEligible = @pIsEligible
					,EligibilityFailureReasonId = @eligibilityfailurereasonid
					,[GPSUser] = @pUser
					,GPSUpdateTimestamp = @insertedDate
				WHERE CalendarPeriod_PeriodId = @pPeriodId
					AND CalendarPeriod_CalendarId = @pCalendarId
					AND Panel_Id = @panelid
					AND PanelistId = @panelist
			END
			ELSE
			BEGIN
				INSERT INTO [dbo].[PanelistEligibility] (
					[GUIDReference]
					,[PanelistId]
					,[Panel_Id]
					,[EligibilityFailureReasonId]
					,[IsEligible]
					,[CalendarPeriod_CalendarId]
					,[CalendarPeriod_PeriodId]
					,[Country_Id]
					,[GPSUser]
					,[GPSUpdateTimestamp]
					,[CreationTimeStamp]
					)
				VALUES (
					newid()
					,@panelist
					,@panelid
					,@eligibilityfailurereasonid
					,@pIsEligible
					,@pCalendarId
					,@pPeriodId
					,@countryId
					,@pUser
					,@insertedDate
					,@insertedDate
					)
			END
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
		END CATCH
	END TRY

	BEGIN CATCH
		DECLARE @ErrorMessage1 NVARCHAR(4000);
		DECLARE @ErrorSeverity1 INT;
		DECLARE @ErrorState1 INT;

		SELECT @ErrorMessage1 = ERROR_MESSAGE()
			,@ErrorSeverity1 = ERROR_SEVERITY()
			,@ErrorState1 = ERROR_STATE();

		RAISERROR (
				@ErrorMessage1
				,-- Message text.
				@ErrorSeverity1
				,-- Severity.
				@ErrorState1 -- State.
				);
	END CATCH
END
GO