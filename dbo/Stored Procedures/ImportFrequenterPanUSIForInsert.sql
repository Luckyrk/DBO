CREATE PROCEDURE [dbo].[ImportFrequenterPanUSIForInsert] (
	@CountryCode AS VARCHAR(3) = 'FR'	
	,@FileName AS VARCHAR(200)
	,@JobId AS VARCHAR(200)
	,@ImportType AS VARCHAR(100) = 'FrequenterPanUSIImport'	
	)
	/*##########################################################################
		Author	: Satish Dandibhotla(457814)
		Date	: 04-MAY-2016 - Initial Version
		Purpose : File Imported data related to Frequenter Pan USI is available in Temp table.
				  This Procedure validated each column from the Temp table and inserts into Target table.
		EXECUTE SP:
		  DECLARE @InsertedRows BIGINT = 0 
			EXEC ImportFrequenterPanUSIForInsert  'FR', 'COMPST-MP.CSV',1 , 'FrequenterPanUSIImport' 
##########################################################################*/
AS
BEGIN
BEGIN TRY
	DECLARE @InsertedRows AS BIGINT
	DECLARE @GPSUser VARCHAR(20) = 'FrequenterPanUSIUser'
	DECLARE @GetDate DATETIME
	DECLARE @CountryId AS UNIQUEIDENTIFIER
	DECLARE @IsErrorOccured AS BIT = 0
	DECLARE @AuditId AS BIGINT

		SELECT @CountryId = CountryId
		FROM Country
		WHERE CountryISO2A = @CountryCode

		SET @GetDate = (select dbo.GetLocalDateTimeByCountryId(getdate(),@CountryId))
		DECLARE @ImportDate DATETIME = @Getdate 

	BEGIN TRY

	INSERT INTO [FileImportAuditSummary] (
		CountryCode
		,PanelID
		,PanelName
		,[Filename]
		,FileImportDate
		,GPSUser
		,TotalRows
		,PassedRows
		,[Status]
		,Comments
		,ImportType
		,JobId
		)
	VALUES (
		@CountryCode
		,NULL
		,NULL
		,@FileName
		,@ImportDate
		,@GPSUser
		,0
		,0
		,'Processing'
		,NULL
		,@ImportType
		,@JobId
		)
	SET @AuditId = @@Identity

	IF ((SELECT OBJECT_Id('tempdb..#TempFrequenterPanUSI')) is not null) 
	BEGIN
		DROP TABLE #TempFrequenterPanUSI
	END

	CREATE TABLE #TempFrequenterPanUSI (
		[household_number] [nvarchar](50) ,
		[Individual] [nvarchar](50) ,
		[USI] [nvarchar](50) ,
		[Frequency] [nvarchar](50) ,
		[Update] [nvarchar](50) ,
		[JobId] [uniqueidentifier] ,
		IsValidhousehold_number BIT,
		IsValidIndividual BIT,
		IsValidUSI BIT,
		IsValidFrequency BIT,
		IsValidBusinessId BIT
	)

	INSERT INTO  #TempFrequenterPanUSI
		(household_number,Individual,USI,Frequency,[Update],JobId,IsValidhousehold_number,IsValidIndividual,IsValidUSI,IsValidFrequency)
	SELECT 
		household_number,Individual,USI,Frequency,[Update],JobId
		,CASE
			 WHEN household_number IS NULL THEN 0
			 WHEN ISNUMERIC(household_number)=0 THEN 0
		 END
		,CASE
			 WHEN Individual IS NULL THEN 0
			 WHEN ISNUMERIC(Individual)=0 THEN 0
		 END
		,CASE
			 WHEN USI IS NULL THEN 0
			 WHEN ISNUMERIC(USI)=0 THEN 0
		 END
		,CASE
			 WHEN Frequency IS NULL THEN 0
			 WHEN ISNUMERIC(Frequency)=0 THEN 0
		 END 
	 FROM TempFrequenterPanUSI WHERE jobid=@JobId	

	UPDATE HT SET HT.IsValidhousehold_number=0
	FROM #TempFrequenterPanUSI HT
	LEFT JOIN Collective C ON C.Sequence = CAST(HT.[household_number] AS INT)
	AND C.CountryId = @CountryId
	WHERE   C.Sequence IS NULL and ISNULL(IsValidhousehold_number,1)<>0


	UPDATE T SET T.IsValidIndividual=0
	FROM #TempFrequenterPanUSI T 
	LEFT JOIN Individual I ON CAST(LEFT(I.IndividualId,CharIndex('-',I.IndividualId)-1) AS INT)=T.[household_number] 
	AND CAST(RIGHT(I.IndividualId,LEN(I.IndividualId) - CharIndex('-',I.IndividualId)) AS INT)=T.Individual 		
	WHERE I.IndividualId IS NULL AND ISNULL(IsValidIndividual,1)<>0

	UPDATE T SET T.IsValidUSI=0
	     FROM #TempFrequenterPanUSI T
		LEFT JOIN FRS.USI C ON C.usi_code = T.USI 			
			WHERE   C.usi_code IS NULL AND  ISNULL(IsValidUSI,1)<>0

		INSERT INTO [dbo].[FileImportErrorLog] (
			CountryCode
			,ImportType
			,[FileName]
			,PanelCode
			,ErrorSource
			,ErrorCode
			,ErrorDescription
			,ErrorDate
			,JobId
			)
			SELECT DISTINCT @CountryCode
			,@ImportType
			,@FileName
			,NULL
			,'HHNO'			
			,'0'
			,'Error: Household Number is Invalid'
			,@ImportDate
			,@JobId
			 FROM #TempFrequenterPanUSI HT WHERE IsValidhousehold_number=0
	  UNION
	       SELECT DISTINCT @CountryCode
			,@ImportType
			,@FileName
			,NULL
			,'Individual'			
			,'0'
			,'Error: Individual is Invalid'
			,@ImportDate
			,@JobId
			 FROM #TempFrequenterPanUSI HT WHERE IsValidIndividual=0
	   UNION
			SELECT DISTINCT @CountryCode
			,@ImportType
			,@FileName
			,NULL
			,'USI'			
			,'0'
			,'Error: USI is Invalid'
			,@ImportDate
			,@JobId
			 FROM #TempFrequenterPanUSI HT WHERE IsValidUSI=0
		UNION
		    SELECT DISTINCT @CountryCode
			,@ImportType
			,@FileName
			,NULL
			,'Frequency'			
			,'0'
			,'Error: Frequency is Invalid'
			,@ImportDate
			,@JobId
			 FROM #TempFrequenterPanUSI HT WHERE IsValidFrequency=0

		IF @@ROWCOUNT > 0
			SET @IsErrorOccured = 1
		
		IF EXISTS(  SELECT 1 FROM
						#TempFrequenterPanUSI T INNER JOIN FRS.FREQUENTER_PAN_USI F ON T.household_number = F.idfoyer 
						AND T.Individual = F.pan_no_individu AND (T.USI = F.usi_code OR T.[Frequency] =F.freq_no_ordre)
				)
		BEGIN
			PRINT 'Error: Duplicate Frequenter Pan USI';
			INSERT INTO [dbo].[FileImportErrorLog] (
			CountryCode
			,ImportType
			,[FileName]
			,PanelCode
			,ErrorSource
			,ErrorCode
			,ErrorDescription
			,ErrorDate
			,JobId
			)
			SELECT DISTINCT @CountryCode
			,@ImportType
			,@FileName
			,NULL
			,'HHNO'			
			,'0'
			,'Error: Duplicate Frequenter Pan USI'
			,@ImportDate
			,@JobId
			 FROM #TempFrequenterPanUSI T INNER JOIN FRS.FREQUENTER_PAN_USI F ON T.household_number = F.idfoyer 
						AND T.Individual = F.pan_no_individu AND (T.USI = F.usi_code OR T.[Frequency] =F.freq_no_ordre	)
		END

		IF @@ROWCOUNT > 0
			SET @IsErrorOccured = 1

		IF EXISTS(  SELECT * FROM
				#TempFrequenterPanUSI
				GROUP BY household_number,Individual,USI
				HAVING COUNT(0)>1
				)
	BEGIN
		PRINT 'Error: Duplicate Frequenter Pan USI'
		INSERT INTO [dbo].[FileImportErrorLog] (
			CountryCode
			,ImportType
			,[FileName]
			,PanelCode
			,ErrorSource
			,ErrorCode
			,ErrorDescription
			,ErrorDate
			,JobId
			)
			SELECT DISTINCT @CountryCode
			,@ImportType
			,@FileName
			,NULL
			,'HHNO'			
			,'0'
			,'Error: Duplicate Frequenter Pan USI'
			,@ImportDate
			,@JobId
			 FROM #TempFrequenterPanUSI HT 
			 GROUP BY household_number,Individual,USI
						HAVING COUNT(0)>1
					;WITH TEMP AS (
						SELECT household_number,Individual,USI FROM
						#TempFrequenterPanUSI
						GROUP BY household_number,Individual,USI
						HAVING COUNT(0)>1
						)

			UPDATE T1 SET IsValidIndividual=0,IsValidhousehold_number=0,IsValidUSI=0
			FROM #TempFrequenterPanUSI T1
			JOIN TEMP T2 ON T1.household_number=T2.household_number AND T1.Individual=T2.Individual AND T1.USI=T2.USI
	END

	IF @@ROWCOUNT > 0
		SET @IsErrorOccured = 1

	IF (@IsErrorOccured = 0)
	BEGIN
		UPDATE SourceT SET IsValidFrequency=0
			FROM (
				SELECT *,ROW_NUMBER() OVER(PARTITION BY CAST(household_number AS INT) ,Individual ORDER BY freq_no_ordre ASC) AS SNO FROM (
				SELECT distinct T2.household_number,T2.Individual,
					  T2.[Frequency]
						AS freq_no_ordre
					   FROM #TempFrequenterPanUSI T2
					   WHERE ISNULL(IsValidhousehold_number,1)<>0 AND ISNULL(IsValidIndividual,1)<>0 AND ISNULL(IsValidUSI,1)<>0 AND ISNULL(IsValidBusinessId,1)<>0 
					   AND ISNULL(IsValidFrequency,1)<>0

				UNION ALL
					
					SELECT distinct T2.household_number,T2.Individual,--T2.USI,
						T1.freq_no_ordre AS freq_no_ordre
					   FROM #TempFrequenterPanUSI T2
					   INNER JOIN frs.frequenter_pan_usi T1 ON T1.idfoyer=T2.household_number AND T1.pan_no_individu=T2.Individual --AND T1.USI_CODE =  T2.USI
					   WHERE ISNULL(IsValidhousehold_number,1)<>0 AND ISNULL(IsValidIndividual,1)<>0 AND ISNULL(IsValidUSI,1)<>0 AND ISNULL(IsValidBusinessId,1)<>0 
					   AND ISNULL(IsValidFrequency,1)<>0
			   ) TT 
			) result 
			JOIN #TempFrequenterPanUSI SourceT 
			ON SourceT.household_number=result.household_number AND SourceT.Individual=result.Individual --AND SourceT.USI=result.USI
			WHERE SNO<>freq_no_ordre
		IF @@ROWCOUNT > 0
		BEGIN
			SET @IsErrorOccured = 1
		END

			INSERT INTO [dbo].[FileImportErrorLog] (
				CountryCode
				,ImportType
				,[FileName]
				,PanelCode
				,ErrorSource
				,ErrorCode
				,ErrorDescription
				,ErrorDate
				,JobId
				)
				SELECT DISTINCT @CountryCode
				,@ImportType
				,@FileName
				,NULL
				,'HHNO'			
				,'0'
				,'Error: Invalid Frequenct'
				,@ImportDate
				,@JobId
				FROM #TempFrequenterPanUSI HT WHERE IsValidFrequency=0
	END

	END TRY
	BEGIN CATCH
		PRINT 'VALIDATION ERRROR OCCURED:'
		INSERT INTO [dbo].[FileImportErrorLog] (
			CountryCode
			,ImportType
			,[FileName]
			,PanelCode
			,ErrorSource
			,ErrorCode
			,ErrorDescription
			,ErrorDate
			,JobId
			)
		SELECT @CountryCode
			,@ImportType
			,@FileName
			,NULL
			,'Unknown'
			,ERROR_NUMBER()
			,ERROR_MESSAGE()
			,@ImportDate
			,@JobId

		PRINT ERROR_MESSAGE();

		UPDATE [FileImportAuditSummary]
			SET [Status] = 'Error'
			,Comments = N'' + ERROR_MESSAGE()
			,PassedRows = @InsertedRows
		WHERE AuditId = @AuditId

		IF @@ROWCOUNT > 0
			SET @IsErrorOccured = 1
	END CATCH

	---------------------------------------------------------------------------------
								-- PERFORM ACTUAL LOGIC
	---------------------------------------------------------------------------------
	IF @IsErrorOccured = 0 --  NO ISSUES WITH DATA
	BEGIN
		BEGIN TRY
			PRINT 'PROCESS STARTED'
			-- Create new data
			INSERT INTO frs.frequenter_pan_usi
				(
				idfoyer,
				pan_no_individu,
				usi_code,
				freq_no_ordre,
				freq_dt_update,
				GPSUser,
				GPSUpdateTimestamp,
				CreationTimeStamp
				)
			SELECT 
				[household_number],
				[Individual],
				USI,
				[Frequency],
				[Update],
				@GPSUser,
				@GetDate
				,@GetDate 
			FROM dbo.TempFrequenterPanUSI AS TEMP where jobid=@JobID

			SET @InsertedRows = @@ROWCOUNT
			PRINT '@InsertedRows : ' + convert(VARCHAR(10), @InsertedRows)

			UPDATE [FileImportAuditSummary]
				SET [Status] = 'Completed'
				,PassedRows = @InsertedRows
			WHERE AuditId = @AuditId
		END TRY
		BEGIN CATCH
			PRINT 'CRITICAL ERROR OCCURED'
			INSERT INTO [dbo].[FileImportErrorLog] (
				CountryCode
				,ImportType
				,[FileName]
				,PanelCode
				,ErrorSource
				,ErrorCode
				,ErrorDescription
				,ErrorDate
				,JobId
				)
			SELECT @CountryCode
				,@ImportType
				,@FileName
				,NULL
				,'Unknown'
				,ERROR_NUMBER()
				,ERROR_MESSAGE()
				,@ImportDate
				,@JobId
				PRINT ERROR_MESSAGE();
			UPDATE [FileImportAuditSummary]
				SET [Status] = 'Error'
				,Comments = substring(N'' + ERROR_MESSAGE(), 1, 400)
				,PassedRows = @InsertedRows
			WHERE AuditId = @AuditId
		END CATCH
	END
	ELSE
	BEGIN
		UPDATE [FileImportAuditSummary]
			SET [Status] = 'Error'
			,Comments = 'Input file has invalid data.'
			,PassedRows = 0
		WHERE AuditId = @AuditId
	END
	SET @InsertedRows = ISNULL(@InsertedRows,0)
	DROP TABLE #TempFrequenterPanUSI
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
