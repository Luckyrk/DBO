/*##########################################################################    
-- Name    : InsertDiaryEntryRecordFromInrule.sql    
-- Date             : 2014-11-26
-- Author           : Kattamuri Sunil Kumar    
-- Company          : Cognizant Technology Solution    
-- Purpose          : Inserts data to Diary Entry Screen
-- Usage   : From the Inrule 
-- Impact   : Change on this procedure SaveDiaryEntry Rule gets impacted.    
-- Required grants  :     
-- Called by        : Inrule      
-- Params Defintion :    
   @pBusinessId NVARCHAR(50) -- Business Id has to send from inrule (000001-00..)
	,@pPanelCode INT -- panel code has to send from inrule (2,3,4.. panelcode from panel table)
	,@pCountryCode VARCHAR(10) -- CountryCode has to send ('ES','TW'.. from Country Table)
	,@pDiaryDateYear INT -- Year has to send(2014,2015..)
	,@pDiaryDatePeriod INT -- Period value has to send (5,6..)
	,@pDiaryDateWeek INT -- Week value has to send (1,2,3,4..)
	,@pNumberOfDaysLate INT -- number of days late value has to send (0,1.)
	,@pNumberOfDaysEarly INT-- Number of Days Early value has to send (0,1..)
	,@pReceivedDate DATETIME -- Date of recieved diary
	,@pPoints INT -- number of points assigned for scanning dairy
	,@pDiarySource NVARCHAR(150) -- Diary Source paper,Online
	,@pTogether INT -- Together has to send from inrule
	,@pIncentiveCode INT -- incentive code has to send from inrule
	,@pClaimFlag INT -- Claim flag has to send from inrule
	,@pConsecutiveEntriesReceived INT -- consecutiveDiaries received
	,@pGPSUser VARCHAR(100) -- GPSuser has to send from Inrule
	,@pCultureCode INT -- Culture Code has to send from Inrule
  
-- Sample Execution :
set statistics time on   
 EXEC	[dbo].[InsertDiaryEntryRecordFromInrule]
		@pBusinessId = N'3000844-01',
		@pPanelCode = 4,
		@pCountryCode = N'TW',
		@pDiaryDateYear = 2014,
		@pDiaryDatePeriod = 11,
		@pDiaryDateWeek = 4,
		@pNumberOfDaysLate = 0,
		@pNumberOfDaysEarly = 0,
		@pReceivedDate = N'2014-11-26',
		@pPoints = 100,
		@pDiarySource = N'Paper',
		@pTogether = 0,
		@pIncentiveCode = 4,
		@pClaimFlag = 0,
		@pConsecutiveEntriesReceived = NULL,
		@pGPSUser = N'InRule',
		@pCultureCode = 1028   
	set statistics time off  
##########################################################################    
-- ver  user			date        change     
-- 1.0  Kattamuri     2014-11-26   initial    
##########################################################################*/
CREATE PROCEDURE [dbo].[InsertDiaryEntryRecordFromInrule] (
	@pBusinessId NVARCHAR(50)
	,@pPanelCode INT
	,@pCountryCode VARCHAR(10)
	,@pDiaryDateYear INT
	,@pDiaryDatePeriod INT
	,@pDiaryDateWeek INT
	,@pNumberOfDaysLate INT
	,@pNumberOfDaysEarly INT
	,@pReceivedDate NVARCHAR(40)
	,@pPoints INT
	,@pDiarySource NVARCHAR(150)
	,@pTogether INT
	,@pIncentiveCode INT
	,@pClaimFlag INT
	,@pConsecutiveEntriesReceived INT
	,@pGPSUser VARCHAR(100)
	,@pCultureCode INT
	)
AS
BEGIN
BEGIN TRY

DECLARE @GetDate DATETIME
		SET @GetDate = (select dbo.GetLocalDateTime(getdate(),@pCountryCode))
	DECLARE @GPSUpdateTimestamp DATETIME
		,@DiaryState NVARCHAR(200)
		,@PanelType VARCHAR(200)
		,@PanelId UNIQUEIDENTIFIER

	SET @GPSUpdateTimestamp = @GetDate

	DECLARE @invalidpanelcode NVARCHAR(200) = 'Invalid Panel.Panel doesnt exist for the Country ' + convert(VARCHAR(10), @pCountryCode) + 'for panel code: ' + convert(VARCHAR(10), @pPanelCode);
	DECLARE @PanelistNotFound NVARCHAR(500) = 'Panelist not found for the Business Id:' + @pBusinessId + ' for Panel Code :' + convert(VARCHAR(10), @pPanelCode);
	DECLARE @InvalidCountry NVARCHAR(200) = 'Invalid Country.Country is Null or Empty Country Provided : ' + convert(VARCHAR(10), @pCountryCode);
	DECLARE @InvalidPoints NVARCHAR(200) = 'Invalid Points.Points cannot be null,Empty or less than 0 Points Provided: ' + convert(VARCHAR(10), @pPoints);
	DECLARE @InvalidDiaryDateYear NVARCHAR(200) = 'Invalid DiaryDateYear.DiaryDateYear cannot be null,Empty or less than 0 DiaryDateYear Provided: ' + convert(VARCHAR(10), @pDiaryDateYear);
	DECLARE @InvalidDiaryDatePeriod NVARCHAR(200) = 'Invalid DiaryDatePeriod.DiaryDatePeriod cannot be null,Empty or less than 0 DiaryDatePeriod Provided: ' + convert(VARCHAR(10), @pDiaryDatePeriod);
	DECLARE @InvalidDiaryDateWeek NVARCHAR(200) = 'Invalid DiaryDateWeek.DiaryDateWeek cannot be null,Empty or less than 0 DiaryDateWeek Provided: ' + convert(VARCHAR(10), @pDiaryDateWeek);
	DECLARE @InvalidNumberOfDaysLate NVARCHAR(200) = 'Invalid Number of Days Late.NumberofDaysLate cannot be null,Empty or less than 0 NumberodDaysLate Provided:' + convert(VARCHAR(10), @pNumberOfDaysLate)
	DECLARE @InvalidNumberOfDaysEarly NVARCHAR(200) = 'Invalid NumberOfDaysEarly.Number of Days Early cannot be null,Empty or less than 0 NumberOfDaysEarly Provided:' + convert(VARCHAR(10), @pNumberOfDaysEarly);
	DECLARE @InvalidReceivedDate NVARCHAR(200) = 'Invalid ReceivedDate.Recieved Date is not in correct date fromat. Received Date Entered:' + convert(VARCHAR(10), @pReceivedDate) + ' it has to be in YYYY-MM-DD format';
	DECLARE @InvalidBusinessId NVARCHAR(200) = 'Invalid BusinessId.Business Id cannot be null or empty BusinessId Provided:' + convert(VARCHAR(10), @pBusinessId);
	DECLARE @InvalidIncentiveCode NVARCHAR(200) = 'Invalid Incentive Code.IncentiveCode Cannot be null,Empty or less than 0 IncentiveCode Provided:' + convert(VARCHAR(10), @pIncentiveCode)
	DECLARE @InvalidClaimFlag NVARCHAR(200) = 'Invalid Claim Flag.Claim Flage cannot be null,Empty or less than 0 ClaimFlag Provided:' + convert(VARCHAR(10), @pClaimFlag)
	DECLARE @InvalidTogetherValue NVARCHAR(200) = 'Invalid Together Value.Together Value cannot be null,empty or less than 0 Together Provided:' + convert(VARCHAR(10), @pTogether)
	DECLARE @DuplicateDiaryEntry NVARCHAR(500) = 'Dupliacte Diary Entry. Diary already exist for the Year ' + Convert(VARCHAR(10), @pDiaryDateYear) + ' Period ' + Convert(VARCHAR(10), @pDiaryDatePeriod) + ' Week ' + Convert(VARCHAR(10), @pDiaryDateWeek)

	BEGIN TRY
		IF NOT EXISTS (
				SELECT 1
				FROM Panel p
				INNER JOIN Country c ON c.CountryId = p.Country_Id
				WHERE PanelCode = @pPanelCode
					AND c.CountryISO2A = @pCountryCode
				)
		BEGIN
			RAISERROR (
					@Invalidpanelcode
					,16
					,1
					);
		END
		ELSE
			SET @PanelId = (
					SELECT TOP 1 GUIDReference
					FROM Panel P
					INNER JOIN Country C ON P.Country_Id = C.CountryId
					WHERE PanelCode = @pPanelCode
						AND C.CountryISO2A = @pCountryCode
					)

		IF EXISTS (
				SELECT 1
				FROM DiaryEntry
				WHERE DiaryDateYear = @pDiaryDateYear
					AND DiaryDatePeriod = @pDiaryDatePeriod
					AND DiaryDateWeek = @pDiaryDateWeek
					AND BusinessId = @pBusinessId
					AND PanelId = @PanelId
				)
			RAISERROR (
					@DuplicateDiaryEntry
					,16
					,1
					);

		SET @PanelType = (
				SELECT TOP 1 [Type]
				FROM Panel p
				INNER JOIN Country C ON c.CountryId = p.Country_Id
				WHERE PanelCode = @pPanelCode
					AND c.CountryISO2A = @pCountryCode
				)

		IF (@PanelType = 'HouseHold')
		BEGIN
			SET @DiaryState = (
					SELECT TOP 1 tt.Value
					FROM Panelist pl
					INNER JOIN CollectiveMembership cm ON cm.Group_Id = pl.PanelMember_Id
					INNER JOIN Panel p ON p.GUIDReference = pl.Panel_Id
					INNER JOIN Individual i ON i.GUIDReference = cm.Individual_Id
					INNER JOIN StateDefinition sd ON sd.Id = pl.State_Id
					INNER JOIN Country C ON c.CountryId = pl.Country_Id
					INNER JOIN TranslationTerm tt ON tt.Translation_Id = sd.Label_Id
						AND tt.CultureCode = @pCultureCode
					WHERE i.IndividualId = @pBusinessId
						AND p.PanelCode = @pPanelCode
						AND c.CountryISO2A = @pCountryCode
					)
		END
		ELSE
			SET @DiaryState = (
					SELECT TOP 1 tt.Value
					FROM Panelist pl
					INNER JOIN Panel p ON p.GUIDReference = pl.Panel_Id
					INNER JOIN Individual i ON i.GUIDReference = pl.PanelMember_Id
					INNER JOIN StateDefinition sd ON sd.Id = pl.State_Id
					INNER JOIN Country C ON c.CountryId = pl.Country_Id
					INNER JOIN TranslationTerm tt ON tt.Translation_Id = sd.Label_Id
						AND tt.CultureCode = @pCultureCode
					WHERE i.IndividualId = @pBusinessId
						AND p.PanelCode = @pPanelCode
						AND c.CountryISO2A = @pCountryCode
					)

		IF (
				@pCountryCode IS NULL
				OR LTRIM(RTRIM(LEN(@pCountryCode))) = 0
				)
			RAISERROR (
					@InvalidCountry
					,16
					,1
					);

		IF (
				@pPoints IS NULL
				OR LTRIM(RTRIM(LEN(@pPoints))) = 0
				OR @pPoints < 0
				)
			RAISERROR (
					@InvalidPoints
					,16
					,1
					);

		IF (
				@pDiaryDateYear IS NULL
				OR LTRIM(RTRIM(LEN(@pDiaryDateYear))) = 0
				OR @pDiaryDateYear <= 0
				)
			RAISERROR (
					@InvalidDiaryDateYear
					,16
					,1
					);

		IF (
				@pDiaryDatePeriod IS NULL
				OR LTRIM(RTRIM(LEN(@pDiaryDatePeriod))) = 0
				OR @pDiaryDatePeriod <= 0
				)
			RAISERROR (
					@InvalidDiaryDatePeriod
					,16
					,1
					);

		IF (
				@pDiaryDateWeek IS NULL
				OR LTRIM(RTRIM(LEN(@pDiaryDateWeek))) = 0
				OR @pDiaryDateWeek <= 0
				)
			RAISERROR (
					@InvalidDiaryDateWeek
					,16
					,1
					);

		IF (
				@pNumberOfDaysLate IS NULL
				OR LTRIM(RTRIM(LEN(@pNumberOfDaysLate))) = 0
				OR @pNumberOfDaysLate < 0
				)
			RAISERROR (
					@InvalidNumberOfDaysLate
					,16
					,1
					);

		IF (
				@pNumberOfDaysEarly IS NULL
				OR LTRIM(RTRIM(LEN(@pNumberOfDaysEarly))) = 0
				OR @pNumberOfDaysEarly < 0
				)
			RAISERROR (
					@InvalidNumberOfDaysEarly
					,16
					,1
					);

		IF (
				@pBusinessId IS NULL
				OR LTRIM(RTRIM(LEN(@pBusinessId))) = 0
				)
			RAISERROR (
					@InvalidBusinessId
					,16
					,1
					);

		IF (
				@pTogether IS NULL
				OR LTRIM(RTRIM(LEN(@pTogether))) = 0
				OR @pTogether < 0
				)
			RAISERROR (
					@InvalidTogetherValue
					,16
					,1
					);

		IF (
				@pIncentiveCode IS NULL
				OR LTRIM(RTRIM(LEN(@pIncentiveCode))) = 0
				OR @pIncentiveCode < 0
				)
			RAISERROR (
					@InvalidIncentiveCode
					,16
					,1
					);

		IF (
				@pClaimFlag IS NULL
				OR LTRIM(RTRIM(LEN(@pClaimFlag))) = 0
				OR @pClaimFlag < 0
				)
			RAISERROR (
					@InvalidClaimFlag
					,16
					,1
					);

		IF (ISDATE(@pReceivedDate) = 0)
		BEGIN
			RAISERROR (
					@InvalidReceivedDate
					,16
					,1
					);
		END
		Declare @CountryId uniqueidentifier 

		select @CountryId = CountryId from Country where CountryISO2A = @pCountryCode
		INSERT INTO DiaryEntry (
			Id
			,Points
			,DiaryDateYear
			,DiaryDatePeriod
			,DiaryDateWeek
			,NumberOfDaysLate
			,NumberOfDaysEarly
			,DiaryState
			,ReceivedDate
			,GPSUser
			,GPSUpdateTimestamp
			,CreationTimeStamp
			,DiarySourceFull
			,BusinessId
			,Together
			,PanelId
			,IncentiveCode
			,ClaimFlag
			,ConsecutiveEntriesReceived
			,Country_Id
			)
		SELECT NEWID()
			,@pPoints
			,@pDiaryDateYear
			,@pDiaryDatePeriod
			,@pDiaryDateWeek
			,@pNumberOfDaysLate
			,@pNumberOfDaysEarly
			,@DiaryState
			,DATEADD(millisecond, 10,@pReceivedDate)
			,@pGPSUser
			,@GPSUpdateTimestamp
			,@GPSUpdateTimestamp
			,@pDiarySource
			,@pBusinessId
			,@pTogether
			,@PanelId
			,@pIncentiveCode
			,@pClaimFlag
			,@pConsecutiveEntriesReceived
			,@CountryId
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

		SELECT @ErrorMessage1 = ERROR_MESSAGE(),
			   @ErrorSeverity1 = ERROR_SEVERITY(),
			   @ErrorState1 = ERROR_STATE();
	
		RAISERROR (@ErrorMessage1, -- Message text.
				   @ErrorSeverity1, -- Severity.
				   @ErrorState1 -- State.
				   );
END CATCH 

END


