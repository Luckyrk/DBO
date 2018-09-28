CREATE PROCEDURE [dbo].[MessageSchemeGridFilter_AdminScreen] (
	@psearchText VARCHAR(10)
	,@pcountrycode VARCHAR(10)
	,@pSortCol VARCHAR(20) = ''
	,@pPage INT = 1
	,@pRecsPerPage INT = 10
	)
AS
BEGIN 
BEGIN TRY 
DECLARE @Categorytable TABLE (
	Id INT
	,Descriptions VARCHAR(50)
	,PanelName VARCHAR(50)
	)

INSERT INTO @Categorytable
select TMS.TemplateMessageSchemeId as Id ,TMS.Description as [Description],P.Name as PanelName from TemplateMessageScheme TMS
LEFT JOIN PanelTemplateMessageScheme PMS on PMS.TemplateMessageSchemeId=TMS.TemplateMessageSchemeId
LEFT JOIN Panel P ON P.GUIDReference = PMS.panel_Id
LEFT JOIN Country C ON C.CountryId = TMS.CountryId
WHERE C.CountryISO2A = @pcountrycode
AND TMS.TemplateMessageSchemeId LIKE '%'+@psearchText+'%'
OR TMS.[Description] LIKE '%'+@psearchText+'%'
OR P.Name LIKE '%'+@psearchText+'%'




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
					WHEN @pSortCol = 'ID_Asc'
						THEN ID
					END ASC
				,CASE 
					WHEN @pSortCol = 'ID_Desc'
						THEN ID
					END DESC
				,CASE 
					WHEN @pSortCol = 'Description_Asc'
						THEN Descriptions
					END ASC
				,CASE 
					WHEN @pSortCol = 'Description_Desc'
						THEN Descriptions
					END DESC
				,CASE 
					WHEN @pSortCol = 'PanelName_Desc'
						THEN PanelName
					END ASC
				,CASE 
					WHEN @pSortCol = 'PanelName_Desc'
						THEN PanelName
					END DESC
				
			) AS ROWNUM
		,ID
		,Descriptions
		,PanelName
	FROM @Categorytable
	)
SELECT ID
	,Descriptions AS [Description]
	,PanelName AS PanelName
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