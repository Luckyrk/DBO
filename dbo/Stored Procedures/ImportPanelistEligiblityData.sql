
CREATE PROCEDURE [dbo].[ImportPanelistEligiblityData] (
	@CountryCode AS VARCHAR(3) = 'TW'
	,@PanelCode AS INT = 4
	,@FileName AS VARCHAR(200)
	,@InsertedRows AS BIGINT OUTPUT 
	,@UpdatedRows AS BIGINT OUTPUT  
)
/*
Author : Suresh P
Date : 3-FEB-2015
- Initial Version

Updates: 
Date: 5-FEB-2015 ; Desc: Added new column PanelCode to error table [PanelistEligibilityErrorLog]
Added LogDate column to SSISLogTable
Added condtion to update PanelistEligibility

	--	EXEC [ImportPanelistEligiblityData] 'TW', 4, 'PanelistEligibilityImport.xlsx', @InsertedRows =0 , @UpdatedRows =0
*/
AS 
BEGIN
BEGIN TRY

DECLARE @GPSUser VARCHAR(20)  = 'ImportUser'
DECLARE @Getdate DATETIME
	SET @Getdate = (select dbo.GetLocalDateTime(GETDATE(),@CountryCode))
DECLARE @insertedDate DATETIME = @Getdate


DECLARE @CountryId AS UNIQUEIDENTIFIER

SELECT @CountryId = CountryId
FROM Country WHERE CountryISO2A = @CountryCode

DECLARE @PanelGUID AS UNIQUEIDENTIFIER

SELECT @PanelGUID = GUIDReference FROM Panel
WHERE PanelCode = @PanelCode AND Country_Id = @CountryId

DECLARE @PanelistId AS UNIQUEIDENTIFIER
DECLARE @paneltype AS VARCHAR(20)

SELECT @paneltype = [Type]
FROM Panel WHERE PanelCode = @PanelCode
AND Country_Id = @CountryId

------------------------------------------
-- Find Panelist
-------------------------------------------
DECLARE @PanelistInfo AS TABLE (
       BusinessID VARCHAR(20),
       PanelistId UNIQUEIDENTIFIER
       )

IF (@paneltype = 'HouseHold')
BEGIN
       INSERT INTO @PanelistInfo (
              BusinessID,
              PanelistId
              )
       SELECT DISTINCT TEMP.BusinessId, Panelist
       FROM [TEMP].[PanelistEligibilityImport] TEMP
       INNER JOIN (
              SELECT pl.GUIDReference AS Panelist,
                     I.IndividualId AS BusinessId
              FROM Panelist pl
              INNER JOIN CollectiveMembership cm ON cm.Group_Id = pl.PanelMember_Id
              INNER JOIN Individual i ON i.GUIDReference = cm.Individual_Id
              WHERE pl.Panel_Id = @PanelGUID
                     AND pl.Country_Id = @CountryId
              ) V ON TEMP.BusinessId = V.BusinessId

END
ELSE
BEGIN
       INSERT INTO @PanelistInfo (
              BusinessID,
              PanelistId
              )
       SELECT DISTINCT TEMP.BusinessId,
              Panelist
       FROM [TEMP].[PanelistEligibilityImport] TEMP
       INNER JOIN (
              SELECT pl.GUIDReference AS Panelist,
                     i.IndividualId AS BusinessId
              FROM Panelist pl
              INNER JOIN Individual i ON i.GUIDReference = pl.PanelMember_Id
              WHERE pl.Panel_Id = @PanelGUID
                     AND pl.Country_Id = @CountryId
              ) V ON TEMP.BusinessId = V.BusinessId
END
	  
------------------------------------------
-- Find Calendar
-------------------------------------------
DECLARE @CalendarID AS UNIQUEIDENTIFIER
DECLARE @YearPeriodTypeId AS UNIQUEIDENTIFIER
DECLARE @MonthPeriodTypeId AS UNIQUEIDENTIFIER
DECLARE @WeekPeriodTypeId AS UNIQUEIDENTIFIER

SET @CalendarID = (
              SELECT TOP 1 CalendarID
              FROM PanelCalendarMapping
              WHERE OwnerCountryId = @CountryId
                     AND PanelID = @PanelGUID
              ORDER BY CalendarID DESC
              )

IF (@CalendarID IS NULL)
BEGIN
       SET @CalendarID = (
                     SELECT TOP 1 CalendarId
                     FROM CountryCalendarMapping
                     WHERE CountryId = @CountryId
                           AND CalendarId NOT IN (
                                  SELECT CalendarID
                                  FROM PanelCalendarMapping
                                  WHERE OwnerCountryId = @CountryId
                                  )
                     )
END


SELECT @YearPeriodTypeId = CH.ParentPeriodTypeId,
       @MonthPeriodTypeId = CH.ChildPeriodTypeId
FROM CalendarPeriod Cp
INNER JOIN CalendarPeriodHierarchy CH ON Cp.CalendarId = CH.CalendarId
WHERE Cp.CalendarId = @CalendarID
       AND CH.SequenceWithinHierarchy IN (1) --AND Cp.PeriodValue = @pYear

SELECT @WeekPeriodTypeId = CH.ChildPeriodTypeId
FROM CalendarPeriod Cp
INNER JOIN CalendarPeriodHierarchy CH ON Cp.CalendarId = CH.CalendarId
WHERE Cp.CalendarId = @CalendarID
       AND CH.SequenceWithinHierarchy IN (2) --AND Cp.PeriodValue = @pYear

DECLARE @CAL AS TABLE (
       PeriodId UNIQUEIDENTIFIER,
       PeriodValue INT,
       [Year] INT,
       Period INT,
       StartDate DATETIME,
       EndDate DATETIME
       )

INSERT INTO @CAL (
       PeriodId,
       PeriodValue,
       [Year],
       Period,
       StartDate,
       EndDate
       )

	SELECT DISTINCT P.PeriodId,
       P.PeriodValue,
       substring(Period, 1, 4) AS [Year],
       SUBSTRING(Period, CHARINDEX('.', Period) + 1, 2) AS [Period],
       CASE 
              WHEN SUBSTRING(Period, CHARINDEX('.', Period) + 1, 2) <> 0
                     THEN p.StartDate
              WHEN substring(Period, 1, 4) <> 0
                     THEN y.StartDate
              END,
       CASE 
              WHEN SUBSTRING(Period, CHARINDEX('.', Period) + 1, 2) <> 0
                     THEN p.StartDate
              WHEN substring(Period, 1, 4) <> 0
                     THEN y.EndDate
              END AS EndDate
	FROM [TEMP].[PanelistEligibilityImport]
	JOIN CalendarPeriod y ON substring(Period, 1, 4) = y.PeriodValue
	JOIN CalendarPeriod p ON (
				  p.StartDate BETWEEN y.StartDate
						 AND y.EndDate
				  )
		   AND (y.CalendarId = p.CalendarId)
	JOIN CalendarPeriod w ON (
				  w.StartDate BETWEEN p.StartDate
						 AND p.EndDate
				  )
		   AND (w.CalendarId = p.CalendarId)
	WHERE y.CalendarId = @CalendarID
       AND y.OwnerCountryId = @CountryId
       AND y.PeriodTypeId = @YearPeriodTypeId
       AND p.PeriodTypeId = @MonthPeriodTypeId
       AND w.PeriodTypeId = @WeekPeriodTypeId
       AND p.PeriodValue = CASE 
		WHEN SUBSTRING(Period, CHARINDEX('.', Period) + 1, 2) = 0
				THEN 1
		ELSE SUBSTRING(Period, CHARINDEX('.', Period) + 1, 2)
		END


--------------------------------------
-- ERROR LOG
--------------------------------------

-- ERROR : 1. INVALID PANELIST
INSERT INTO [dbo].[PanelistEligibilityErrorLog]
([FileName],PanelCode, ErrorSource, ErrorCode, ErrorDescription, ErrorDate )

SELECT @FileName , @PanelCode,'BusinessId', '0', 'Invalid BusinessID : ' + BusinessId , @Getdate
FROM
	(
	SELECT DISTINCT TEMP.BusinessId          
	FROM [TEMP].[PanelistEligibilityImport] TEMP
	Where TEMP.BusinessId not in 
	(     SELECT IndividualId AS BusinessId
		FROM Panelist pl
		INNER JOIN CollectiveMembership cm ON cm.Group_Id = pl.PanelMember_Id
		INNER JOIN Individual i ON i.GUIDReference = cm.Individual_Id
		WHERE pl.Panel_Id = @PanelGUID AND pl.Country_Id = @CountryId
	union all
		SELECT  i.IndividualId AS BusinessId
		FROM Panelist pl
		INNER JOIN Individual i ON i.GUIDReference = pl.PanelMember_Id
		WHERE pl.Panel_Id = @PanelGUID
		AND pl.Country_Id = @CountryId
		)
	) V

				
-- ERROR : 2. Calendar errors

INSERT INTO [dbo].[PanelistEligibilityErrorLog]
([FileName], PanelCode, ErrorSource, ErrorCode, ErrorDescription, ErrorDate )
SELECT @FileName , @PanelCode, 'Calendar', '0', 'Invalid Calendar Period for BusinessId: ' + BusinessId + ', Period: ' + Period, @Getdate
FROM
	(
		select  [Period], BusinessId  FROM [TEMP].[PanelistEligibilityImport]
		Where Period is null
union all				
		select  [Period], BusinessId    FROM [TEMP].[PanelistEligibilityImport]
		Where SUBSTRING(Period, CHARINDEX('.', Period) + 1, 2) > 13 and  SUBSTRING(Period, CHARINDEX('.', Period) + 1, 2)= 0
union all
		select [Period], BusinessId  FROM [TEMP].[PanelistEligibilityImport]
		Where substring(Period, 1, 4) not in 
		(Select PeriodValue  From CalendarPeriod Where CalendarId = @CalendarID AND 
		 PeriodTypeId = @YearPeriodTypeId AND OwnerCountryId = @CountryId)
	) V


	
-- ERROR : 3. Demographic Weight Warning
INSERT INTO [dbo].[PanelistEligibilityErrorLog]
([FileName], PanelCode, ErrorSource, ErrorCode, ErrorDescription, ErrorDate )

SELECT @FileName , @PanelCode,  'DemographicWeight', '0', 'Warning: Demographic Weight Value is NULL for BusinessId: ' + BusinessId + ' Period: ' + Period , @Getdate
FROM [TEMP].[PanelistEligibilityImport] AS TEMP
Where DemographicWeight is null OR DemographicWeight = ''


/*
-- ERROR : 4. IsEligible Flag
INSERT INTO [dbo].[PanelistEligibilityErrorLog]
(FileName, ErrorSource, ErrorCode, ErrorDescription, ErrorDate )

SELECT @FileName , 'IsEligible', '0', 'Invalid IsEligible Value : ' + IsEligible + ', BusinessId: ' + BusinessId, @Getdate
FROM [TEMP].[PanelistEligibilityImport] AS TEMP
*/

-------------------------------------
-- EligibilityFailureReason
------------------------------------
	INSERT INTO [EligibilityFailureReason]
	(EligibilityFailureReasonId, [Description], Country_Id, GPSUser, GPSUpdateTimestamp, CreationTimeStamp)
	SELECT NEWID()  ,EligibilityReson ,@CountryId ,@GPSUser AS [GPSUser] ,@insertedDate ,@insertedDate
	FROM (
       SELECT DISTINCT TEMP.EligibilityReson
       FROM [TEMP].[PanelistEligibilityImport] AS TEMP
       WHERE TEMP.EligibilityReson NOT IN (
                     SELECT DISTINCT [Description]
                     FROM [dbo].[EligibilityFailureReason]
                     WHERE Country_Id = @CountryId
                     )
       ) eligView
-------------------------------------

              
END TRY
BEGIN CATCH
       print 'ERRROR OCCURED:'
       --ROLLBACK TRANSACTION

		INSERT INTO [dbo].[PanelistEligibilityErrorLog]
		([FileName] ,PanelCode, ErrorSource, ErrorCode, ErrorDescription, ErrorDate )

		SELECT @FileName , @PanelCode,  'Unknown', ERROR_NUMBER(), ERROR_MESSAGE() , @Getdate
              
		PRINT ERROR_MESSAGE();

END CATCH
----------------------------------------
SET @InsertedRows = 0
SET @UpdatedRows = 0

BEGIN TRANSACTION
BEGIN TRY
			
			-- UPDATING [DemographicWeight] for exising BusinessId and Calendar Period. 

              UPDATE PE
              SET PE.[DemographicWeight] = V.[DemographicWeight],
                     GPSUser = @GPSUser,
                     [GPSUpdateTimestamp] = @insertedDate
              FROM [PanelistEligibility] PE
              INNER JOIN (
                     SELECT TEMP.[DemographicWeight],   P.PanelistId, C.PeriodId
                     FROM [TEMP].[PanelistEligibilityImport] AS TEMP
                     INNER JOIN @CAL AS C ON C.Period = SUBSTRING(TEMP.Period, CHARINDEX('.', TEMP.Period) + 1, 2)
                           AND C.Year = substring(TEMP.Period, 1, 4)
                     INNER JOIN @PanelistInfo AS P ON P.BusinessID = TEMP.BusinessId
                     ) V ON PE.PanelistId = V.PanelistId
                     AND PE.CalendarPeriod_PeriodId = V.PeriodId
					 	AND PE.[DemographicWeight] <> V.[DemographicWeight]
              WHERE PE.Country_Id = @CountryId
                     AND PE.Panel_Id = @PanelGUID
                     AND PE.CalendarPeriod_CalendarId = @CalendarID
					 


			SET @UpdatedRows = @@ROWCOUNT

			-- Create new data
              INSERT INTO [dbo].[PanelistEligibility] (
                     [GUIDReference],
                     [PanelistId],
                     [Panel_Id],
                     [EligibilityFailureReasonId],
                     [IsEligible],
                     [CalendarPeriod_CalendarId],
                     [CalendarPeriod_PeriodId],
                     [Country_Id],
                     [GPSUser],
                     [GPSUpdateTimestamp],
                     [CreationTimeStamp],
                     [DemographicWeight]
                     )
              SELECT     NEWID(),
                     P.PanelistId,
                     @PanelGUID,
                     elgReason.EligibilityFailureReasonId AS [EligibilityFailureReasonId],
                     IsEligible AS IsEligible --- 
                     ,      @CalendarID,
                     C.PeriodId,
                     @CountryId,
                     @GPSUser AS [GPSUser],
                     @insertedDate,
                     @insertedDate,
                     [DemographicWeight]
              FROM [TEMP].[PanelistEligibilityImport] AS TEMP
              INNER JOIN @CAL AS C ON C.Period = SUBSTRING(TEMP.Period, CHARINDEX('.', TEMP.Period) + 1, 2)
                     AND C.Year = substring(TEMP.Period, 1, 4)
              INNER JOIN @PanelistInfo AS P ON P.BusinessID = TEMP.BusinessId
              LEFT JOIN EligibilityFailureReason AS elgReason
               ON elgReason.[Description] = TEMP.EligibilityReson AND elgReason.Country_Id = @CountryId
              WHERE NOT EXISTS (
                           SELECT 1
                           FROM [dbo].[PanelistEligibility]
                           WHERE Panel_Id = @PanelGUID
                                  AND CalendarPeriod_CalendarId = @CalendarID
                                  AND CalendarPeriod_PeriodId = C.PeriodId
                                  AND Country_Id = @CountryId
                                  AND PanelistId = P.PanelistId
                           )
						   
			SET @InsertedRows = @@ROWCOUNT

END TRY
BEGIN CATCH
       print 'ERRROR OCCURED:'
       ROLLBACK TRANSACTION

              DECLARE @ErrorNumber1 INT = ERROR_NUMBER();
              DECLARE @ErrorLine1 INT = ERROR_LINE();
              DECLARE @ErrorMessage1 NVARCHAR(4000) = ERROR_MESSAGE();
              DECLARE @ErrorSeverity1 INT = ERROR_SEVERITY();
              DECLARE @ErrorState1 INT = ERROR_STATE();
			  
			INSERT INTO [dbo].[PanelistEligibilityErrorLog]
			([FileName],PanelCode, ErrorSource, ErrorCode, ErrorDescription, ErrorDate )

			SELECT @FileName , @PanelCode, 'Unknown', ERROR_NUMBER(), ERROR_MESSAGE() , @Getdate
              
			PRINT ERROR_MESSAGE();

       END CATCH

COMMIT TRANSACTION


END