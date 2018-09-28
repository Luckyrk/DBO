CREATE PROCEDURE InsertImportAudit @pError VARCHAR(1000)
	,@pUser VARCHAR(100)
	,@pFileId UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON

	BEGIN TRY
		DECLARE @t TABLE (
			FileId UNIQUEIDENTIFIER
			,ErrorMessage VARCHAR(8000)
			)

		INSERT @t
		VALUES (
			@pFileId
			,@pError
			)

		DECLARE @GetDate DATETIME

		SET @GetDate = (
				SELECT dbo.GetLocalDateTimeByCountryId(GETDATE(), Country_Id)
				FROM ImportFile
				WHERE GUIDReference = @pFileId
				)

		INSERT INTO ImportAudit
		SELECT NEWID()
		,1
		,1
		,LTRIM(RTRIM(m.n.value('.[1]', 'varchar(8000)'))) AS ErrorMessage
		,@GetDate
		,NULL
		,NULL
		,NULL
		,@pUser
		,@GetDate
			,FileId
		FROM (
			SELECT FileId
				,CAST('<XMLRoot><RowData>' + REPLACE(LEFT(ErrorMessage, LEN(ErrorMessage) - 1), '&', '</RowData><RowData>') + '</RowData></XMLRoot>' AS XML) AS x
			FROM @t
			) t
		CROSS APPLY x.nodes('/XMLRoot/RowData') m(n)
	END TRY

	BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(4000);
		DECLARE @ErrorSeverity INT;
		DECLARE @ErrorState INT;

		SELECT @ErrorMessage = ERROR_MESSAGE()
			,@ErrorSeverity = ERROR_SEVERITY()
			,@ErrorState = ERROR_STATE();

		RAISERROR (
				@ErrorMessage
				,-- Message text.
				@ErrorSeverity
				,-- Severity.
				@ErrorState -- State.
				);
	END CATCH
END