CREATE PROCEDURE RoleManagementGrid_AdminScreen(
	@psearchText VARCHAR(10) = ''
	,@pSortCol VARCHAR(20) 
	,@pPage INT = 1
	,@pRecsPerPage INT = 10
	)
AS
BEGIN
BEGIN TRY 
DECLARE @Categorytable TABLE (
	SystemRoleTypeId INT
	,Descriptions VARCHAR(50)
	)
	IF(LEN(@psearchText)!=0)
	BEGIN
		INSERT INTO @Categorytable
		SELECT SystemRoleTypeId,[Description] from systemroletype
		WHERE [Description] LIKE '%'+@psearchText+'%'
		OR [Description] LIKE '%'+@psearchText+'%'
	END
	ELSE
		BEGIN
			INSERT INTO @Categorytable
			SELECT SystemRoleTypeId,[Description] from systemroletype
			ORDER BY [Description] asc
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
						THEN SystemRoleTypeId
					END ASC
				,CASE 
					WHEN @pSortCol = 'IdDesc'
						THEN SystemRoleTypeId
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
		,SystemRoleTypeId
		,Descriptions
	FROM @Categorytable
	)
SELECT SystemRoleTypeId
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



