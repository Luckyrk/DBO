GO

--The cast to value type 'Boolean' failed because the materialized value is null. Either the result type's generic parameter or the query must use a nullable type.
/*
declare @p1 dbo.ColumnTableType
insert into @p1 values(1,N'Year',1)
insert into @p1 values(2,N'Period',1)
insert into @p1 values(3,N'Week',1)
insert into @p1 values(4,N'PanelCode',1)
insert into @p1 values(5,N'BusinessId',1)
insert into @p1 values(6,N'IncentiveCode',1)
insert into @p1 values(7,N'IncentiveReason',1)
insert into @p1 values(8,N'Points',1)
insert into @p1 values(9,N'ReceivedDate',1)
insert into @p1 values(10,N'Source',1)
declare @p2 dbo.DiaryEntryImport
insert into @p2 values(1,N'2015',N'1',N'1',N'2',N'00000001-00',N'5',N'aaaa',N'10',N'9/24/2015 12:00:00 AM',N'4',N'2015|1|1|2|00000001-00|5|aaaa|10|24-Sep-2015|4',NULL)
exec usp_DiaryEntryImportInsert @pColumn=@p1,@pDiaryEntryImport=@p2,@pCountryId='3558A18E-CCEB-CADC-CB8C-08CF81794A86',@pUser=N'testuser',@pFileId='6EA16D70-69CB-C2B8-393C-08D2B8598C78',@pCultureCode=2057
*/
--The cast to value type 'Boolean' failed because the materialized value is null. Either the result type's generic parameter or the query must use a nullable type.
CREATE PROCEDURE [dbo].[usp_DiaryEntryImportInsert]
@pColumn ColumnTableType READONLY,
@pDiaryEntryImport dbo.DiaryEntryImport READONLY,
@pCountryId UniqueIdentifier=NULL,
@pUser VARCHAR(100)=NULL,
@pFileId UniqueIdentifier=NULL,
@pCultureCode INT=NULL,
@pSystemDate DATETIME=NULL
--@pCalendareRececiedDate DATETIME=NULL
AS
BEGIN
SET NOCOUNT ON;
BEGIN TRY
DECLARE @Getdate DATETIME
INSERT INTO DiaryInsertLog(CountryId,CreatedTimeStamp,InsertCount,[User],DiaryBeforeCount,DiaryAfterCount,Comments)
VALUES(@pCountryId,@pSystemDate,1,@pUser,1,1,'System Date Track purpose')
SET @Getdate = (select dbo.GetLocalDateTimeByCountryId(getdate(),@pCountryId))
SET @pSystemDate=@Getdate
--IF @pSystemDate IS NULL 

DECLARE @pProcessingDate DATETIME,@pCalendareRececiedDate DATETIME
		SET @pProcessingDate=DATEADD(DD,-7,@pSystemDate)
		SET @pCalendareRececiedDate =@pSystemDate
DECLARE @ErrorMessage NVARCHAR(400), @isErrorOccured BIT=0,@BusinessIdLength INT

DECLARE @YearPeriodId UNIQUEIDENTIFIER,@MonthPeriodId UNIQUEIDENTIFIER,@WeekPeriodId UNIQUEIDENTIFIER,@DiaryPointsLimitation INT

SET @DiaryPointsLimitation=(SELECT TOP 1 KV.Value FROM KeyAppSetting KA
							JOIN KeyValueAppSetting KV ON KV.KeyAppSetting_Id=KA.GUIDReference
							WHERE KV.Country_Id=@pCountryId AND KA.KeyName='DiaryPointsLimitation'
							)
IF(@DiaryPointsLimitation IS NULL)
BEGIN
	SET @DiaryPointsLimitation=6
END


	SELECT @YearPeriodId = PeriodTypeId
		FROM PeriodType
		WHERE OwnerCountry_Id = @pCountryID
			AND PeriodGroup = 1
			AND PeriodGroupSequence = 1 -- year

		SELECT @MonthPeriodId = PeriodTypeId
		FROM PeriodType
		WHERE OwnerCountry_Id = @pCountryID
			AND PeriodGroup = 1
			AND PeriodGroupSequence = 2 -- period


		SELECT @WeekPeriodId = PeriodTypeId
		FROM PeriodType
		WHERE OwnerCountry_Id = @pCountryID
			AND PeriodGroup = 1
			AND PeriodGroupSequence = 3 -- week



--Country Specific BusinessId length

CREATE TABLE #DiaryEntryImportedData
(
	[Rownumber] [int] NULL,[Year] [nvarchar](100) COLLATE DATABASE_DEFAULT NULL,[Period] [nvarchar](100)  COLLATE DATABASE_DEFAULT NULL
	,[Week] [nvarchar](100) COLLATE DATABASE_DEFAULT NULL,[PanelCode] [nvarchar](100) COLLATE DATABASE_DEFAULT NULL,
	[BusinessId] [varchar](50) COLLATE DATABASE_DEFAULT NULL,[IncentiveCode] [nvarchar](100) COLLATE DATABASE_DEFAULT NULL,[IncentiveReason] [nvarchar](400) COLLATE DATABASE_DEFAULT NULL,[Points] VARCHAR(50) NULL,
	[ReceivedDate] [nvarchar](100) COLLATE DATABASE_DEFAULT NULL,[Source] [varchar](100) COLLATE DATABASE_DEFAULT NULL,[FullRow] [nvarchar](max) COLLATE DATABASE_DEFAULT NULL
	,[GACode] [nvarchar](100) COLLATE DATABASE_DEFAULT NULL,	
	[DateRangeFrom] DATETIME NULL,[DateRangeTo] DATETIME NULL,[PointsFrom] INT NULL,[PointsTo] INT NULL,[CanPointsOverrideble] BIT NULL,
	PanelId UniqueIdentifier NULL,IncentiveTypeId UniqueIdentifier NULL,IncentiveReasonId UniqueIdentifier NULL,GroupId UniqueIdentifier NULL,
	MainShopperId UniqueIdentifier NULL,FormattedBusinessId VARCHAR(100),DiaryDate NVARCHAR(100) COLLATE DATABASE_DEFAULT NULL,PeriodDiff INT NULL,
	LateDiary VARCHAR(100) COLLATE DATABASE_DEFAULT,EarlyDiary VARCHAR(100) COLLATE DATABASE_DEFAULT,CandidateID UniqueIdentifier,Panelname NVARCHAR(100) COLLATE DATABASE_DEFAULT
	,PanelistState NVARCHAR(100) COLLATE DATABASE_DEFAULT,
	IsBusinessIDInValid BIT,IsYearInValid BIT,IsPeriodInValid BIT,IsWeeekInValid BIT,IsPanelCodeInValid BIT,IsIncentiveCodeInValid BIT,
	IsIncentiveReasonInValid BIT,IsPointsInValid BIT,IsReceivedDateInValid BIT,IsSourceInValid BIT,ActualPoints INT,PanelType VARCHAR(100),IsDroppedOutPanelist BIT
)

Declare @BusinessIdLengthtbl Table (BusinessIdLength INT)
INSERT INTO @BusinessIdLengthtbl
Exec GetBusinessIDLength @pCountryId

SET @BusinessIdLength=(SELECT TOP 1 BusinessIdLength FROM  @BusinessIdLengthtbl)


DECLARE @ActualCalendarInfo TABLE (
PanelId UNIQUEIDENTIFIER,
   CalendarId       UNIQUEIDENTIFIER ,
   IsYpwCalendar   INT ,
   ProcessingDatePeriod VARCHAR(100),
   ProcessingDatePeriodDiaryReport VARCHAR(100),
   CalendareRececiedDatePeriod VARCHAR(100),
   CalendareRececiedDatePeriodYear VARCHAR(100),
   CalendareRececiedDatePeriodPeriod VARCHAR(100),
   CalendareRececiedDatePeriodWeek VARCHAR(100),
   StartDate DATETIME,
   EndDate DATETIME,
   ReceivedDate DateTime
)

--Diary related Error Messages
DECLARE @DiaryMessages TABLE (KeyName NVARCHAR(100),Value NVARCHAR(400))
INSERT INTO @DiaryMessages
EXEC GetDiaryMessages @pCultureCode

--All valid Panels for the Country
Declare @ValidAllPanles TABLE (PanelCode INT,PanelId UniqueIdentifier,PanelType NVARCHAR(100),Panelname NVARCHAR(100))
INSERT INTO @ValidAllPanles(PanelCode,PanelId,PanelType,Panelname)
Select  distinct 
PanelCode,pnl.GUIDReference,pnl.[Type],pnl.Name
from Panel pnl
inner join Panelist pnlist on pnlist.Panel_Id=pnl.GUIDReference 
where pnl.Country_Id=@pCountryId

--GroupId for the panel and individual
Declare @GroupInfo Table (PanelId uniqueIdentifier,individualId uniqueIdentifier,GroupId uniqueIdentifier)
INSERT INTO @GroupInfo(PanelId,individualId,GroupId)
Select  distinct
pnl.GUIDReference,cm.Individual_Id,cm.Group_Id
from Panel pnl
inner join Panelist pnlist on pnlist.Panel_Id=pnl.GUIDReference 
inner join CollectiveMembership cm ON cm.Individual_Id=pnlist.PanelMember_Id
where pnl.Country_Id=@pCountryId

Declare @ValidGroups TABLE(GroupNumber VARCHAR(100))
INSERT INTO @ValidGroups
EXEC GetSequenceNumbersList @pCountryId

Declare @AvaliablePanelists TABLE(PanelId UniqueIdentifier,BusinessId VARCHAR(100),PanelistState NVARCHAR(100),IsHouseHoldPanel BIT,PanelistCreationDate DATETIME,CandidateId UniqueIdentifier,KeyName NVARCHAR(400),DiaryTypeCode NVARCHAR(100),GroupNumber VARCHAR(100))

INSERT INTO @AvaliablePanelists(PanelId,BusinessId,PanelistState,IsHouseHoldPanel,PanelistCreationDate,CandidateId,KeyName,DiaryTypeCode)
EXEC GetAvailableindividualPanelPanelists @pCultureCode,@pCountryId

INSERT INTO @AvaliablePanelists(PanelId,BusinessId,PanelistState,IsHouseHoldPanel,PanelistCreationDate,CandidateId,KeyName,DiaryTypeCode)
EXEC GetAvailableHouseholdPanelPanelists @pCultureCode,@pCountryId

UPDATE @AvaliablePanelists SET GroupNumber=(SELECT items FROM dbo.Split(BusinessId,'-') WHERE Id=1)

Declare @IncentiveReasons TABLE (IncentiveTypeId UniqueIdentifier,PanelId UniqueIdentifier,IncentiveReason NVARCHAR(400),IncentiveReasonId UniqueIdentifier,Points INT,MinPoints INT,MaxPoints INT,HasUpdatableValue BIT)

INSERT INTO #DiaryEntryImportedData([Rownumber],[Year],[Period],
	[Week],[PanelCode],[BusinessId],[IncentiveCode],[ReceivedDate],
	[Source],[FullRow],[GACode],FormattedBusinessId,IncentiveReason,Points,
	DiaryDate,IsBusinessIDInValid,IsYearInValid,IsPeriodInValid,IsWeeekInValid,IsPanelCodeInValid,
	IsIncentiveCodeInValid,IsIncentiveReasonInValid,IsPointsInValid,IsReceivedDateInValid,IsSourceInValid)
SELECT [Rownumber],[Year],[Period],
	[Week],[PanelCode],[BusinessId],[IncentiveCode],[ReceivedDate],
	[Source],[FullRow],[GACode],(SELECT TOP 1 items FROM dbo.Split(BusinessId,'-') WHERE Id=1),IncentiveReason,Points,
	ISNULL([Year],'')+ISNULL('.'+[Period],'')+ISNULL('.'+[Week],''),
	CASE
	WHEN ISNULL(BusinessId,'')='' THEN 1 ELSE 0
	END,
	CASE
	WHEN ISNULL([Year],'')='' THEN 1 
	WHEN ISNUMERIC([Year])=0 THEN 1
	ELSE 0
	END,
	CASE
	WHEN ISNULL(Period,'')='' THEN 1 
	WHEN ISNUMERIC(Period)=0 THEN 1
	ELSE 0
	END,
	CASE
	WHEN ISNULL([Week],'')='' THEN 1
	WHEN ISNUMERIC([Week])=0 THEN 1
	 ELSE 0
	END,
	CASE
	WHEN ISNULL(PanelCode,'')='' THEN 1 
	WHEN ISNUMERIC(PanelCode)=0 THEN 1
	ELSE 0
	END,
	CASE
	WHEN ISNULL(IncentiveCode,'')='' THEN 1 
	WHEN ISNUMERIC(IncentiveCode)=0 THEN 1
	ELSE 0
	END,
	CASE
	WHEN ISNUMERIC(IncentiveReason)=0 THEN 1
	WHEN ISNULL(IncentiveReason,'')='' THEN 1 ELSE 0
	END,
	0,
	CASE
	WHEN ISNULL(ReceivedDate,'')='' THEN 1 ELSE 0
	END,
	CASE
	WHEN ISNULL([Source],'')='' THEN 1 ELSE 0
	END
	FROM @pDiaryEntryImport


UPDATE #DiaryEntryImportedData SET FormattedBusinessId=(SELECT items FROM dbo.Split(BusinessId,'-') WHERE Id=1)+PanelCode 
WHERE LEN(FormattedBusinessId)<@BusinessIdLength AND FormattedBusinessId IS NOT NULL AND IsBusinessIDInValid=0


UPDATE Feed SET Feed.PanelId=VP.PanelId,Feed.Panelname=VP.Panelname,Feed.PanelType=VP.PanelType
FROM
#DiaryEntryImportedData Feed
JOIN @ValidAllPanles VP ON VP.PanelCode=Feed.PanelCode
WHERE Feed.PanelCode IS NOT NULL
AND IsPanelCodeInValid=0

UPDATE #DiaryEntryImportedData SET IsPanelCodeInValid=1 WHERE PanelId IS NULL



	IF NOT EXISTS (
			SELECT 1
			FROM ImportFile I
			INNER JOIN StateDefinition SD ON SD.Id = I.State_Id
				AND I.GUIDReference = @pFileId
			WHERE SD.Code = 'ImportFileProcessing'
				AND SD.Country_Id = @pCountryId
			)
	BEGIN
		INSERT INTO ImportAudit
		VALUES (
			NEWID(),1,1,'File already is processed',@GetDate
			,NULL,NULL,@GetDate,@pUser,@GetDate,@pFileId
			)

		EXEC InsertImportFile 'ImportFileBusinessValidationError'
			,@pUser
			,@pFileId
			,@pCountryId

		RETURN;
	END

	DECLARE @maxColumnCount INT
	--SET @maxColumnCount = (
	--		SELECT MAX(Rownumber)
	--		FROM @pColumn
	--		)
	SET @maxColumnCount =13
	DECLARE @REPETSEPARATOER NVARCHAR(MAX)
	SET @REPETSEPARATOER = REPLICATE('|', @maxColumnCount)

	IF EXISTS (SELECT 1 FROM #DiaryEntryImportedData WHERE IsBusinessIDInValid=1)
				BEGIN
					SET @ErrorMessage='The Business Id cannot be empty.'
					SET @isErrorOccured = 1
					INSERT INTO ImportAudit (
						GUIDReference,Error,IsInvalid,[Message],[Date],SerializedRowData,SerializedRowErrors
						,CreationTimeStamp,GPSUser,GPSUpdateTimestamp,[File_Id]
						)
					SELECT NEWID(),1,0,@ErrorMessage,@GetDate,[FullRow],@REPETSEPARATOER
						,@GetDate,@pUser,@GetDate,@pFileId
					FROM #DiaryEntryImportedData WHERE IsBusinessIDInValid=1
				END
	IF EXISTS (SELECT * FROM #DiaryEntryImportedData Feed WHERE ISNUMERIC(REPLACE(Feed.BusinessId,'-',''))=0 AND IsBusinessIDInValid=0)
	 BEGIN
		SET @ErrorMessage='Please enter the correct format of the Business Id.'
					SET @isErrorOccured = 1
					INSERT INTO ImportAudit (
						GUIDReference,Error,IsInvalid,[Message],[Date],SerializedRowData,SerializedRowErrors
						,CreationTimeStamp,GPSUser,GPSUpdateTimestamp,[File_Id]
						)
					SELECT NEWID(),1,0,@ErrorMessage,@GetDate,[FullRow],@REPETSEPARATOER
						,@GetDate,@pUser,@GetDate,@pFileId
					FROM #DiaryEntryImportedData Feed
					WHERE ISNUMERIC(REPLACE(Feed.BusinessId,'-',''))=0 AND IsBusinessIDInValid=0

		UPDATE #DiaryEntryImportedData SET IsBusinessIDInValid=1
		WHERE ISNUMERIC(REPLACE(BusinessId,'-',''))=0
		AND IsBusinessIDInValid=0
    END
	IF EXISTS (SELECT 1 FROM #DiaryEntryImportedData Feed WHERE Feed.IsReceivedDateInValid=1)
		BEGIN
		 SET @ErrorMessage='The received date cannot be empty.'
					SET @isErrorOccured = 1
					INSERT INTO ImportAudit (
						GUIDReference,Error,IsInvalid,[Message],[Date],SerializedRowData,SerializedRowErrors
						,CreationTimeStamp,GPSUser,GPSUpdateTimestamp,[File_Id]
						)
					SELECT NEWID(),1,0,@ErrorMessage,@GetDate,Feed.[FullRow],@REPETSEPARATOER
						,@GetDate,@pUser,@GetDate,@pFileId
					FROM #DiaryEntryImportedData Feed WHERE Feed.IsReceivedDateInValid=1

		END
	IF EXISTS (SELECT 1 FROM #DiaryEntryImportedData WHERE IsYearInValid=1)
				BEGIN
				SET @ErrorMessage='Please enter valid diary date year.'
					SET @isErrorOccured = 1
					INSERT INTO ImportAudit (
						GUIDReference,Error,IsInvalid,[Message],[Date],SerializedRowData,SerializedRowErrors
						,CreationTimeStamp,GPSUser,GPSUpdateTimestamp,[File_Id]
						)
					SELECT NEWID(),1,0,@ErrorMessage,@GetDate,[FullRow],@REPETSEPARATOER
						,@GetDate,@pUser,@GetDate,@pFileId
					FROM #DiaryEntryImportedData WHERE IsYearInValid=1
				END
	IF EXISTS (SELECT 1 FROM #DiaryEntryImportedData WHERE IsPeriodInValid=1)
				BEGIN
				SET @ErrorMessage='Please enter valid diary date Period.'
					SET @isErrorOccured = 1
					INSERT INTO ImportAudit (
						GUIDReference,Error,IsInvalid,[Message],[Date],SerializedRowData,SerializedRowErrors
						,CreationTimeStamp,GPSUser,GPSUpdateTimestamp,[File_Id]
						)
					SELECT NEWID(),1,0,@ErrorMessage,@GetDate,[FullRow],@REPETSEPARATOER
						,@GetDate,@pUser,@GetDate,@pFileId
					FROM #DiaryEntryImportedData WHERE IsPeriodInValid=1
				END
	IF EXISTS (SELECT 1 FROM #DiaryEntryImportedData WHERE IsWeeekInValid=1)
				BEGIN
				
				SET @ErrorMessage='Please enter valid diary date Week.'
					SET @isErrorOccured = 1
					INSERT INTO ImportAudit (
						GUIDReference,Error,IsInvalid,[Message],[Date],SerializedRowData,SerializedRowErrors
						,CreationTimeStamp,GPSUser,GPSUpdateTimestamp,[File_Id]
						)
					SELECT NEWID(),1,0,@ErrorMessage,@GetDate,[FullRow],@REPETSEPARATOER
						,@GetDate,@pUser,@GetDate,@pFileId
					FROM #DiaryEntryImportedData WHERE IsWeeekInValid=1
				END

	IF EXISTS (SELECT 1 FROM #DiaryEntryImportedData WHERE IsSourceInValid=1 )
	BEGIN
	SET @ErrorMessage='Source cannot be empty.'
		SET @isErrorOccured = 1
		INSERT INTO ImportAudit (
			GUIDReference,Error,IsInvalid,[Message],[Date],SerializedRowData,SerializedRowErrors
			,CreationTimeStamp,GPSUser,GPSUpdateTimestamp,[File_Id]
			)
		SELECT NEWID(),1,0,@ErrorMessage,@GetDate,[FullRow],@REPETSEPARATOER
			,@GetDate,@pUser,@GetDate,@pFileId
		FROM #DiaryEntryImportedData WHERE IsSourceInValid=1 



	END

    IF EXISTS (SELECT 1 FROM #DiaryEntryImportedData WHERE IsPanelCodeInValid=1 AND ISNULL(PanelCode,'')='')
	BEGIN
	SET @ErrorMessage='Please enter valid Panel Code'
		SET @isErrorOccured = 1
		INSERT INTO ImportAudit (
			GUIDReference,Error,IsInvalid,[Message],[Date],SerializedRowData,SerializedRowErrors
			,CreationTimeStamp,GPSUser,GPSUpdateTimestamp,[File_Id]
			)
		SELECT NEWID(),1,0,@ErrorMessage,@GetDate,[FullRow],@REPETSEPARATOER
			,@GetDate,@pUser,@GetDate,@pFileId
		FROM #DiaryEntryImportedData WHERE IsPanelCodeInValid=1 AND ISNULL(PanelCode,'')=''
	END

	IF EXISTS (SELECT 1 FROM #DiaryEntryImportedData WHERE IsPanelCodeInValid=1 AND ISNULL(PanelCode,'')<>'')
	BEGIN
	SET @ErrorMessage='Invalid Panel Code.'
		SET @isErrorOccured = 1
		INSERT INTO ImportAudit (
			GUIDReference,Error,IsInvalid,[Message],[Date],SerializedRowData,SerializedRowErrors
			,CreationTimeStamp,GPSUser,GPSUpdateTimestamp,[File_Id]
			)
		SELECT NEWID(),1,0,@ErrorMessage,@GetDate,[FullRow],@REPETSEPARATOER
			,@GetDate,@pUser,@GetDate,@pFileId
		FROM #DiaryEntryImportedData WHERE IsPanelCodeInValid=1 AND ISNULL(PanelCode,'')<>''
	END

	IF EXISTS (SELECT 1 FROM #DiaryEntryImportedData Feed
		  WHERE ISDATE(Feed.ReceivedDate)=0
		  AND Feed.IsReceivedDateInValid=0
		)
		 BEGIN
			SET @ErrorMessage='Invalid Received Date.'
			SET @isErrorOccured = 1

			INSERT INTO ImportAudit (
				GUIDReference,Error,IsInvalid,[Message],[Date],SerializedRowData,SerializedRowErrors
				,CreationTimeStamp,GPSUser,GPSUpdateTimestamp,[File_Id]
				)
			SELECT NEWID(),1,0,@ErrorMessage,@GetDate,[FullRow],@REPETSEPARATOER
				,@GetDate,@pUser,@GetDate,@pFileId
			FROM #DiaryEntryImportedData Feed
			 WHERE ISDATE(Feed.ReceivedDate)=0
			 AND Feed.IsReceivedDateInValid=0

		  UPDATE #DiaryEntryImportedData SET IsReceivedDateInValid=1
		  WHERE ISDATE(ReceivedDate)=0
		  AND IsReceivedDateInValid=0

		END

	IF EXISTS (SELECT 1 FROM #DiaryEntryImportedData Feed
		  WHERE CAST(Feed.ReceivedDate AS DATE)>CAST(@Getdate AS DATE)
		  AND ISDATE(Feed.ReceivedDate)=1
		  AND Feed.IsReceivedDateInValid=0
		)
		 BEGIN
			SET @ErrorMessage='Received date should not be in the future.'
			SET @isErrorOccured = 1

			INSERT INTO ImportAudit (
				GUIDReference,Error,IsInvalid,[Message],[Date],SerializedRowData,SerializedRowErrors
				,CreationTimeStamp,GPSUser,GPSUpdateTimestamp,[File_Id]
				)
			SELECT NEWID(),1,0,@ErrorMessage,@GetDate,[FullRow],@REPETSEPARATOER
				,@GetDate,@pUser,@GetDate,@pFileId
			FROM #DiaryEntryImportedData Feed
			WHERE CAST(Feed.ReceivedDate AS DATE)>CAST(@Getdate AS DATE)
			AND ISDATE(Feed.ReceivedDate)=1
			AND Feed.IsReceivedDateInValid=0


			UPDATE #DiaryEntryImportedData SET IsReceivedDateInValid=1
			WHERE CAST(ReceivedDate AS DATE)>CAST(@Getdate AS DATE)
			AND ISDATE(ReceivedDate)=1
			AND IsReceivedDateInValid=0

		END
	IF EXISTS (SELECT 1 
			  FROM #DiaryEntryImportedData DI 
			  LEFT JOIN @ValidGroups VG ON CAST(VG.GroupNumber AS INT)=CAST(DI.FormattedBusinessId AS INT)
			  WHERE VG.GroupNumber IS NULL AND DI.IsBusinessIDInValid=0
			 )
		BEGIN
		 SET @ErrorMessage='This group not existed.'
					SET @isErrorOccured = 1
					INSERT INTO ImportAudit (
						GUIDReference,Error,IsInvalid,[Message],[Date],SerializedRowData,SerializedRowErrors
						,CreationTimeStamp,GPSUser,GPSUpdateTimestamp,[File_Id]
						)
					SELECT NEWID(),1,0,@ErrorMessage,@GetDate,[FullRow],@REPETSEPARATOER
						  ,@GetDate,@pUser,@GetDate,@pFileId
					FROM #DiaryEntryImportedData DI 
					LEFT JOIN @ValidGroups VG ON CAST(VG.GroupNumber AS INT)=CAST(DI.FormattedBusinessId AS INT)
					WHERE VG.GroupNumber IS NULL  AND DI.IsBusinessIDInValid=0
			 
			 UPDATE DI SET DI.IsBusinessIDInValid=1
			 FROM #DiaryEntryImportedData DI 
			  LEFT JOIN @ValidGroups VG ON CAST(VG.GroupNumber AS INT)=CAST(DI.FormattedBusinessId AS INT)
			  WHERE VG.GroupNumber IS NULL AND DI.IsBusinessIDInValid=0

		END
	
	IF EXISTS (SELECT 1 FROM #DiaryEntryImportedData DI
	 LEFT JOIN @AvaliablePanelists AP ON AP.PanelId=DI.PanelId  --AND CAST(AP.GroupNumber AS INT)=CAST(DI.FormattedBusinessId AS INT)
	 WHERE AP.BusinessId IS NULL AND DI.IsPanelCodeInValid=0	 
	 )
	BEGIN
	 SET @ErrorMessage='This is not the main shopper for this panel.'
	 SET @isErrorOccured = 1
	 INSERT INTO ImportAudit (
			GUIDReference,Error,IsInvalid,[Message],[Date],SerializedRowData,SerializedRowErrors
			,CreationTimeStamp,GPSUser,GPSUpdateTimestamp,[File_Id]
			)
	 SELECT NEWID(),1,0,@ErrorMessage,@GetDate,[FullRow],@REPETSEPARATOER
			,@GetDate,@pUser,@GetDate,@pFileId
			FROM #DiaryEntryImportedData DI
	 LEFT JOIN @AvaliablePanelists AP ON AP.PanelId=DI.PanelId  -- AND CAST(AP.GroupNumber AS INT)=CAST(DI.FormattedBusinessId AS INT)
	 WHERE AP.BusinessId IS NULL AND DI.IsPanelCodeInValid=0

	 UPDATE DI SET DI.IsPanelCodeInValid=1
	 FROM #DiaryEntryImportedData DI
	 LEFT JOIN @AvaliablePanelists AP ON AP.PanelId=DI.PanelId --AND CAST(AP.GroupNumber AS INT)=CAST(DI.FormattedBusinessId AS INT)
	 WHERE AP.BusinessId IS NULL AND DI.IsPanelCodeInValid=0
	END

	IF EXISTS (  SELECT 1 FROM #DiaryEntryImportedData DI
	 LEFT JOIN @AvaliablePanelists AP ON AP.PanelId=DI.PanelId AND CAST(AP.GroupNumber AS INT)=CAST(DI.FormattedBusinessId AS INT)
	 WHERE DI.IsBusinessIDInValid=0 AND DI.IsPanelCodeInValid=0 AND AP.PanelId IS NULL
	  --AND DI.PanelType='HouseHold'
	 
	  )
				BEGIN
				SET @ErrorMessage='This is not the main shopper for this panel.' --GroupMainshopperMsg
					SET @isErrorOccured = 1
					INSERT INTO ImportAudit (
						GUIDReference,Error,IsInvalid,[Message],[Date],SerializedRowData,SerializedRowErrors
						,CreationTimeStamp,GPSUser,GPSUpdateTimestamp,[File_Id]
						)
					SELECT NEWID(),1,0,@ErrorMessage,@GetDate,[FullRow],@REPETSEPARATOER
					,@GetDate,@pUser,@GetDate,@pFileId
					FROM #DiaryEntryImportedData DI
	 LEFT JOIN @AvaliablePanelists AP ON AP.PanelId=DI.PanelId AND CAST(AP.GroupNumber AS INT)=CAST(DI.FormattedBusinessId AS INT)
	 WHERE DI.IsBusinessIDInValid=0 AND DI.IsPanelCodeInValid=0 AND AP.PanelId IS NULL
	  --AND DI.PanelType='HouseHold'

				  UPDATE DI SET DI.IsBusinessIDInValid=1
				 FROM #DiaryEntryImportedData DI
	 LEFT JOIN @AvaliablePanelists AP ON AP.PanelId=DI.PanelId AND CAST(AP.GroupNumber AS INT)=CAST(DI.FormattedBusinessId AS INT)
	 WHERE DI.IsBusinessIDInValid=0 AND DI.IsPanelCodeInValid=0 AND AP.PanelId IS NULL
	  --AND DI.PanelType='HouseHold'
				END
			


			IF EXISTS (  SELECT 1 FROM #DiaryEntryImportedData DI
	 LEFT JOIN @AvaliablePanelists AP ON AP.PanelId=DI.PanelId AND AP.BusinessId =DI.BusinessId
	 WHERE DI.IsBusinessIDInValid=0 AND DI.IsPanelCodeInValid=0 AND AP.PanelId IS NULL
	  AND DI.PanelType='Individual'
	 
	  )
				BEGIN
			SET @ErrorMessage='This is not the main shopper for this panel.' --GroupMainshopperMsg
					SET @isErrorOccured = 1
					INSERT INTO ImportAudit (
						GUIDReference,Error,IsInvalid,[Message],[Date],SerializedRowData,SerializedRowErrors
						,CreationTimeStamp,GPSUser,GPSUpdateTimestamp,[File_Id]
						)
					SELECT NEWID(),1,0,@ErrorMessage,@GetDate,[FullRow],@REPETSEPARATOER
					,@GetDate,@pUser,@GetDate,@pFileId
					FROM #DiaryEntryImportedData DI
	 LEFT JOIN @AvaliablePanelists AP ON AP.PanelId=DI.PanelId AND AP.BusinessId =DI.BusinessId
	 WHERE DI.IsBusinessIDInValid=0 AND DI.IsPanelCodeInValid=0 AND AP.PanelId IS NULL
	  AND DI.PanelType='Individual'

				  UPDATE DI SET DI.IsBusinessIDInValid=1
				 FROM #DiaryEntryImportedData DI
	 LEFT JOIN @AvaliablePanelists AP ON AP.PanelId=DI.PanelId AND AP.BusinessId =DI.BusinessId
	 WHERE DI.IsBusinessIDInValid=0 AND DI.IsPanelCodeInValid=0 AND AP.PanelId IS NULL
	  AND DI.PanelType='Individual'
				END
			

		

INSERT INTO @ActualCalendarInfo
SELECT T.PanelId,T.CalendarId,T.IsYpwCalendar,T.ProcessingDatePeriod,
T.ProcessingDatePeriodDiaryReport,T.CalendareRececiedDatePeriod,T.CalendareRececiedDatePeriodYear,
T.CalendareRececiedDatePeriodPeriod,T.CalendareRececiedDatePeriodWeek,
T.StartDate,T.EndDate,D.ReceivedDate FROM (
SELECT DISTINCT PanelId,ReceivedDate FROM #DiaryEntryImportedData DI
) D 
CROSS APPLY fn_GetActualCalendarYearPeriodWeek(@pCountryID,D.PanelId,D.ReceivedDate,D.ReceivedDate,@YearPeriodId,@MonthPeriodId,
	@WeekPeriodId) T


	DECLARE @CountryCalendarID UNIQUEIDENTIFIER
	
	IF (@CountryCalendarID IS NULL)
	BEGIN
		SET @CountryCalendarID = (
				SELECT TOP 1 CalendarId
				FROM CountryCalendarMapping
				WHERE CountryId = @pCountryId
					AND CalendarId NOT IN (
						SELECT CalendarID
						FROM PanelCalendarMapping
						WHERE OwnerCountryId = @pCountryID
						)
				)

	END

	DECLARE @ValidCalendars TABLE
	(
		CalendarID UNIQUEIDENTIFIER,		
		PanelId UNIQUEIDENTIFIER	
	)

	DECLARE @ValidCalendarPeriods TABLE
	(
		CalendarID UNIQUEIDENTIFIER,
		CalendarYear INT,
		CalendarPeriod INT,
		CalendarWeek INT,
		PanelId UNIQUEIDENTIFIER,
		RowNumber INT		
	)

	INSERT INTO @ValidCalendars(CalendarID,PanelId)
		SELECT PM.CalendarID,VP.PanelId
			FROM @ValidAllPanles VP
			LEFT JOIN PanelCalendarMapping PM ON VP.PanelId=PM.PanelID AND OwnerCountryId = @pCountryID

	UPDATE @ValidCalendars SET  CalendarID=@CountryCalendarID WHERE CalendarID IS NULL

	INSERT INTO @ValidCalendarPeriods	
	SELECT a.CalendarId,a.PeriodValue AS [year]
			,b.PeriodValue AS period
			,c.PeriodValue AS [week]		
			,VP.PanelId
				,row_number() OVER (
				PARTITION BY a.PeriodValue
				,b.PeriodValue ORDER BY c.PeriodValue
				) AS id
		FROM CalendarPeriod a
		JOIN @ValidCalendars VP ON VP.CalendarID=a.CalendarId
		INNER JOIN CalendarPeriod b ON (
				b.StartDate BETWEEN a.StartDate AND a.EndDate
				)
				AND (a.CalendarId = b.CalendarId)
		INNER JOIN CalendarPeriod c ON (
				c.StartDate BETWEEN b.StartDate
					AND b.EndDate
					)
			AND (c.CalendarId = b.CalendarId)
		WHERE  a.PeriodTypeId = @YearPeriodId
			AND b.PeriodTypeId = @MonthPeriodId
			AND c.PeriodTypeId = @WeekPeriodId
		
		UPDATE @ValidCalendarPeriods SET CalendarWeek=(CASE WHEN CalendarWeek % 4 = 0 AND RowNumber <> 5 THEN 4 
		WHEN CalendarWeek % 4 <> 0 AND RowNumber = 5 THEN 5 ELSE CalendarWeek % 4 END)


	IF EXISTS (  SELECT 1 FROM #DiaryEntryImportedData D
	LEFT JOIN @ValidCalendarPeriods  VC  ON VC.CalendarYear=D.[Year]
	WHERE VC.CalendarYear IS NULL AND D.IsYearInValid=0)
	BEGIN
		SET @ErrorMessage='InValid Year.'
		SET @isErrorOccured = 1

		INSERT INTO ImportAudit (
			GUIDReference,Error,IsInvalid,[Message],[Date],SerializedRowData,SerializedRowErrors
			,CreationTimeStamp,GPSUser,GPSUpdateTimestamp,[File_Id]
			)
		SELECT NEWID(),1,0,@ErrorMessage,@GetDate,[FullRow],@REPETSEPARATOER
			,@GetDate,@pUser,@GetDate,@pFileId
		FROM #DiaryEntryImportedData D
		LEFT JOIN @ValidCalendarPeriods  VC  ON VC.CalendarYear=D.[Year]
		WHERE VC.CalendarYear IS NULL AND D.IsYearInValid=0

	UPDATE D SET D.IsYearInValid=1
	FROM #DiaryEntryImportedData D
	LEFT JOIN @ValidCalendarPeriods  VC  ON VC.CalendarYear=D.[Year]
	WHERE VC.CalendarYear IS NULL AND D.IsYearInValid=0

	END

	IF EXISTS (  SELECT 1 FROM #DiaryEntryImportedData D
	LEFT JOIN @ValidCalendarPeriods  VC  ON VC.CalendarYear=D.[Year] AND VC.CalendarPeriod=D.Period
	WHERE VC.CalendarYear IS NULL AND D.IsYearInValid=0 AND D.IsPeriodInValid=0
	)
	BEGIN
		SET @ErrorMessage='InValid Period.'
		SET @isErrorOccured = 1

		INSERT INTO ImportAudit (
			GUIDReference,Error,IsInvalid,[Message],[Date],SerializedRowData,SerializedRowErrors
			,CreationTimeStamp,GPSUser,GPSUpdateTimestamp,[File_Id]
			)
		SELECT NEWID(),1,0,@ErrorMessage,@GetDate,[FullRow],@REPETSEPARATOER
			,@GetDate,@pUser,@GetDate,@pFileId
		FROM #DiaryEntryImportedData D
	LEFT JOIN @ValidCalendarPeriods  VC  ON VC.CalendarYear=D.[Year] AND VC.CalendarPeriod=D.Period
	WHERE VC.CalendarYear IS NULL AND D.IsYearInValid=0 AND D.IsPeriodInValid=0

	UPDATE D SET D.IsPeriodInValid=1
	FROM #DiaryEntryImportedData D
	LEFT JOIN @ValidCalendarPeriods  VC  ON VC.CalendarYear=D.[Year] AND VC.CalendarPeriod=D.Period
	WHERE VC.CalendarYear IS NULL AND D.IsYearInValid=0 AND D.IsPeriodInValid=0

	END

	IF EXISTS (  SELECT 1 FROM #DiaryEntryImportedData D
	LEFT JOIN @ValidCalendarPeriods  VC  ON VC.CalendarYear=D.[Year] AND VC.CalendarPeriod=D.Period AND VC.CalendarWeek=D.[Week]
	WHERE VC.CalendarYear IS NULL AND D.IsYearInValid=0 AND D.IsPeriodInValid=0 AND D.IsWeeekInValid=0
	)
	BEGIN
		SET @ErrorMessage='InValid Week.'
		SET @isErrorOccured = 1

		INSERT INTO ImportAudit (
			GUIDReference,Error,IsInvalid,[Message],[Date],SerializedRowData,SerializedRowErrors
			,CreationTimeStamp,GPSUser,GPSUpdateTimestamp,[File_Id]
			)
		SELECT NEWID(),1,0,@ErrorMessage,@GetDate,[FullRow],@REPETSEPARATOER
			,@GetDate,@pUser,@GetDate,@pFileId
		FROM #DiaryEntryImportedData D
	LEFT JOIN @ValidCalendarPeriods  VC  ON VC.CalendarYear=D.[Year] AND VC.CalendarPeriod=D.Period AND VC.CalendarWeek=D.[Week]
	WHERE VC.CalendarYear IS NULL AND D.IsYearInValid=0 AND D.IsPeriodInValid=0 AND D.IsWeeekInValid=0

	UPDATE D SET D.IsWeeekInValid=1
	FROM #DiaryEntryImportedData D
	LEFT JOIN @ValidCalendarPeriods  VC  ON VC.CalendarYear=D.[Year] AND VC.CalendarPeriod=D.Period AND VC.CalendarWeek=D.[Week]
	WHERE VC.CalendarYear IS NULL AND D.IsYearInValid=0 AND D.IsPeriodInValid=0 AND D.IsWeeekInValid=0

	END


	IF EXISTS (  SELECT 1 FROM @ActualCalendarInfo  AC
	JOIN #DiaryEntryImportedData D ON D.PanelId=AC.PanelId and d.ReceivedDate=ac.ReceivedDate
	WHERE CalendareRececiedDatePeriod IS NOT NULL
	AND ((CAST(D.[Year] AS INT)>CAST(AC.CalendareRececiedDatePeriodYear AS INT)) OR (  (CAST(D.[Year]  AS INT)= CAST(AC.CalendareRececiedDatePeriodYear  AS INT) AND CAST(D.Period AS INT) > CAST(AC.CalendareRececiedDatePeriodPeriod AS INT)))
	OR (  (CAST(D.[Year] AS INT) = CAST(AC.CalendareRececiedDatePeriodYear AS INT) AND CAST(D.Period AS INT) = CAST(AC.CalendareRececiedDatePeriodPeriod AS INT) AND CAST(D.[Week] AS INT) > CAST(AC.CalendareRececiedDatePeriodWeek AS INT)))
	)
	AND D.IsYearInValid=0 AND D.IsPeriodInValid=0 AND D.IsWeeekInValid=0
	)
	BEGIN
		SET @ErrorMessage='Future date period is not allowed.'
		SET @isErrorOccured = 1

		INSERT INTO ImportAudit (
			GUIDReference,Error,IsInvalid,[Message],[Date],SerializedRowData,SerializedRowErrors
			,CreationTimeStamp,GPSUser,GPSUpdateTimestamp,[File_Id]
			)
		SELECT NEWID(),1,0,@ErrorMessage,@GetDate,[FullRow],@REPETSEPARATOER
			,@GetDate,@pUser,@GetDate,@pFileId
		FROM @ActualCalendarInfo  AC
	JOIN #DiaryEntryImportedData D ON D.PanelId=AC.PanelId and d.ReceivedDate=ac.ReceivedDate
	WHERE CalendareRececiedDatePeriod IS NOT NULL
	AND ((CAST(D.[Year] AS INT)>CAST(AC.CalendareRececiedDatePeriodYear AS INT)) OR (  (CAST(D.[Year]  AS INT)= CAST(AC.CalendareRececiedDatePeriodYear  AS INT) AND CAST(D.Period AS INT) > CAST(AC.CalendareRececiedDatePeriodPeriod AS INT)))
	OR (  (CAST(D.[Year] AS INT) = CAST(AC.CalendareRececiedDatePeriodYear AS INT) AND CAST(D.Period AS INT) = CAST(AC.CalendareRececiedDatePeriodPeriod AS INT) AND CAST(D.[Week] AS INT) > CAST(AC.CalendareRececiedDatePeriodWeek AS INT)))
	) AND D.IsYearInValid=0 AND D.IsPeriodInValid=0 AND D.IsWeeekInValid=0

	UPDATE D SET D.IsYearInValid=1,D.IsPeriodInValid=1,D.IsWeeekInValid=1
	FROM @ActualCalendarInfo  AC
	JOIN #DiaryEntryImportedData D ON D.PanelId=AC.PanelId and d.ReceivedDate=ac.ReceivedDate
	WHERE CalendareRececiedDatePeriod IS NOT NULL
	AND ((CAST(D.[Year] AS INT)>CAST(AC.CalendareRececiedDatePeriodYear AS INT)) OR (  (CAST(D.[Year]  AS INT)= CAST(AC.CalendareRececiedDatePeriodYear  AS INT) AND CAST(D.Period AS INT) > CAST(AC.CalendareRececiedDatePeriodPeriod AS INT)))
	OR (  (CAST(D.[Year] AS INT) = CAST(AC.CalendareRececiedDatePeriodYear AS INT) AND CAST(D.Period AS INT) = CAST(AC.CalendareRececiedDatePeriodPeriod AS INT) AND CAST(D.[Week] AS INT) > CAST(AC.CalendareRececiedDatePeriodWeek AS INT)))
	) AND D.IsYearInValid=0 AND D.IsPeriodInValid=0 AND D.IsWeeekInValid=0

	END
	IF EXISTS(
		 SELECT 1 FROM #DiaryEntryImportedData 
		 WHERE IsBusinessIDInValid=0 AND IsPanelCodeInValid=0 AND IsYearInValid=0 AND IsPeriodInValid=0 AND IsWeeekInValid=0
		 GROUP BY DiaryDate,BusinessId,PanelId
		 HAVING COUNT(0)>1
		 )
		 BEGIN
		 SET @ErrorMessage='This is a duplicated diary for the diary period.'
		 SET @isErrorOccured = 1
		 

		INSERT INTO ImportAudit (
			GUIDReference,Error,IsInvalid,[Message],[Date],SerializedRowData,SerializedRowErrors
			,CreationTimeStamp,GPSUser,GPSUpdateTimestamp,[File_Id]
			)
		SELECT NEWID(),1,0,@ErrorMessage,@GetDate,DiaryDate+'.'+BusinessId+'.',@REPETSEPARATOER
			,@GetDate,@pUser,@GetDate,@pFileId
		FROM #DiaryEntryImportedData 
		WHERE IsBusinessIDInValid=0 AND IsPanelCodeInValid=0 AND IsYearInValid=0 AND IsPeriodInValid=0 AND IsWeeekInValid=0
		GROUP BY DiaryDate,BusinessId,PanelId,IsBusinessIDInValid,IsPanelCodeInValid,IsYearInValid,IsPeriodInValid,IsWeeekInValid 
		HAVING COUNT(0)>1

		 ;WIth TEMP AS
		 ( 
		 SELECT DiaryDate,BusinessId,PanelId,IsBusinessIDInValid,IsPanelCodeInValid,IsYearInValid,IsPeriodInValid,IsWeeekInValid 
		 FROM #DiaryEntryImportedData 
		 WHERE IsBusinessIDInValid=0 AND IsPanelCodeInValid=0 AND IsYearInValid=0 AND IsPeriodInValid=0 AND IsWeeekInValid=0
		 GROUP BY DiaryDate,BusinessId,PanelId,IsBusinessIDInValid,IsPanelCodeInValid,IsYearInValid,IsPeriodInValid,IsWeeekInValid 
		 HAVING COUNT(0)>1
		 ) 
		 UPDATE DI SET IsBusinessIDInValid=1,IsPanelCodeInValid=1,IsYearInValid=1,IsPeriodInValid=1,IsWeeekInValid=1
		 FROM #DiaryEntryImportedData  DI
		 JOIN TEMP T ON DI.DiaryDate=T.DiaryDate AND T.BusinessId=DI.BusinessId AND T.PanelId=DI.PanelId


		 END
		 
	IF EXISTS(SELECT 1 FROM #DiaryEntryImportedData DEI
		 JOIN DiaryEntry D ON D.[DiaryDateYear]=DEI.[Year] AND D.DiaryDatePeriod=DEI.Period AND D.DiaryDateWeek=DEI.[Week]
		 AND D.PanelId=DEI.PanelId AND D.BusinessId=DEI.BusinessId
		 WHERE IsBusinessIDInValid=0 AND IsPanelCodeInValid=0 AND IsYearInValid=0 AND IsPeriodInValid=0 AND IsWeeekInValid=0
		 )
		 BEGIN
		  SET @ErrorMessage='This is a duplicated diary for the diary period.'
		 SET @isErrorOccured = 1
		INSERT INTO ImportAudit (
			GUIDReference,Error,IsInvalid,[Message],[Date],SerializedRowData,SerializedRowErrors
			,CreationTimeStamp,GPSUser,GPSUpdateTimestamp,[File_Id]
			)
		SELECT NEWID(),1,0,@ErrorMessage,@GetDate,[FullRow],@REPETSEPARATOER
			,@GetDate,@pUser,@GetDate,@pFileId
		 FROM #DiaryEntryImportedData DEI
		 JOIN DiaryEntry D ON D.[DiaryDateYear]=DEI.[Year] AND D.DiaryDatePeriod=DEI.Period AND D.DiaryDateWeek=DEI.[Week]
		 AND D.PanelId=DEI.PanelId AND D.BusinessId=DEI.BusinessId
		 WHERE IsBusinessIDInValid=0 AND IsPanelCodeInValid=0 AND IsYearInValid=0 AND IsPeriodInValid=0 AND IsWeeekInValid=0

		 UPDATE DEI SET IsBusinessIDInValid=1,IsPanelCodeInValid=1,IsYearInValid=1,IsPeriodInValid=1,IsWeeekInValid=1
		 FROM #DiaryEntryImportedData DEI
		 JOIN DiaryEntry D ON D.[DiaryDateYear]=DEI.[Year] AND D.DiaryDatePeriod=DEI.Period AND D.DiaryDateWeek=DEI.[Week]
		 AND D.PanelId=DEI.PanelId AND D.BusinessId=DEI.BusinessId
		 WHERE IsBusinessIDInValid=0 AND IsPanelCodeInValid=0 AND IsYearInValid=0 AND IsPeriodInValid=0 AND IsWeeekInValid=0

		 END

		 

		  IF EXISTS(SELECT 1 FROM #DiaryEntryImportedData DEI
		  JOIN @ActualCalendarInfo AC ON AC.PanelId=DEI.PanelId and dei.ReceivedDate=ac.ReceivedDate
		  WHERE CAST(DEI.ReceivedDate AS DATE)<CAST(AC.StartDate AS DATE)
		  AND ISDATE(DEI.ReceivedDate)=1
		  AND IsBusinessIDInValid=0 AND IsPanelCodeInValid=0 AND IsYearInValid=0 AND IsPeriodInValid=0 AND IsWeeekInValid=0
		)
		 BEGIN
		  SET @ErrorMessage='Received Date is not found in the calendar.'
		 SET @isErrorOccured = 1
		INSERT INTO ImportAudit (
			GUIDReference,Error,IsInvalid,[Message],[Date],SerializedRowData,SerializedRowErrors
			,CreationTimeStamp,GPSUser,GPSUpdateTimestamp,[File_Id]
			)
		SELECT NEWID(),1,0,@ErrorMessage,@GetDate,[FullRow],@REPETSEPARATOER
			,@GetDate,@pUser,@GetDate,@pFileId
			FROM #DiaryEntryImportedData DEI
		  JOIN @ActualCalendarInfo AC ON AC.PanelId=DEI.PanelId and dei.ReceivedDate=ac.ReceivedDate
		  WHERE CAST(DEI.ReceivedDate AS DATE)<CAST(AC.StartDate AS DATE)
		  AND ISDATE(DEI.ReceivedDate)=1
		  AND IsBusinessIDInValid=0 AND IsPanelCodeInValid=0 AND IsYearInValid=0 AND IsPeriodInValid=0 AND IsWeeekInValid=0

		  UPDATE DEI SET IsBusinessIDInValid=1,IsPanelCodeInValid=1,IsYearInValid=1,IsPeriodInValid=1,IsWeeekInValid=1
		  FROM #DiaryEntryImportedData DEI
		  JOIN @ActualCalendarInfo AC ON AC.PanelId=DEI.PanelId and dei.ReceivedDate=ac.ReceivedDate
		  WHERE CAST(DEI.ReceivedDate AS DATE)<CAST(AC.StartDate AS DATE)
		  AND ISDATE(DEI.ReceivedDate)=1
		  AND IsBusinessIDInValid=0 AND IsPanelCodeInValid=0 AND IsYearInValid=0 AND IsPeriodInValid=0 AND IsWeeekInValid=0


		 END
		  IF EXISTS(SELECT 1 FROM #DiaryEntryImportedData DI
		 JOIN @AvaliablePanelists AP ON AP.BusinessId=DI.BusinessId AND DI.PanelId=AP.PanelId
		 WHERE AP.KeyName IN ('PanelistDroppedOffState','PanelistRefusalState')
		 AND DI.IsBusinessIDInValid=0 AND DI.IsPanelCodeInValid=0 
		 )
		 BEGIN
		  --SET @ErrorMessage=(SELECT Value FROM @DiaryMessages WHERE KeyName='DroppedOffWarningMsg')
		  --SET @ErrorMessage=ISNULL(@ErrorMessage,'DroppedOffWarningMsg')
		 --SET @isErrorOccured = 1
		--INSERT INTO ImportAudit (
		--	GUIDReference,Error,IsInvalid,[Message],[Date],SerializedRowData,SerializedRowErrors
		--	,CreationTimeStamp,GPSUser,GPSUpdateTimestamp,[File_Id]
		--	)
		--SELECT NEWID(),1,0,@ErrorMessage,@GetDate,[FullRow],@REPETSEPARATOER
		--	,@GetDate,@pUser,@GetDate,@pFileId
		--	FROM #DiaryEntryImportedData DI
		-- JOIN @AvaliablePanelists AP ON AP.BusinessId=DI.BusinessId
		-- WHERE AP.KeyName IN ('PanelistDroppedOffState','PanelistRefusalState')
		-- AND DI.IsBusinessIDInValid=0 AND DI.IsPanelCodeInValid=0
		
		/*
		For Dropout panel we need to allow to import but points should not be added .
		 And if the Panelist is dropped of then we need not to take care of Points related Validations.
		 */
		 UPDATE DI SET DI.IsDroppedOutPanelist=1    
		 FROM #DiaryEntryImportedData DI
		 JOIN @AvaliablePanelists AP ON AP.BusinessId=DI.BusinessId AND DI.PanelId=AP.PanelId
		 WHERE AP.KeyName IN ('PanelistDroppedOffState','PanelistRefusalState')
		 AND DI.IsBusinessIDInValid=0 AND DI.IsPanelCodeInValid=0  
		 END

	IF EXISTS (SELECT 1 FROM #DiaryEntryImportedData WHERE IsIncentiveCodeInValid=1 )
	BEGIN
	SET @ErrorMessage='Invalid Incentive Code.'
		SET @isErrorOccured = 1
		INSERT INTO ImportAudit (
			GUIDReference,Error,IsInvalid,[Message],[Date],SerializedRowData,SerializedRowErrors
			,CreationTimeStamp,GPSUser,GPSUpdateTimestamp,[File_Id]
			)
		SELECT NEWID(),1,0,@ErrorMessage,@GetDate,[FullRow],@REPETSEPARATOER
			,@GetDate,@pUser,@GetDate,@pFileId
		FROM #DiaryEntryImportedData WHERE IsIncentiveCodeInValid=1
	END
		 
		UPDATE Feed SET Feed.IncentiveTypeId=IPAET.GUIDReference
		FROM IncentivePointAccountEntryType IPAET
		JOIN #DiaryEntryImportedData Feed ON Feed.IncentiveCode=IPAET.Code
		AND IsIncentiveCodeInValid=0
		WHERE IPAET.Country_Id = @pCountryId

		IF EXISTS(SELECT 1 FROM #DiaryEntryImportedData DI
		 WHERE DI.IsIncentiveCodeInValid=0	 AND DI.IncentiveTypeId IS NULL	 
		 )
		 BEGIN
		SET @ErrorMessage='Invalid Incentive Code.'
		 SET @isErrorOccured = 1
		INSERT INTO ImportAudit (
			GUIDReference,Error,IsInvalid,[Message],[Date],SerializedRowData,SerializedRowErrors
			,CreationTimeStamp,GPSUser,GPSUpdateTimestamp,[File_Id]
			)
		SELECT NEWID(),1,0,@ErrorMessage,@GetDate,[FullRow],@REPETSEPARATOER
			,@GetDate,@pUser,@GetDate,@pFileId
			FROM #DiaryEntryImportedData DI
		 WHERE DI.IsIncentiveCodeInValid=0	AND DI.IncentiveTypeId IS NULL

		 UPDATE DI SET DI.IsIncentiveCodeInValid=1
		FROM #DiaryEntryImportedData DI
		 WHERE DI.IsIncentiveCodeInValid=0	AND DI.IncentiveTypeId IS NULL
		 END

		 INSERT INTO @IncentiveReasons(IncentiveTypeId,IncentiveReason,IncentiveReasonId,Points,MinPoints,MaxPoints,HasUpdatableValue)
		SELECT Feed.IncentiveTypeId,IP.Code,IP.GUIDReference AS Id,IP.Value AS Points,IP.Minimum,IP.Maximum,IP.HasUpdateableValue
		FROM IncentivePoint IP
		--INNER JOIN TranslationTerm tt ON IP.Description_Id = tt.Translation_Id
		--AND tt.CultureCode = @pCultureCode
		INNER JOIN #DiaryEntryImportedData Feed ON IP.[Type_Id]=Feed.IncentiveTypeId AND IP.Code=Feed.IncentiveReason -- AND tt.Value=Feed.IncentiveReason
		WHERE (IP.ValidFrom IS NULL OR CAST(IP.ValidFrom AS DATE) <= @Getdate)
			AND (IP.ValidTo IS NULL OR CAST(IP.ValidTo AS DATE) >= @Getdate)
			AND Feed.IsIncentiveCodeInValid=0 AND Feed.IsIncentiveReasonInValid=0

		UPDATE Feed SET Feed.IncentiveReasonId=IR.IncentiveReasonId,Feed.CanPointsOverrideble=IR.HasUpdatableValue,Feed.PointsFrom=IR.MinPoints,Feed.PointsTo=IR.MaxPoints
		,Feed.ActualPoints=IR.Points
		FROM #DiaryEntryImportedData Feed
		JOIN @IncentiveReasons IR ON IR.IncentiveTypeId=Feed.IncentiveTypeId  AND IR.IncentiveReason=Feed.IncentiveReason	
		AND Feed.IsIncentiveCodeInValid=0 AND Feed.IsIncentiveReasonInValid=0 --AND Feed.IsPanelCodeInValid=0

		DECLARE @WeeksInPeriod INT= 4
		   UPDATE DI SET DI.PeriodDiff=
		    (((CAST(ISNULL(AC.CalendareRececiedDatePeriodPeriod,0) AS INT) + ((CAST(ISNULL(AC.CalendareRececiedDatePeriodYear,0) AS INT) - CAST(DI.[Year] AS INT)) * 13)) * @WeeksInPeriod) + (CAST(ISNULL(AC.CalendareRececiedDatePeriodWeek,0) AS INT) - @WeeksInPeriod)) 
		   - ((CAST(DI.Period AS INT) * @WeeksInPeriod) + (CAST(DI.[Week] AS INT)- @WeeksInPeriod))
		   ,LateDiary=1,Points=0 -- If late Diary Then Points should not add
		    FROM @ActualCalendarInfo AC
		   JOIN #DiaryEntryImportedData DI ON DI.PanelId=AC.PanelId and di.ReceivedDate=ac.ReceivedDate
		   WHERE @DiaryPointsLimitation>0 AND  CAST(AC.CalendareRececiedDatePeriodYear AS INT)> CAST(DI.[Year] AS INT)
		   AND ((((CAST(ISNULL(AC.CalendareRececiedDatePeriodPeriod,0) AS INT) + ((CAST(ISNULL(AC.CalendareRececiedDatePeriodYear,0) AS INT) - CAST(DI.[Year] AS INT)) * 13)) * @WeeksInPeriod) + (CAST(ISNULL(AC.CalendareRececiedDatePeriodWeek,0) AS INT) - @WeeksInPeriod)) 
		   - ((CAST(DI.Period  AS INT) * @WeeksInPeriod) + (CAST(DI.[Week] AS INT) - @WeeksInPeriod)))>=@DiaryPointsLimitation
		   AND IsYearInValid=0 AND IsPeriodInValid=0 AND IsWeeekInValid=0

		    UPDATE DI SET DI.PeriodDiff=
		    ((CAST(ISNULL(AC.CalendareRececiedDatePeriodPeriod,0) AS INT) * @WeeksInPeriod) + (CAST(ISNULL(AC.CalendareRececiedDatePeriodWeek,0) AS INT) - @WeeksInPeriod)) - ((CAST(DI.Period AS INT) * @WeeksInPeriod) + (CAST(DI.[Week] AS INT) - @WeeksInPeriod))
			,LateDiary=1,Points=0 -- If late Diary Then Points should not add
		    FROM @ActualCalendarInfo AC
		   JOIN #DiaryEntryImportedData DI ON DI.PanelId=AC.PanelId and di.ReceivedDate=ac.ReceivedDate
		   WHERE @DiaryPointsLimitation>0 AND  CAST(AC.CalendareRececiedDatePeriodYear AS INT) = CAST(DI.[Year] AS INT)
		   AND CAST(AC.CalendareRececiedDatePeriodPeriod AS INT) >= CAST(DI.[Period] AS INT)
		   AND  (((CAST(ISNULL(AC.CalendareRececiedDatePeriodPeriod,0) AS INT) * @WeeksInPeriod) + (CAST(ISNULL(AC.CalendareRececiedDatePeriodWeek,0) AS INT) - @WeeksInPeriod)) 
		   - ((DI.Period * @WeeksInPeriod) + (DI.[Week] - @WeeksInPeriod)))>=@DiaryPointsLimitation
		   AND IsYearInValid=0 AND IsPeriodInValid=0 AND IsWeeekInValid=0

		IF EXISTS(SELECT * FROM #DiaryEntryImportedData Feed WHERE
		Feed.IsPointsInValid=0 AND Points IS NOT NULL AND ISNUMERIC(Points)=0--ISNULL(Points,0)<>0
		AND ISNULL(IsDroppedOutPanelist,0)=0
		)
		BEGIN
		 SET @ErrorMessage='Points must be Numeric.'
					SET @isErrorOccured = 1
					INSERT INTO ImportAudit (
						GUIDReference,Error,IsInvalid,[Message],[Date],SerializedRowData,SerializedRowErrors
						,CreationTimeStamp,GPSUser,GPSUpdateTimestamp,[File_Id]
						)
					SELECT NEWID(),1,0,@ErrorMessage,@GetDate,[FullRow],@REPETSEPARATOER
						,@GetDate,@pUser,@GetDate,@pFileId
					FROM #DiaryEntryImportedData Feed
					WHERE Feed.IsPointsInValid=0 AND Points IS NOT NULL AND ISNUMERIC(Points)=0
					AND ISNULL(IsDroppedOutPanelist,0)=0

					UPDATE #DiaryEntryImportedData SET IsPointsInValid=1
					WHERE IsPointsInValid=0 AND Points IS NOT NULL AND ISNUMERIC(Points)=0
					AND ISNULL(IsDroppedOutPanelist,0)=0
		END





	IF EXISTS(SELECT * FROM #DiaryEntryImportedData Feed WHERE
		Feed.IsPointsInValid=0 AND ISNULL(Feed.CanPointsOverrideble,0)=0 AND Points IS NOT NULL--ISNULL(Points,0)<>0
		AND CAST(Feed.Points AS INT)<>Feed.ActualPoints
		AND ISNULL(IsDroppedOutPanelist,0)=0 AND ISNULL(LateDiary,0)=0
		)
		BEGIN
		 SET @ErrorMessage='InValid Points.'
					SET @isErrorOccured = 1
					INSERT INTO ImportAudit (
						GUIDReference,Error,IsInvalid,[Message],[Date],SerializedRowData,SerializedRowErrors
						,CreationTimeStamp,GPSUser,GPSUpdateTimestamp,[File_Id]
						)
					SELECT NEWID(),1,0,@ErrorMessage,@GetDate,[FullRow],@REPETSEPARATOER
						,@GetDate,@pUser,@GetDate,@pFileId
					FROM #DiaryEntryImportedData Feed
					WHERE Feed.IsPointsInValid=0 AND ISNULL(Feed.CanPointsOverrideble,0)=0 AND Points IS NOT NULL-- ISNULL(Points,0)<>0
					AND CAST(Feed.Points AS INT)<>Feed.ActualPoints
					AND ISNULL(IsDroppedOutPanelist,0)=0 AND ISNULL(LateDiary,0)=0


					UPDATE #DiaryEntryImportedData SET IsPointsInValid=1
					WHERE IsPointsInValid=0 AND ISNULL(CanPointsOverrideble,0)=0 AND Points IS NOT NULL-- ISNULL(Points,0)<>0
					AND CAST(Points AS INT)<>ActualPoints
					AND ISNULL(IsDroppedOutPanelist,0)=0 AND ISNULL(LateDiary,0)=0
		END

		IF EXISTS(SELECT * FROM #DiaryEntryImportedData Feed WHERE
		Feed.IsPointsInValid=0 AND ISNULL(Feed.CanPointsOverrideble,0)=1 AND Points IS NULL
		AND ISNULL(IsDroppedOutPanelist,0)=0 AND ISNULL(LateDiary,0)=0
		)
		BEGIN
		 SET @ErrorMessage='You must select or enter the points you wish to be allocated..'
					SET @isErrorOccured = 1
					INSERT INTO ImportAudit (
						GUIDReference,Error,IsInvalid,[Message],[Date],SerializedRowData,SerializedRowErrors
						,CreationTimeStamp,GPSUser,GPSUpdateTimestamp,[File_Id]
						)
					SELECT NEWID(),1,0,@ErrorMessage,@GetDate,[FullRow],@REPETSEPARATOER
						,@GetDate,@pUser,@GetDate,@pFileId
					FROM #DiaryEntryImportedData Feed
					WHERE Feed.IsPointsInValid=0 AND ISNULL(Feed.CanPointsOverrideble,0)=1 AND Points IS NULL
					AND ISNULL(IsDroppedOutPanelist,0)=0 AND ISNULL(LateDiary,0)=0

					UPDATE #DiaryEntryImportedData SET IsPointsInValid=1
					WHERE IsPointsInValid=0 AND ISNULL(CanPointsOverrideble,0)=1 AND Points IS NULL
					AND ISNULL(IsDroppedOutPanelist,0)=0 AND ISNULL(LateDiary,0)=0
		END



		IF EXISTS(SELECT * FROM #DiaryEntryImportedData Feed WHERE --Feed.PointsFrom IS NOT NULL AND
		 ((ISNULL(CAST(Feed.Points AS INT),0)< ISNULL(Feed.PointsFrom,0)) OR (ISNULL(CAST(Feed.Points AS INT),0) > ISNULL(Feed.PointsTo,ISNULL(Feed.Points,0)+1)))
		AND Feed.IsPointsInValid=0 AND ISNULL(Feed.CanPointsOverrideble,0)=1 AND Points IS NOT NULL
		AND ISNULL(IsDroppedOutPanelist,0)=0 AND ISNULL(LateDiary,0)=0 AND ISNULL(IsBusinessIDInValid,0)=0
		)
		BEGIN
		 SET @ErrorMessage='Allocated Points Not in Range.'
					SET @isErrorOccured = 1
					INSERT INTO ImportAudit (
						GUIDReference,Error,IsInvalid,[Message],[Date],SerializedRowData,SerializedRowErrors
						,CreationTimeStamp,GPSUser,GPSUpdateTimestamp,[File_Id]
						)
					SELECT NEWID(),1,0,@ErrorMessage,@GetDate,[FullRow],@REPETSEPARATOER
						,@GetDate,@pUser,@GetDate,@pFileId
					FROM #DiaryEntryImportedData Feed
					WHERE (ISNULL(CAST(Feed.Points AS INT),0)< ISNULL(Feed.PointsFrom,0) OR ISNULL(CAST(Feed.Points AS INT),0) > ISNULL(Feed.PointsTo,0))
					AND ISNULL(CanPointsOverrideble,0)=1 AND IsPointsInValid=0 AND Points IS NOT NULL
					AND ISNULL(IsDroppedOutPanelist,0)=0 AND ISNULL(LateDiary,0)=0

					UPDATE #DiaryEntryImportedData SET IsPointsInValid=1
					WHERE (ISNULL(CAST(Points AS INT),0)< ISNULL(PointsFrom,0) OR ISNULL(CAST(Points AS INT),0) > ISNULL(PointsTo,0))
					AND ISNULL(CanPointsOverrideble,0)=1 AND IsPointsInValid=0 AND Points IS NOT NULL
					AND ISNULL(IsDroppedOutPanelist,0)=0 AND ISNULL(LateDiary,0)=0
		END

		  IF EXISTS(SELECT 1 FROM #DiaryEntryImportedData DI
		  WHERE DI.IncentiveReasonId IS NULL AND DI.IsIncentiveCodeInValid=0 AND DI.IsIncentiveReasonInValid=0
		  )
		  BEGIN
				SET @ErrorMessage='Invalid IncentiveReason.'
				SET @isErrorOccured = 1
				INSERT INTO ImportAudit (
				GUIDReference,Error,IsInvalid,[Message],[Date],SerializedRowData,SerializedRowErrors
				,CreationTimeStamp,GPSUser,GPSUpdateTimestamp,[File_Id]
				)
				SELECT NEWID(),1,0,@ErrorMessage,@GetDate,[FullRow],@REPETSEPARATOER
				,@GetDate,@pUser,@GetDate,@pFileId
				FROM #DiaryEntryImportedData DI
				 WHERE DI.IncentiveReasonId IS NULL AND DI.IsIncentiveCodeInValid=0 AND DI.IsIncentiveReasonInValid=0


				UPDATE DI SET DI.IsIncentiveReasonInValid=1
				FROM #DiaryEntryImportedData DI				
				 WHERE DI.IncentiveReasonId IS NULL AND DI.IsIncentiveCodeInValid=0 AND DI.IsIncentiveReasonInValid=0 
		 END


		   
		   UPDATE DI SET EarlyDiary=1
		    FROM @ActualCalendarInfo AC
		   JOIN #DiaryEntryImportedData DI ON DI.PanelId=AC.PanelId and di.ReceivedDate=ac.ReceivedDate
		   WHERE
		   ((AC.CalendareRececiedDatePeriodYear = DI.[Year] AND AC.CalendareRececiedDatePeriodPeriod = DI.Period AND
		    AC.CalendareRececiedDatePeriodWeek= DI.[Week]) OR
        ((CAST(AC.CalendareRececiedDatePeriodYear AS INT) < CAST(DI.[Year] AS INT))  OR (CAST(AC.CalendareRececiedDatePeriodYear AS INT) = CAST(DI.[Year] AS INT) AND CAST(AC.CalendareRececiedDatePeriodPeriod AS INT) < CAST(DI.Period AS INT)) 
		OR (CAST(AC.CalendareRececiedDatePeriodYear AS INT) = CAST(DI.[Year] AS INT) AND CAST(AC.CalendareRececiedDatePeriodPeriod AS INT) = CAST(DI.Period AS INT) AND CAST(AC.CalendareRececiedDatePeriodWeek AS INT) <  CAST(DI.[Week] AS INT))
		)
		) AND IsYearInValid=0 AND IsPeriodInValid=0 AND IsWeeekInValid=0

		

		IF (@isErrorOccured =1)
	BEGIN
		EXEC InsertImportFile 'ImportFileError'
			,@pUser
			,@pFileId
			,@pCountryId

		RETURN;
	END
	ELSE
	BEGIN
	
	UPDATE DI SET DI.CandidateID=AP.CandidateId,DI.BusinessId=AP.BusinessId,DI.PanelistState=AP.PanelistState
	FROM
	#DiaryEntryImportedData DI
	INNER JOIN @AvaliablePanelists AP ON AP.PanelId=DI.PanelId AND CAST(AP.GroupNumber AS INT)=CAST(DI.FormattedBusinessId AS INT)

IF EXISTS( SELECT 1 FROM #DiaryEntryImportedData
 GROUP BY BusinessId,PanelId,[Year], [Period],[Week] 
 HAVING COUNT(0)>1)
 BEGIN 
 
  SET @ErrorMessage='Duplicate Diaries entered for the Mainshopper:'  
    SET @isErrorOccured = 1  
    
	INSERT INTO ImportAudit (  
    GUIDReference,Error,IsInvalid,[Message],[Date],SerializedRowData,SerializedRowErrors  
    ,CreationTimeStamp,GPSUser,GPSUpdateTimestamp,[File_Id]  
    )  
	SELECT NEWID(),1,0,@ErrorMessage+ BusinessId ,@GetDate,MAX([FullRow]),@REPETSEPARATOER  
    ,@GetDate,@pUser,@GetDate,@pFileId   FROM #DiaryEntryImportedData
	GROUP BY BusinessId,PanelId,[Year], [Period],[Week] 
	HAVING COUNT(0)>1
	
	EXEC InsertImportFile 'ImportFileError'  
   ,@pUser  
   ,@pFileId  
   ,@pCountryId  
  
  RETURN;  
 
 END

 IF EXISTS (
		SELECT 1
		FROM #DiaryEntryImportedData DEI
		INNER JOIN DiaryEntry D ON D.[DiaryDateYear] = DEI.[Year]
			AND D.DiaryDatePeriod = DEI.Period
			AND D.DiaryDateWeek = DEI.[Week]
			AND D.PanelId = DEI.PanelId
			AND D.BusinessId = DEI.BusinessId
		)
BEGIN
	SET @ErrorMessage = 'Duplicate Diaries entered for the Mainshopper:'
	SET @isErrorOccured = 1

	INSERT INTO ImportAudit (
		GUIDReference
		,Error
		,IsInvalid
		,[Message]
		,[Date]
		,SerializedRowData
		,SerializedRowErrors
		,CreationTimeStamp
		,GPSUser
		,GPSUpdateTimestamp
		,[File_Id]
		)
	SELECT NEWID()
		,1
		,0
		,@ErrorMessage + BusinessId
		,@GetDate
		,[FullRow]
		,@REPETSEPARATOER
		,@GetDate
		,@pUser
		,@GetDate
		,@pFileId
	FROM #DiaryEntryImportedData DEI
	INNER JOIN DiaryEntry D ON D.[DiaryDateYear] = DEI.[Year]
		AND D.DiaryDatePeriod = DEI.Period
		AND D.DiaryDateWeek = DEI.[Week]
		AND D.PanelId = DEI.PanelId
		AND D.BusinessId = DEI.BusinessId

	--WHERE IsBusinessIDInValid=0 AND IsPanelCodeInValid=0 AND IsYearInValid=0 AND IsPeriodInValid=0 AND IsWeeekInValid=0
	RETURN;
END

	DECLARE @pDiaryEntryRecords dbo.DiaryEntryRecords
	
		INSERT INTO @pDiaryEntryRecords  ([Id],[PanelId],[PanelName],[DiaryDateYear],[DiaryDatePeriod],
	[DiaryDateWeek],[NumberOfDaysLate],[NumberOfDaysEarly],[ReceivedDate],
	[Points],[CumulativePoints],[PointId],
	[DiarySource],[DiaryState],[BusinessId],[Together],[IncentiveCode],
	[ClaimFlag],[TransactionInfoId],[IndividualId],[Balance])
	SELECT 
	NEWID(),PanelId,PanelName,[Year],Period,[Week],ISNULL(LateDiary,0),ISNULL(EarlyDiary,0),ReceivedDate,
	CASE
	WHEN ISNULL(IsDroppedOutPanelist,0)=1 THEN 0
	ELSE
	Points
	END,CASE
	WHEN ISNULL(IsDroppedOutPanelist,0)=1 THEN 0
	ELSE
	Points
	END,IncentiveReasonId,Source,
	PanelistState,BusinessId,0,IncentiveCode,0,NEWID(),CandidateID,0 FROM #DiaryEntryImportedData

	EXEC InsertDiaryEntryRecords @pUser,@pCountryId,@pCalendareRececiedDate,@pDiaryEntryRecords

	EXEC InsertImportFile 'ImportFileSuccess'
				,@pUser
				,@pFileId
				,@pCountryId

			INSERT INTO ImportAudit (
				GUIDReference
				,Error
				,IsInvalid
				,[Message]
				,[Date]
				,SerializedRowData
				,SerializedRowErrors
				,CreationTimeStamp
				,GPSUser
				,GPSUpdateTimestamp
				,[File_Id]
				)
			SELECT NEWID()
				,0
				,0
				,'Diary Imported successfully....'
				,@GetDate
				,Feed.[FullRow]
				,@REPETSEPARATOER
				,@GetDate
				,@pUser
				,@GetDate
				,@pFileId
			FROM @pDiaryEntryImport Feed


	END
	END TRY
	BEGIN CATCH
	INSERT INTO ImportAudit (
				GUIDReference,Error,IsInvalid,[Message],[Date],SerializedRowData,SerializedRowErrors
				,CreationTimeStamp,GPSUser,GPSUpdateTimestamp,[File_Id]
				)
				SELECT NEWID(),1,0,ERROR_MESSAGE(),@GetDate,ERROR_PROCEDURE(),@REPETSEPARATOER
				,@GetDate,@pUser,@GetDate,@pFileId

					EXEC InsertImportFile 'ImportFileError'
			,@pUser
			,@pFileId
			,@pCountryId
	END CATCH
END

