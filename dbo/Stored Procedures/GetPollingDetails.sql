CREATE PROCEDURE [dbo].[GetPollingDetails] (
       @pIndividualId UNIQUEIDENTIFIER
       ,@pPanelistId UNIQUEIDENTIFIER
       ,@pCountryId UNIQUEIDENTIFIER
       ,@pDeviceNumber NVARCHAR(200)
       ,@pTodayDate DateTime
       )
AS
BEGIN
BEGIN TRY
    DECLARE @pollingHistoryButton AS BIT, 
			@LastPollingStatusSuccessTranslationId AS UNIQUEIDENTIFIER, 
			@LastPollingStatusProblemTranslationId AS UNIQUEIDENTIFIER, 
			@CountryCode AS VARCHAR (10);
    SELECT @LastPollingStatusSuccessTranslationId = [TranslationId]
    FROM   [dbo].[Translation]
    WHERE  [KeyName] = 'LastPollingStatusSuccess';
    SELECT @LastPollingStatusProblemTranslationId = [TranslationId]
    FROM   [dbo].[Translation]
    WHERE  [KeyName] = 'LastPollingStatusProblem';
    SELECT @pollingHistoryButton = dbo.[IsFieldRequiredOrFieldVisible](@pCountryId, 'PollingHistoryButton', 0); -- 0 for IsVisible column
    SET @CountryCode = (SELECT TOP 1 CountryISO2A
                        FROM   Country
                        WHERE  CountryId = @pCountryId);
    DECLARE @hhNumber AS VARCHAR (20);
    DECLARE @TSQL AS VARCHAR (8000);
    CREATE TABLE #ISECPollData
    (
        Household_Number NVARCHAR (50),
        Call_start_time  DATETIME     
    );
    SELECT @hhNumber = C.Sequence
    FROM   Collective AS C
           INNER JOIN
           CollectiveMembership AS CM
           ON c.GUIDReference = CM.Group_Id
    WHERE  CM.Individual_Id = @pIndividualId;
    IF (ISNULL(@pollingHistoryButton, 0) = 1)
        BEGIN
            IF EXISTS (SELECT 1
                       FROM   Panelist AS PL
                              INNER JOIN Panel AS P ON P.GUIDReference = PL.Panel_Id
                              INNER JOIN KeyValueAppSetting AS KV ON KV.value = CAST (P.PanelCode AS NVARCHAR)
                       WHERE  PL.GUIDReference = @pPanelistId
                              AND P.Country_Id = @pCountryId)
                BEGIN
                    SET @pollingHistoryButton = 1;
                END
            ELSE
                SET @pollingHistoryButton = 0;
        END
    IF (@CountryCode = 'GB'
        AND EXISTS (SELECT * FROM   master..sysservers WHERE  srvname = N'SPAN'))
        BEGIN
            SELECT @TSQL = 'SELECT c.Household_Number,c.Call_start_time FROM 
									(SELECT  Household_Number, Call_start_time FROM OPENQUERY(SPAN, 
									''SELECT Household_number, call_start_time FROM 
									(SELECT Household_number, call_start_time ,ROW_NUMBER()OVER(PARTITION BY  Household_number ORDER BY call_start_time desc) 
										as Rownumber FROM PT0255 )  b 
									WHERE b.Household_Number =''''' + @hhNumber + ''''' and b.Rownumber = 1'') b ) c';
            INSERT INTO #ISECPollData
            EXECUTE (@TSQL);
            IF NOT EXISTS (SELECT * FROM   #ISECPollData)
                BEGIN
                    SELECT @pollingHistoryButton AS IsVisible,
                           0 AS IsLate,
                           NULL AS LastPollingDateTime;
                END
            ELSE
                BEGIN
                    SELECT TOP 1 @pollingHistoryButton AS IsVisible,
                                 CASE 
									WHEN DATEDIFF(minute, Isec.Call_start_time, @pTodayDate) > 11520 THEN 1 ELSE 0 --11520 =60*24*8 (8 days minutes)
									END AS IsLate,
                                 Isec.Call_start_time AS LastPollingDateTime
                    FROM   #ISECPollData AS Isec;
                END
        END
    IF (@CountryCode = 'IE'
        AND EXISTS (SELECT * FROM   master..sysservers WHERE  srvname = N'SPANIE'))
        BEGIN
            SELECT @TSQL = 'SELECT c.Household_Number,c.Call_start_time FROM 
									(SELECT  Household_Number, Call_start_time FROM OPENQUERY(SPANIE, 
									''SELECT Household_number, call_start_time FROM 
									(SELECT Household_number, call_start_time ,ROW_NUMBER()OVER(PARTITION BY  Household_number ORDER BY call_start_time desc) 
										as Rownumber FROM PT0255 )  b 
									WHERE b.Household_Number =''''' + @hhNumber + ''''' and b.Rownumber = 1'') b ) c';
            INSERT INTO #ISECPollData
            EXECUTE (@TSQL);
            IF NOT EXISTS (SELECT * FROM   #ISECPollData)
                BEGIN
                    SELECT @pollingHistoryButton AS IsVisible,
                           0 AS IsLate,
                           NULL AS LastPollingDateTime;
                END
            ELSE
                BEGIN
                    SELECT TOP 1 @pollingHistoryButton AS IsVisible,
                                 CASE 
									WHEN DATEDIFF(minute, Isec.Call_start_time, @pTodayDate) > 11520 THEN 1 ELSE 0 --11520 =60*24*8 (8 days minutes)
									END AS IsLate,
                                 Isec.Call_start_time AS LastPollingDateTime
                    FROM   #ISECPollData AS Isec;
                END
        END
    IF (@CountryCode = 'ES'
        AND EXISTS (SELECT * FROM   master..sysservers WHERE  srvname = N'SPANES'))
        BEGIN
            SELECT @TSQL = 'SELECT c.Household_Number,c.Call_start_time From 
									(SELECT  Household_Number, Call_start_time FROM OPENQUERY(SPANES, 
									''SELECT Household_number, call_start_time From 
									(SELECT Household_number, call_start_time ,ROW_NUMBER()OVER(PARTITION BY  Household_number ORDER BY call_start_time desc) 
										as Rownumber FROM PT0255 )  b 
									WHERE b.Household_Number =''''' + @hhNumber + ''''' and b.Rownumber = 1'') b ) c';
            INSERT INTO #ISECPollData
            EXECUTE (@TSQL);
            IF NOT EXISTS (SELECT * FROM   #ISECPollData)
                BEGIN
                    SELECT @pollingHistoryButton AS IsVisible,
                           0 AS IsLate,
                           NULL AS LastPollingDateTime;
                END
            ELSE
                BEGIN
                    SELECT TOP 1 @pollingHistoryButton AS IsVisible,
                                 CASE 
									WHEN DATEDIFF(minute, Isec.Call_start_time, @pTodayDate) > 11520 THEN 1 ELSE 0 --11520 =60*24*8 (8 days minutes)
									END AS IsLate,
                                 Isec.Call_start_time AS LastPollingDateTime
                    FROM   #ISECPollData AS Isec;
                END
        END
    ELSE
        BEGIN
            SELECT 1 AS IsVisible,
                   0 AS IsLate,
                   NULL AS LastPollingDateTime;
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