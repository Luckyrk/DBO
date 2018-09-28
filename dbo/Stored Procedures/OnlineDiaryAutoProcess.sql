CREATE PROCEDURE [dbo].[OnlineDiaryAutoProcess] (
	@FileName NVARCHAR(500)
	,@TPanelId INT
	,@TotalCount BIGINT
	,@ImportType INT
	,@CountryCode VARCHAR(10)
	,@LocalFileName NVARCHAR(500)
	,@AuditID NVARCHAR(200) 
	)
AS
/*##########################################################################
-- Name				: OnlineDiaryAutoProcess
-- Date             : 2015-01-06
-- Author           : Jagadeesh B
-- Company          : Cognizant Technology Solution
-- Purpose          : Online Dairy Job
-- Sample Execution :
Exec OnlineDiaryAutoProcess 'panel_export_20141214180000.csv',4,100,1,'TW','F:\fromftp\MalePanel\panel_export_20141214180000.csv'
##########################################################################
-- ver  user			 date        change 
-- 1.0  Jagadeesh B      2015-01-06	 Initial
-- 1.1 Jagadeesh B       2015-01-12  changed for diarystate
--  Jagadeesh B       2015-Feb-03    added Uid coulmn to failed daieries
--  Jagadeesh B       2015-Mar-06    changed the logic to get the indv id from alias lookup using Uid (insted of U_Other_id)
Updates: 
	-- 14/05/2015 Allocate incentive points to LP individual.
	-- 16/11/2015 @IncentiveCode for SSW added default code = 0 and value = 0
	-- 16/11/2015 for LP incentives, updated CountryCode column GiftPrice = 0 (it was NULL)
	-- 02/03/2017 Updated BatchId, TransactionID columns
##########################################################################*/
BEGIN
BEGIN TRY
	DECLARE @PanelName AS NVARCHAR(100)
	DECLARE @RowCount BIGINT = 0
	DECLARE @Passed BIGINT = 0
	DECLARE @PanelGUID AS NVARCHAR(100)
	DECLARE @CountryGUID AS NVARCHAR(100)DECLARE @PanelId AS NVARCHAR(100)
	DECLARE @DiaryEntryStgId AS NVARCHAR(100)
	DECLARE @Id AS NVARCHAR(100)
	DECLARE @NPAN AS NVARCHAR(100)
	DECLARE @BusinessId AS NVARCHAR(100)
	DECLARE @PanellistId AS NVARCHAR(100)
	DECLARE @ReceivedDate AS NVARCHAR(100)
	DECLARE @DiaryDateFull AS NVARCHAR(100)
	DECLARE @DiaryDateYear AS NVARCHAR(100)
	DECLARE @DiaryDatePeriod AS NVARCHAR(100)
	DECLARE @DiaryDateWeek AS NVARCHAR(100)
	DECLARE @IncentiveCode AS NVARCHAR(100)
	DECLARE @Points AS NVARCHAR(100)
	DECLARE @NumberOfDaysLate AS NVARCHAR(100)
	DECLARE @NumberOfDaysEarly AS NVARCHAR(100)
	DECLARE @IsDuplicate AS NVARCHAR(100)
	DECLARE @IsDropout AS NVARCHAR(100)
	DECLARE @IsConfirmed AS NVARCHAR(100)
	DECLARE @DiaryState AS NVARCHAR(100)
	DECLARE @DiarySourceValue AS NVARCHAR(100)
	DECLARE @DiarySourceFull AS NVARCHAR(100)
	DECLARE @GPSUser AS NVARCHAR(100)
	DECLARE @GPSUpdateTimestamp AS NVARCHAR(100)
	DECLARE @CreationTimeStamp AS NVARCHAR(100)
	DECLARE @Together AS NVARCHAR(100)
	DECLARE @ClaimFlag AS NVARCHAR(100)
	DECLARE @ERROR_NUMBER BIGINT
	DECLARE @ERROR_MESSAGE NVARCHAR(MAX)
	DECLARE @PN NVARCHAR(100)
	DECLARE @PanelType NVARCHAR(100)
	DECLARE @NPAN_ALIAS NVARCHAR(100)
	DECLARE @IndividualId VARCHAR(20)
	DECLARE @Getdate DATETIME
	SET @Getdate = (select dbo.GetLocalDateTime(GETDATE(),@CountryCode))
	SET @GPSUser  = 'OnlineDiary_Auto'

	SELECT @CountryGUID = CountryId
	FROM Country
	WHERE CountryISO2A = @CountryCode

	SELECT @PanelName = [Name]
		,@PanelGUID = GUIDReference
		,@PanelType = [Type]
	FROM dbo.Panel
	WHERE PanelCode = CONVERT(INT, @TPanelId)
		AND Country_Id = @CountryGUID

	SET @PN = @PanelName
	SET @RowCount = @TotalCount

	BEGIN TRANSACTION Tran01

	BEGIN TRY
		DECLARE @MaxBatchID as BIGINT
		DECLARE @TransactionID AS BIGINT = 0
		
		Select @MaxBatchID = Max(BatchID) + 1 from IncentiveAccountTransaction
		Where Country_Id = @CountryGUID 
		
		IF @MaxBatchID IS NULL
		BEGIN 
			SET @MaxBatchID = 1
		END

		DECLARE @DairyCursor CURSOR SET @DairyCursor = CURSOR
		FOR
		(
				SELECT DiaryEntryStgId
					,NEWID() AS Id
					,N'' + isnull(f.[u_other_id], '') AS NPAN
					,N'' + isnull(f.[u_other_id], '') AS BusinessId
					,NEWID() AS PanellistId
					,d.PanelId
					,@PN AS PanelName
					,ReceivedDate
					,N'YYYY.PP.WW' AS DiaryDateFull
					,YEAR(ReceivedDate) AS DiaryDateYear
					,MONTH(ReceivedDate) AS DiaryDatePeriod
					,MONTH(ReceivedDate) / 4 AS DiaryDateWeek
					,0 AS IncentiveCode
					,Points
					,0 AS NumberOfDaysLate
					,0 AS NumberOfDaysEarly
					,0 AS IsDuplicate
					,0 AS IsDropout
					,1 AS IsConfirmed
					,N'Live' AS DiaryState
					,DiarySourceValue
					,N'Online' AS DiarySourceFull
					,N'' + @GPSUser AS GPSUser
					,@Getdate AS GPSUpdateTimestamp
					,@Getdate AS CreationTimeStamp
					,0 AS Together
					,0 AS ClaimFlag
					,CountryCode
					,d.NPAN AS NPAN_ALIAS
				FROM Staging.DiaryEntryStage d
				LEFT JOIN TWN_OnLineDiaryProcessing.dbo.ftpFileImport f ON d.NPAN = f.[uid] COLLATE SQL_Latin1_General_CP1_CI_AI
					AND f.processid = @AuditID
				WHERE d.CountryCode = @CountryCode
				)

		OPEN @DairyCursor

		FETCH NEXT
		FROM @DairyCursor
		INTO @DiaryEntryStgId
			,@Id
			,@NPAN
			,@BusinessId
			,@PanellistId
			,@PanelId
			,@PanelName
			,@ReceivedDate
			,@DiaryDateFull
			,@DiaryDateYear
			,@DiaryDatePeriod
			,@DiaryDateWeek
			,@IncentiveCode
			,@Points
			,@NumberOfDaysLate
			,@NumberOfDaysEarly
			,@IsDuplicate
			,@IsDropout
			,@IsConfirmed
			,@DiaryState
			,@DiarySourceValue
			,@DiarySourceFull
			,@GPSUser
			,@GPSUpdateTimestamp
			,@CreationTimeStamp
			,@Together
			,@ClaimFlag
			,@CountryCode
			,@NPAN_ALIAS

		WHILE @@FETCH_STATUS = 0
		BEGIN
			BEGIN TRY
				SELECT @CountryGUID = CountryId
				FROM Country
				WHERE CountryISO2A = @CountryCode

				DECLARE @CalendarID AS NVARCHAR(100)

				SET @CalendarID = (
						SELECT TOP 1 CalendarID
						FROM PanelCalendarMapping
						WHERE OwnerCountryId = @CountryGUID
							AND PanelID = @PanelGUID
						ORDER BY CalendarID DESC
						)

				IF (@CalendarID IS NULL)
				BEGIN
					SET @CalendarID = (
							SELECT TOP 1 CalendarID
							FROM CountryCalendarMapping
							WHERE CountryId = @CountryGUID
								AND CalendarId NOT IN (
									SELECT CalendarID
									FROM PanelCalendarMapping
									WHERE OwnerCountryId = @CountryGUID
									)
							)
				END

				DECLARE @PeriodValue AS NVARCHAR(100)

				SET @PeriodValue = (
						SELECT TOP 1 PeriodValue
						FROM CalendarPeriod CP
						INNER JOIN PeriodType PT ON CP.PeriodTypeId = PT.PeriodTypeId
						WHERE CalendarId = @CalendarID
							AND PeriodGroup = 1
							AND PeriodGroupSequence = 3
							AND DATEADD(week, - 1, CONVERT(DATE, @Getdate, 113)) BETWEEN CONVERT(DATE, StartDate, 113)
								AND CONVERT(DATE, EndDate, 113)
						)
				SET @DiaryDateWeek = @PeriodValue
				SET @DiaryDatePeriod = (
						SELECT TOP 1 PeriodValue
						FROM CalendarPeriod CP
						INNER JOIN PeriodType PT ON CP.PeriodTypeId = PT.PeriodTypeId
						WHERE CalendarId = @CalendarID
							AND PeriodGroup = 1
							AND PeriodGroupSequence = 2
							AND DATEADD(week, - 1, CONVERT(DATE, @Getdate, 113)) BETWEEN CONVERT(DATE, StartDate, 113)
								AND CONVERT(DATE, EndDate, 113)
						)
				SET @DiaryDateYear = (
						SELECT TOP 1 PeriodValue
						FROM CalendarPeriod CP
						INNER JOIN PeriodType PT ON CP.PeriodTypeId = PT.PeriodTypeId
						WHERE CalendarId = @CalendarID
							AND PeriodGroup = 1
							AND PeriodGroupSequence = 1
							AND DATEADD(week, - 1, CONVERT(DATE, @Getdate, 113)) BETWEEN CONVERT(DATE, StartDate, 113)
								AND CONVERT(DATE, EndDate, 113)
						)

				IF @DiaryDateWeek IS NOT NULL
					AND @DiaryDatePeriod IS NOT NULL
					AND @DiaryDateYear IS NOT NULL
				BEGIN
					SET @DiaryDateFull = @DiaryDateYear + '.' + @DiaryDatePeriod + '.' + @DiaryDateWeek

					DECLARE @IncentiveType NVARCHAR(250)

					SELECT @PanelName = [Name]
						,@PanelGUID = GUIDReference
					FROM dbo.Panel
					WHERE PanelCode = CONVERT(INT, @PanelId)
						AND Country_Id = @CountryGUID

					SET @IncentiveCode = (
							CASE 
								WHEN lower(replace(rtrim(ltrim(@PN)), ' ', '')) = 'worldpanel'
									THEN '1020013'
								WHEN lower(replace(rtrim(ltrim(@PN)), ' ', '')) = 'babypanel'
									THEN '0'
								WHEN lower(replace(rtrim(ltrim(@PN)), ' ', '')) = 'ladypanel'
									THEN '1020014'
								WHEN lower(replace(rtrim(ltrim(@PN)), ' ', '')) = 'malepanel'
									THEN '0'
								WHEN lower(replace(rtrim(ltrim(@PN)), ' ', '')) = 'ssw'
									THEN '0'
								END
							)
					SET @Points = (
							CASE 
								WHEN lower(replace(rtrim(ltrim(@PN)), ' ', '')) = 'worldpanel'
									THEN 100
								WHEN lower(replace(rtrim(ltrim(@PN)), ' ', '')) = 'babypanel'
									THEN 0
								WHEN lower(replace(rtrim(ltrim(@PN)), ' ', '')) = 'ladypanel'
									THEN 100
								WHEN lower(replace(rtrim(ltrim(@PN)), ' ', '')) = 'malepanel'
									THEN 0
								WHEN lower(replace(rtrim(ltrim(@PN)), ' ', '')) = 'ssw'
									THEN 0
								END
							)
					SET @IndividualId = NULL

					DECLARE @NamedAliasContextId UNIQUEIDENTIFIER = NULL

					SELECT @NamedAliasContextId = NamedAliasContextId
					FROM NamedAliasContext
					WHERE NAME LIKE 'QB%'
						AND NAME LIKE '%_ID_%'
						AND Panel_Id = @PanelGUID

					SELECT @IndividualId = IndividualId
					FROM Individual
					WHERE GUIDReference = (
							SELECT Candidate_Id
							FROM NamedAlias
							WHERE AliasContext_Id = @NamedAliasContextId
								AND [Key] = @NPAN_ALIAS
							)

					IF @IndividualId IS NULL
					BEGIN
						SET @ERROR_NUMBER = '000'
						SET @ERROR_MESSAGE = 'No MainShopper for this Group. NPAN not found: ' + @BusinessId + ', UID: ' + @NPAN_ALIAS

						EXEC TWN_OnLineDiaryProcessing.dbo.usp_InsertAuditDetailsFailure @PanelId
							,@FileName
							,@GPSUser
							,@ImportType
							,2
							,@RowCount
							,@ERROR_NUMBER
							,@ERROR_MESSAGE

						INSERT INTO dbo.FailedDiaryEntryStage (
							DiaryEntryStgId
							,NPAN
							,DiarySourceValue
							,ReceivedDate
							,Points
							,PanelId
							,[FileName]
							,GPSUser
							,GPSUpdateTimestamp
							,CreationTimeStamp
							,CountryCode
							,[UId]
							)
						VALUES (
							@Id
							,@NPAN
							,@DiarySourceValue
							,@ReceivedDate
							,@Points
							,@PanelId
							,@FileName
							,@GPSUser
							,@GPSUpdateTimestamp
							,@CreationTimeStamp
							,@CountryCode
							,@NPAN_ALIAS
							)

						DELETE
						FROM Staging.DiaryEntryStage
						WHERE DiaryEntryStgId = @DiaryEntryStgId;
					END
					ELSE
					BEGIN
						SET @DiaryState = NULL

						IF (@PanelType = 'HouseHold')
						BEGIN
							SELECT @DiaryState = Value
							FROM dbo.Panelist
							INNER JOIN Collective ON Collective.GUIDReference = dbo.Panelist.PanelMember_Id
							INNER JOIN dbo.Candidate ON dbo.Panelist.PanelMember_Id = dbo.Candidate.GUIDReference
							INNER JOIN CollectiveMembership CM ON CM.Group_Id = Collective.GUIDReference
							INNER JOIN Individual ON Individual.GUIDReference = CM.Individual_Id
							LEFT JOIN dbo.StateDefinition ON dbo.Panelist.State_Id = dbo.StateDefinition.Id
							INNER JOIN dbo.Translation ON Keyname = dbo.StateDefinition.Code
							INNER JOIN TranslationTerm ON Translation_Id = TranslationId
							WHERE Candidate.Country_Id = @CountryGUID
								AND Individual.IndividualId = @IndividualId
								AND CultureCode = 2057
						END
						ELSE
						BEGIN
							SELECT @DiaryState = Value
							FROM dbo.Panelist
							INNER JOIN Individual ON Individual.GUIDReference = dbo.Panelist.PanelMember_Id
							INNER JOIN dbo.Candidate ON dbo.Panelist.PanelMember_Id = dbo.Candidate.GUIDReference
							LEFT JOIN dbo.StateDefinition ON dbo.Panelist.State_Id = dbo.StateDefinition.Id
							INNER JOIN dbo.Translation ON Keyname = dbo.StateDefinition.Code
							INNER JOIN TranslationTerm ON Translation_Id = TranslationId
							WHERE Candidate.Country_Id = @CountryGUID
								AND Individual.IndividualId = @IndividualId
								AND CultureCode = 2057
						END

						----
						IF NOT EXISTS (
								SELECT 1
								FROM dbo.DiaryEntry
								WHERE BusinessId = @IndividualId
									AND PanelId = @PanelGUID
									AND DiaryDateYear = @DiaryDateYear
									AND DiaryDatePeriod = @DiaryDatePeriod
									AND DiaryDateWeek = @DiaryDateWeek
									AND Country_Id = @CountryGUID
								)
						BEGIN
							INSERT INTO dbo.DiaryEntry (
								Id
								,BusinessId
								,PanelId
								,ReceivedDate
								,DiaryDateYear
								,DiaryDatePeriod
								,DiaryDateWeek
								,IncentiveCode
								,Points
								,NumberOfDaysLate
								,NumberOfDaysEarly
								,DiaryState
								,DiarySourceFull
								,GPSUser
								,GPSUpdateTimestamp
								,CreationTimeStamp
								,Together
								,ClaimFlag
								,Country_Id
								)
							VALUES (
								@Id
								,@IndividualId
								,@PanelGUID
								,@ReceivedDate
								,@DiaryDateYear
								,@DiaryDatePeriod
								,@DiaryDateWeek
								,@IncentiveCode
								,@Points
								,@NumberOfDaysLate
								,@NumberOfDaysEarly
								,@DiaryState
								,@DiarySourceFull
								,@GPSUser
								,@GPSUpdateTimestamp
								,@CreationTimeStamp
								,@Together
								,@ClaimFlag
								,@CountryGUID
								)

								-- Allocate incentive points to LP individual.
								if (replace(rtrim(ltrim(@PN)), ' ', '')) = 'ladypanel'
								begin 
										
											DECLARE @PointGUID uniqueidentifier = (select top 1 GUIDReference from IncentivePoint Where Code = '1020014')
											DECLARE @IncentiveAccountTransactionInfoId uniqueidentifier =( SELECT NEWID() )
											DECLARE @TransactionSourceId uniqueidentifier
											DECLARE @IndividualGUID uniqueidentifier

											SELECT @IndividualGUID = GUIDreference FROM Individual 
											Where IndividualID =  @IndividualId and  CountryId = @CountryGUID

											DECLARE @Balance BIGINT  = ( SELECT 
																		ISNULL(
																		SUM(CASE IAT.[Type]
																			WHEN 'Debit' THEN (- 1 * ((ISNULL(Ammount,0))))
																			ELSE ISNULL(info.Ammount,0)
																			END), 0) AS Amount
																	FROM dbo.IncentiveAccount AS ia
																	INNER JOIN dbo.IncentiveAccountTransaction AS iat ON iat.Account_Id = ia.IncentiveAccountId
																		AND iat.Country_Id = ia.Country_Id
																	INNER JOIN IncentiveAccountTransactionInfo Info ON IAT.TransactionInfo_Id = Info.IncentiveAccountTransactionInfoId
																	WHERE ia.IncentiveAccountId=@IndividualGUID AND iat.Country_Id=@CountryGUID
																	GROUP BY ia.IncentiveAccountId)

											select @TransactionSourceId =  TransactionSourceId from  TransactionSource TS
											where  Code = 'S' and Country_Id = @CountryGUID

											SET @TransactionID = @TransactionID + 1

											-- 1
											INSERT INTO  IncentiveAccountTransactionInfo
											(IncentiveAccountTransactionInfoId, Ammount, GPSUser, GPSUpdateTimestamp, CreationTimeStamp, 
											GiftPrice, Discriminator, Point_Id, RewardDeliveryType_Id, Country_Id)
											select @IncentiveAccountTransactionInfoId, 100, @GPSUser GPSUser, @Getdate GPSUpdateTimestamp ,  @Getdate CreationTimestamp ,
											0 as GiftPrice,  'TransactionInfo' as Discriminator, @PointGUID  Point_Id, NULL RewardDeliveryType_Id,  @CountryGUID

											-- 2
											INSERT INTO IncentiveAccountTransaction
											(IncentiveAccountTransactionId, CreationDate, SynchronisationDate, TransactionDate, Comments, Balance,
												GPSUser, GPSUpdateTimestamp, CreationTimeStamp, 
											PackageId, TransactionInfo_Id, TransactionSource_Id, Depositor_Id, Panel_Id, DeliveryAddress_Id,
											 Account_Id, [Type],Country_Id, BatchId, TransactionId)

											SELECT  NEWID(), @Getdate, NULL, @Getdate, 'LP 100 for received diary', (ISNULL(@Balance,0)  + 100) as Balance,
											@GPSUser, @Getdate,  @Getdate, NULL PackageId , @IncentiveAccountTransactionInfoId as  TransactionInfo_Id,
											@TransactionSourceId as  TransactionSource_Id , @IndividualGUID as Depositor_Id,
											null as Panel_ID, NULL DeliveryAddress_Id, @IndividualGUID as Account_ID , 'Credit',  @CountryGUID
											,@MaxBatchID, @TransactionID

								end




							SET @Passed = @Passed + 1
						END
						ELSE
						BEGIN
							INSERT INTO dbo.FailedDiaryEntryStage (
								DiaryEntryStgId
								,NPAN
								,DiarySourceValue
								,ReceivedDate
								,Points
								,PanelId
								,[FileName]
								,GPSUser
								,GPSUpdateTimestamp
								,CreationTimeStamp
								,CountryCode
								,[UId]
								)
							VALUES (
								@Id
								,@NPAN
								,@DiarySourceValue
								,@ReceivedDate
								,@Points
								,@PanelId
								,@FileName
								,@GPSUser
								,@GPSUpdateTimestamp
								,@CreationTimeStamp
								,@CountryCode
								,@NPAN_ALIAS
								)

							DELETE
							FROM Staging.DiaryEntryStage
							WHERE DiaryEntryStgId = @DiaryEntryStgId;

							SET @ERROR_NUMBER = 00
							SET @ERROR_MESSAGE = 'Dulplicate diary (NPAN + Period)'
							SET @ERROR_MESSAGE = @ERROR_MESSAGE + ' NPAN:' + @NPAN

							EXEC [TWN_OnLineDiaryProcessing].[dbo].[usp_InsertAuditDetailsFailure] @PanelId
								,@FileName
								,@GPSUser
								,@ImportType
								,2
								,@RowCount
								,@ERROR_NUMBER
								,@ERROR_MESSAGE
						END

						DELETE
						FROM Staging.DiaryEntryStage
						WHERE DiaryEntryStgId = @DiaryEntryStgId;
					END
							---
				END
				ELSE
				BEGIN
					INSERT INTO dbo.FailedDiaryEntryStage (
						DiaryEntryStgId
						,NPAN
						,DiarySourceValue
						,ReceivedDate
						,Points
						,PanelId
						,[FileName]
						,GPSUser
						,GPSUpdateTimestamp
						,CreationTimeStamp
						,CountryCode
						,[UId]
						)
					VALUES (
						@Id
						,@NPAN
						,@DiarySourceValue
						,@ReceivedDate
						,@Points
						,@PanelId
						,@FileName
						,@GPSUser
						,@GPSUpdateTimestamp
						,@CreationTimeStamp
						,@CountryCode
						,@NPAN_ALIAS
						)

					DELETE
					FROM Staging.DiaryEntryStage
					WHERE DiaryEntryStgId = @DiaryEntryStgId;

					SET @ERROR_NUMBER = 00
					SET @ERROR_MESSAGE = 'Calendar period does not exists.'
					SET @ERROR_MESSAGE = @ERROR_MESSAGE + ' NPAN:' + @NPAN + ' ReceivedDate:' + @ReceivedDate

					EXEC [TWN_OnLineDiaryProcessing].[dbo].[usp_InsertAuditDetailsFailure] @PanelId
						,@FileName
						,@GPSUser
						,@ImportType
						,2
						,@RowCount
						,@ERROR_NUMBER
						,@ERROR_MESSAGE
				END

				FETCH NEXT
				FROM @DairyCursor
				INTO @DiaryEntryStgId
					,@Id
					,@NPAN
					,@BusinessId
					,@PanellistId
					,@PanelId
					,@PanelName
					,@ReceivedDate
					,@DiaryDateFull
					,@DiaryDateYear
					,@DiaryDatePeriod
					,@DiaryDateWeek
					,@IncentiveCode
					,@Points
					,@NumberOfDaysLate
					,@NumberOfDaysEarly
					,@IsDuplicate
					,@IsDropout
					,@IsConfirmed
					,@DiaryState
					,@DiarySourceValue
					,@DiarySourceFull
					,@GPSUser
					,@GPSUpdateTimestamp
					,@CreationTimeStamp
					,@Together
					,@ClaimFlag
					,@CountryCode
					,@NPAN_ALIAS
					--COMMIT TRANSACTION Tran01
			END TRY

			BEGIN CATCH
				SET @ERROR_NUMBER = ERROR_NUMBER()
				SET @ERROR_MESSAGE = ERROR_MESSAGE()

				EXEC TWN_OnLineDiaryProcessing.dbo.usp_InsertAuditDetailsFailure @PanelId
					,@FileName
					,@GPSUser
					,@ImportType
					,2
					,@RowCount
					,@ERROR_NUMBER
					,@ERROR_MESSAGE

				INSERT INTO dbo.FailedDiaryEntryStage (
					DiaryEntryStgId
					,NPAN
					,DiarySourceValue
					,ReceivedDate
					,Points
					,PanelId
					,[FileName]
					,GPSUser
					,GPSUpdateTimestamp
					,CreationTimeStamp
					,CountryCode
					,[UId]
					)
				SELECT @Id
					,@NPAN
					,@DiarySourceValue
					,@ReceivedDate
					,@Points
					,@PanelId
					,@FileName
					,@GPSUser
					,@GPSUpdateTimestamp
					,@CreationTimeStamp
					,@CountryCode
					,@NPAN_ALIAS
				WHERE NOT EXISTS (
						SELECT 1
						FROM FailedDiaryEntryStage
						WHERE DiaryEntryStgId = @Id
						)

				DELETE
				FROM Staging.DiaryEntryStage
				WHERE DiaryEntryStgId = @DiaryEntryStgId;

				FETCH NEXT
				FROM @DairyCursor
				INTO @DiaryEntryStgId
					,@Id
					,@NPAN
					,@BusinessId
					,@PanellistId
					,@PanelId
					,@PanelName
					,@ReceivedDate
					,@DiaryDateFull
					,@DiaryDateYear
					,@DiaryDatePeriod
					,@DiaryDateWeek
					,@IncentiveCode
					,@Points
					,@NumberOfDaysLate
					,@NumberOfDaysEarly
					,@IsDuplicate
					,@IsDropout
					,@IsConfirmed
					,@DiaryState
					,@DiarySourceValue
					,@DiarySourceFull
					,@GPSUser
					,@GPSUpdateTimestamp
					,@CreationTimeStamp
					,@Together
					,@ClaimFlag
					,@CountryCode
					,@NPAN_ALIAS
			END CATCH
		END -- while 

		CLOSE @DairyCursor

		DEALLOCATE @DairyCursor

		SELECT @CountryGUID = CountryId
		FROM Country
		WHERE CountryISO2A = @CountryCode

		IF (
				@PN IS NULL
				OR LEN(ISNULL(@PN, '')) = 0
				)
		BEGIN
			SELECT @PN = [Name]
			FROM DBO.PANEL
			WHERE PanelCode = @PanelName
				AND Country_Id = @CountryGUID
		END

		DELETE
		FROM [Staging].[ImportAuditSummary]
		WHERE Convert(DATETIME, Convert(VARCHAR, Rundate, 101)) >= Convert(DATETIME, Convert(VARCHAR, @Getdate, 101))
			AND PanelName = @PN
			AND ImportType = 1

		INSERT INTO [Staging].[ImportAuditSummary] (
			[Filename]
			,[Rows]
			,Passed
			,PanelName
			,CountryCode
			,Rundate
			,PanelId
			,ImportType
			,AuditId
			)
		VALUES (
			@LocalFileName
			,ISNULL(@RowCount, 0)
			,ISNULL(@Passed, 0)
			,@PN
			,@CountryCode
			,@Getdate
			,@PanelGUID
			,1
			,@AuditID
			)
	END TRY

	BEGIN CATCH
		SELECT @CountryGUID = CountryId
		FROM Country
		WHERE CountryISO2A = @CountryCode

		DELETE
		FROM [Staging].[ImportAuditSummary]
		WHERE Convert(DATETIME, Convert(VARCHAR, Rundate, 101)) >= Convert(DATETIME, Convert(VARCHAR, @Getdate, 101))
			AND PanelName = @PN
			AND ImportType = 1

		INSERT INTO [Staging].[ImportAuditSummary] (
			[Filename]
			,[Rows]
			,Passed
			,PanelName
			,CountryCode
			,Rundate
			,PanelId
			,ImportType
			,AuditId
			)
		VALUES (
			ISNULL(@LocalFileName, '')
			,ISNULL(@RowCount, 0)
			,ISNULL(@Passed, 0)
			,ISNULL(@PN, 'ERROR')
			,@CountryCode
			,@Getdate
			,@PanelGUID
			,1
			,@AuditID
			)
	END CATCH

	COMMIT TRANSACTION Tran01
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