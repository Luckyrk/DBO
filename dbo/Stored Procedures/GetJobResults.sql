CREATE PROCEDURE [dbo].[GetJobResults]
(
       @pJobId BIGINT,
	   @pKey varchar(100),
	   @pvalue varchar(200),
	   @pCountryCode Varchar(5),
	   @pIncentiveAccountType VARCHAR(100)
)
AS
BEGIN
	BEGIN TRY
       DECLARE @JobQuery VARCHAR(MAX) = '';

	   DECLARE @GetDate DATETIME
		SET @GetDate = (select dbo.GetLocalDateTime(GETDATE(),@pCountryCode))

       SELECT @JobQuery =  SBR.SqlCommand FROM SqlBusinessRule SBR 
			JOIN SqlJob SJ ON SBR.Id = SJ.Id
			WHERE SJ.Id = @pJobId

		--SET @JobQuery = 'SELECT ''2''+RIGHT(''000000''+CAST(a.GroupId AS varchar),6) AS u_account,Amount as  points_adjust,
		--      Comments as points_reason 
		--	  FROM [FullIndividualRedemptions] a
		--	  INNER JOIN [FullGroupAttributesAsRows] b
		--	        on b.CountryISO2A = a.CountryISO2A
		--			and b.GroupId = a.GroupId
		--			and b.[Key] = ''Alta_web''
		--			and b.Value = ''1''
		--			WHERE a.CountryISO2A = ''ES'' AND a.SynchronisationDate is null';
		IF OBJECT_ID('tempdb..##JobResults') IS NOT NULL
		BEGIN
			DROP TABLE ##JobResults
		END

		IF OBJECT_ID('tempdb..##IncentiveResults') IS NOT NULL
		BEGIN
			DROP TABLE ##IncentiveResults
		END
		DECLARE @JobExecute VARCHAR(MAX) = '';
		SET @JobExecute = 'SELECT * INTO ##JobResults FROM (' + @JobQuery + ') Temp';
		
		EXECUTE(@JobExecute); 		
		
		DECLARE @JobResultCount BIGINT = 0;
		DECLARE @ResultCount BIGINT = 0;

		SELECT IncentiveAccountTransactionId,I.IndividualId,c.Sequence,ba.CountryISO2A,iat.[Type] INTO ##IncentiveResults FROM IncentiveAccountTransaction iat
			JOIN Individual i on i.GUIDReference=iat.Account_Id 
			JOIN CollectiveMembership cm on cm.Individual_Id=i.GUIDReference
			JOIN Collective c on c.GUIDReference=cm.Group_Id
			JOIN IncentiveAccountTransactionInfo iatf on iatf.IncentiveAccountTransactionInfoId=iat.TransactionInfo_Id
			JOIN country ct on ct.CountryId=c.CountryId
			JOIN IncentivePoint ip on ip.GUIDReference=iatf.Point_Id
			JOIN FullIndividualAttributesAsRows ba on ba.IndividualId=i.IndividualId
			AND ba.CountryISO2A = ct.CountryISO2A					
			AND ba.[Key] = @pKey
			AND ba.Value = @pvalue
			WHERE ct.CountryISO2A = @pCountryCode AND iat.SynchronisationDate is null and iat.[Type] = @pIncentiveAccountType

		SELECT @JobResultCount = COUNT(1) FROM ##JobResults;
		SELECT @ResultCount = COUNT(1) FROM ##IncentiveResults

		--IF @JobResultCount = @ResultCount
		--BEGIN
			SELECT 1

			DECLARE @TodaDate AS DATETIME = @GetDate

			--SELECT TMP.* FROM IncentiveAccountTransaction IAT INNER JOIN ##IncentiveResults TMP ON IAT.IncentiveAccountTransactionId  = TMP.IncentiveAccountTransactionId
			UPDATE IAT SET IAT.SynchronisationDate = @TodaDate FROM
			IncentiveAccountTransaction IAT INNER JOIN ##IncentiveResults TMP ON IAT.IncentiveAccountTransactionId  = TMP.IncentiveAccountTransactionId

			SELECT  u_account,points_adjust,points_reason FROM ##JobResults

			SELECT ISNULL(Value,KS.DefaultValue) FROM KeyAppSetting KS LEFT JOIN KeyValueAppSetting KVS ON KS.GUIDReference = KVS.KeyAppSetting_Id WHERE KS.KeyName ='FetchaGPReportPath'

		--END
		--ELSE
		--BEGIN
		--	SELECT -1;

		--	SELECT IndividualId,Sequence,CountryISO2A,[Type],'Synchronizationdate was not Updated' FROM ##IncentiveResults

		--	SELECT ISNULL(Value,KS.DefaultValue) FROM KeyAppSetting KS LEFT JOIN KeyValueAppSetting KVS ON KS.GUIDReference = KVS.KeyAppSetting_Id WHERE KS.KeyName ='FetchaGPErrorPath'
		--END

		END TRY

		BEGIN CATCH
			DECLARE @ErrorNumber INT = ERROR_NUMBER();
			DECLARE @ErrorLine INT = ERROR_LINE();
			DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
			DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
			DECLARE @ErrorState INT = ERROR_STATE();
			IF OBJECT_ID('tempdb..##JobResults') IS NOT NULL
			BEGIN
				DROP TABLE ##JobResults
			END

			IF OBJECT_ID('tempdb..##IncentiveResults') IS NOT NULL
			BEGIN
				DROP TABLE ##IncentiveResults
			END

			RAISERROR (
					@ErrorMessage
					,@ErrorSeverity
					,@ErrorState
					);
		END CATCH

		IF OBJECT_ID('tempdb..##JobResults') IS NOT NULL
		BEGIN
			DROP TABLE ##JobResults
		END

		IF OBJECT_ID('tempdb..##IncentiveResults') IS NOT NULL
		BEGIN
			DROP TABLE ##IncentiveResults
		END

END
GO