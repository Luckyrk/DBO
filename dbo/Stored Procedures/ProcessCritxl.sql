CREATE PROCEDURE [dbo].[ProcessCritxl]
	@Year INT,
	@Period INT,
	@CountryId UNIQUEIDENTIFIER
AS
BEGIN
BEGIN TRY 
	SET NOCOUNT ON
	
	IF EXISTS (SELECT 1 FROM Critxl x WHERE x.[Year]=@Year AND x.Period=@Period AND x.Country_Id=@CountryId AND [Status] like 'Processing')
		RETURN

	UPDATE x SET [Status]='Processing'
	FROM Critxl x WHERE x.[Year]=@Year AND x.Period=@Period AND x.Country_Id=@CountryId

	DECLARE @CandidatesUnfiltered AS TABLE(GUIDReference UNIQUEIDENTIFIER);
	

	INSERT INTO @CandidatesUnfiltered
	SELECT DISTINCT f.GUIDReference
	FROM StateDefinitionHistory a 
	JOIN StateDefinition b ON a.To_Id = b.Id and b.Code = 'PanelistLiveState'
	JOIN Panelist e ON a.Panelist_Id = e.GUIDReference
	JOIN Candidate f ON e.PanelMember_Id = f.GUIDReference
	JOIN Panel g ON e.Panel_Id = g.GUIDReference
	JOIN Country ON Country.CountryId=f.Country_Id
	JOIN CalendarDenorm cals ON Country.CountryISO2A=cals.CountryISO2A AND YearPeriodValue=@Year  AND PeriodPeriodValue=@Period
	LEFT JOIN StateDefinitionHistory c ON a.Panelist_Id = c.Panelist_Id AND a.To_Id = c.From_Id AND a.GPSUpdateTimestamp = c.GPSUpdateTimestamp
	LEFT JOIN StateDefinition d ON c.To_Id = d.Id AND d.Code = 'PanelistDroppedOffState'
	LEFT JOIN ReasonForChangeState r ON c.ReasonForchangeState_Id = r.Id
	WHERE
		Country.CountryId=@CountryId AND
		g.PanelCode in (24,25,75) AND 
		(c.CreationDate IS NULL OR c.CreationDate > DATEADD(wk, DATEDIFF(wk,0,cals.PeriodStartDate) + 2, 0)) --Third monday of the period

	INSERT INTO @CandidatesUnfiltered
	SELECT Group_Id
	FROM CollectiveMembership cm
	JOIN StateDefinition sd ON cm.State_id=sd.Id AND sd.InactiveBehavior=0
	JOIN @CandidatesUnfiltered c ON cm.Individual_Id=c.GUIDReference

	DECLARE @Candidates AS TABLE(GUIDReference UNIQUEIDENTIFIER);
	INSERT INTO @Candidates
	SELECT DISTINCT GUIDReference FROM @CandidatesUnfiltered
	
	DECLARE @IndividualCount INT;
	DECLARE @GroupCount INT;

	SELECT @IndividualCount = COUNT(*) FROM @Candidates c JOIN Individual i on i.GUIDReference=c.GUIDReference
	SELECT @GroupCount = COUNT(*) FROM @Candidates c JOIN Collective i on i.GUIDReference=c.GUIDReference
	
	DELETE xlv
	FROM CritXLvalue xlv
	JOIN CritXL xl ON xl.[Year]=xlv.[Year] AND xl.Period=xlv.Period AND xl.Country_Id=@CountryId
	WHERE xlv.[Year]=@Year AND xlv.Period=@Period AND xl.Locked=0

	DECLARE @error BIT = 0;

	DECLARE @CId UNIQUEIDENTIFIER;
	WHILE EXISTS(SELECT 1 FROM @Candidates) AND @error=0
	BEGIN
		SELECT TOP 1 @CId = GUIDReference FROM @Candidates
		
		BEGIN TRY
			BEGIN TRANSACTION
				DELETE xlv
				FROM CritXLvalue xlv
				JOIN CritXL xl ON xl.[Year]=xlv.[Year] AND xl.Period=xlv.Period AND xl.Country_Id=@CountryId
				WHERE xlv.[Year]=@Year AND xlv.Period=@Period AND xl.Locked=0 AND xlv.Candidate_Id=@CId

		INSERT INTO CritXLvalue
		SELECT DISTINCT
					@Year, @Period, xl.AttributeKey, @CId, --av.Value
					(SELECT TOP 1 av.Value FROM Attribute a --ON xl.AttributeKey=a.[Key]
						JOIN AttributeValue av ON av.DemographicId=a.GUIDReference
						WHERE xl.AttributeKey=a.[Key] AND av.CandidateId=@CId ORDER BY av.GPSUpdateTimestamp DESC) AS Value
		FROM CritXL xl
				WHERE xl.Locked=0 AND xl.[Year]=@Year AND xl.Period=@Period
			COMMIT TRANSACTION
		END TRY
		BEGIN CATCH
			IF (XACT_STATE()) = -1	ROLLBACK TRANSACTION;
			IF (XACT_STATE()) = 1	COMMIT TRANSACTION;
			SET @error = 1;
		END CATCH;
		DELETE c FROM @Candidates c WHERE c.GUIDReference=@CId
	END
	
	--IF @error=1
	--	THROW 51000, 'An error has occured while inserting data.', 1;
	--ELSE
	IF @error=0
	BEGIN
		DECLARE @EmailBody NVARCHAR(MAX);
		SELECT @EmailBody = CONCAT('CritXL Data for Period [', @Year, '.', RIGHT(CONCAT('0', @Period), 2), '] for Country [', CountryIso2a, '] Processed Successfully.') FROM Country WHERE CountryId=@CountryId
		DECLARE @EmailSubject NVARCHAR(MAX) = @EmailBody
		SET @EmailBody = @EmailBody + CONCAT(' - Population: ', @IndividualCount, ' Individuals in ', @GroupCount, ' Households. If you need to reprocess the information, you can now do so.');

		DECLARE @Emails NVARCHAR(MAX)
		SELECT  @Emails = ISNULL(Value, kas.DefaultValue)
		FROM KeyAppSetting kas
		LEFT JOIN KeyValueAppSetting kv ON kv.KeyAppSetting_Id=kas.GUIDReference AND kv.Country_id=@CountryId
		WHERE kas.KeyName = 'FrenchShopProcessNotificationEmails'
	
		IF (@Emails IS NOT NULL)
			EXEC msdb.dbo.sp_send_dbmail
			@profile_name = 'SQLMAIL',
			@recipients = @Emails,
			@subject = @EmailSubject,
			@body = @EmailBody,
			@body_format= 'TEXT'

	END

	UPDATE x SET [Status]='Complete'
	FROM Critxl x WHERE x.[Year]=@Year AND x.Period=@Period AND x.Country_Id=@CountryId

	SET NOCOUNT OFF

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
