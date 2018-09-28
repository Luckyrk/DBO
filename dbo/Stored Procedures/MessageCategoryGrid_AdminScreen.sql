CREATE PROCEDURE [dbo].[MessageCategoryGrid_AdminScreen] (
	@pcountrycode VARCHAR(10)
	,@psearchText VARCHAR(10) 
	,@pSortCol VARCHAR(20) 
	,@pPage INT = 1
	,@pRecsPerPage INT = 10
	)
AS
BEGIN 
BEGIN TRY 
DECLARE @Categorytable TABLE (
	Id INT
	,Descriptions VARCHAR(50)
	)

	IF(LEN(@psearchText)!=0)
	BEGIN
		INSERT INTO @Categorytable
		SELECT TMC.TemplateMessageCategoryId AS Id,TMC.[Description] AS [Description]
		FROM TemplateMessageCategories TMC
		INNER JOIN COUNTRY C ON C.CountryId = TMC.CountryId
		WHERE C.CountryISO2A=@pcountrycode
		AND	(TMC.TemplateMessageCategoryId LIKE '%'+@psearchText+'%'
		OR TMC.[Description] LIKE '%'+@psearchText+'%')
	END
	ELSE
		BEGIN
			INSERT INTO @Categorytable
			SELECT TMC.TemplateMessageCategoryId AS Id
				,TMC.[Description] AS [Description]

			FROM TemplateMessageCategories TMC
			JOIN COUNTRY C ON C.CountryId = TMC.CountryId
			WHERE C.CountryISO2A=@pcountrycode
			ORDER BY TMC.TemplateMessageCategoryId DESC
		END


DECLARE @FirstRec INT
	,@LastRec INT

SELECT @FirstRec = (@pPage - 1) * @pRecsPerPage

SELECT @LastRec = (@pPage * @pRecsPerPage + 1)

SELECT count(*) AS TotalRecords
FROM @Categorytable
; WITH CTE_Results
AS (
	SELECT ROW_NUMBER() OVER (
			ORDER BY CASE 
					WHEN @pSortCol = 'IdAsc'
						THEN ID
					END ASC
				,CASE 
					WHEN @pSortCol = 'IdDesc'
						THEN ID
					END DESC
				,CASE 
					WHEN @pSortCol = 'DescriptionAsc'
						THEN Descriptions
					END ASC
				,CASE 
					WHEN @pSortCol = 'DescriptionAsc'
						THEN Descriptions
					END DESC
				
			) AS ROWNUM
		,ID
		,Descriptions
	FROM @Categorytable
	)
SELECT ID
	,Descriptions AS [Description]
FROM CTE_Results
WHERE ROWNUM > @FirstRec
	AND ROWNUM < @LastRec
ORDER BY ROWNUM ASC
END TRY 
BEGIN CATCH
		DECLARE @ErrorMsg NVARCHAR(4000);
		DECLARE @Severity INT;
		DECLARE @State INT;

		SELECT @ErrorMsg = ERROR_MESSAGE(),
			   @Severity = ERROR_SEVERITY(),
			   @State = ERROR_STATE();
	
		RAISERROR (@ErrorMsg, -- Message text.
				   @Severity, -- Severity.
				   @State -- State.
				   );
END CATCH
END