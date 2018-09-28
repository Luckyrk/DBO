
CREATE PROCEDURE ProductReasonsmanagement_AdminScreen (
	@pcountrycode VARCHAR(2)
	,@psearchText NVARCHAR(50)
	,@pSortCol VARCHAR(20) = ''
	,@pPage INT = 1
	,@pRecsPerPage INT = 10
	)
AS
BEGIN
	BEGIN TRY
		IF (ISNULL(@psearchText, '') = '')
			SET @pSortCol = 'AnswerCode_Asc'

		DECLARE @Answer AS TABLE (
			answerCode NVARCHAR(10)
			,answerDescription NVARCHAR(300)
			,callAgain BIT
			,GPSUser NVARCHAR(100)
			,GPSUpdateTimeStamp DATETIME
			,CreationTimeStamp DATETIME
			)

		IF (LEN(@psearchText) != 0)
		BEGIN
			INSERT INTO @Answer
			SELECT DISTINCT LTRIM(RTRIM(a.AnswerCatCode)) AS answerCode
				,a.AnswerCatDescription AS answerDescription
				,a.callAgain AS CallAgain
				,a.GPSUser AS GPSUSer
				,a.GPSUpdateTimeStamp AS GPSUpdateTimeStamp
				,a.CreationTimeStamp AS CreationTimeStamp
			FROM DemandedProductCategoryAnswer a
			JOIN Country c ON c.CountryId = a.Country_Id
			WHERE c.CountryISO2A = @pcountrycode
				AND (
					a.AnswerCatCode LIKE '%' + @psearchText + '%'
					OR a.AnswerCatDescription LIKE '%' + @psearchText + '%'
					)
			ORDER BY answerCode
		END
		ELSE
			INSERT INTO @Answer
			SELECT DISTINCT LTRIM(RTRIM(a.AnswerCatCode)) AS answerCode
				,a.AnswerCatDescription AS answerDescription
				,a.callAgain AS CallAgain
				,a.GPSUser AS GPSUSer
				,a.GPSUpdateTimeStamp AS GPSUpdateTimeStamp
				,a.CreationTimeStamp AS CreationTimeStamp
			FROM DemandedProductCategoryAnswer a
			JOIN Country c ON c.CountryId = a.Country_Id
			WHERE c.CountryISO2A = @pcountrycode
			ORDER BY answerCode

		DECLARE @FirstRec INT
			,@LastRec INT

		SELECT @FirstRec = (@pPage - 1) * @pRecsPerPage

		SELECT @LastRec = (@pPage * @pRecsPerPage + 1)

		SELECT DISTINCT count(*) AS Total
		FROM @Answer;

		WITH CTE_Results
		AS (
			SELECT ROW_NUMBER() OVER (
					ORDER BY CASE 
							WHEN @pSortCol = 'AnswerCode_Asc'
								THEN CASE isnumeric(AnswerCode)
										WHEN 1
											THEN convert(INT, AnswerCode)
										ELSE 999999
										END
							END ASC
						,CASE 
							WHEN @pSortCol = 'AnswerCode_Desc'
								THEN CASE isnumeric(AnswerCode)
										WHEN 1
											THEN convert(INT, AnswerCode)
										ELSE 999999
										END
							END DESC
						,CASE 
							WHEN @psortCol = 'answerCatDescription_Asc'
								THEN answerDescription
							END ASC
						,CASE 
							WHEN @psortCol = 'answerCatDescription_Asc'
								THEN answerDescription
							END DESC
					) AS ROWNUM
				,answerCode
				,answerDescription
				,CallAgain
				,GPSUser
				,GPSUpdateTimeStamp
				,CreationTimeStamp
			FROM @Answer
			)
		SELECT DISTINCT ROWNUM
			,AnswerCode
			,answerDescription
			,CallAgain
			,GPSUser
			,GPSUpdateTimeStamp
			,CreationTimeStamp
		FROM CTE_Results
		WHERE ROWNUM > @FirstRec
			AND ROWNUM < @LastRec
		ORDER BY AnswerCode ASC
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
