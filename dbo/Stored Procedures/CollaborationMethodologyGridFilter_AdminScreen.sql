﻿  create PROCEDURE CollaborationMethodologyGridFilter_AdminScreen
  (
  @psearchText VARCHAR(100),
  @pcountrycode VARCHAR(10),
  @pSortCol VARCHAR(20) = '',
@pPage INT = 1,
@pRecsPerPage INT = 10
  )
  AS
  BEGIN	
  BEGIN TRY 
  declare @Collaboration AS TABLE
  (
  code VARCHAR(10),
  Value VARCHAR(100)
  )
 INSERT INTO @Collaboration SELECT cm.code,tt.value FROM CollaborationMethodology cm join Translation t ON cm.TranslationId=t.TranslationId
join TranslationTerm tt ON t.TranslationId=tt.Translation_Id JOIN COUNTRY C ON C.CountryId =cm.Country_Id 
					                                             WHERE CultureCode=2057 and C.CountryISO2A=@pcountrycode  AND Code LIKE '%'+@psearchText+'%' AND Value LIKE '%'+@psearchText+'%'

  DECLARE @FirstRec INT
	   ,@LastRec INT
SELECT @FirstRec = (@pPage - 1) * @pRecsPerPage
SELECT @LastRec = (@pPage * @pRecsPerPage + 1)
SELECT count(*) AS Total
FROM @Collaboration
  

  ; WITH CTE_Results
AS (

	SELECT ROW_NUMBER() OVER (
			ORDER BY CASE 
					WHEN @pSortCol = 'code_Asc'
						THEN code
					END ASC
				,CASE 
					WHEN @pSortCol = 'code_Desc'
						THEN code
					END DESC
				,CASE
				    WHEN @psortCol = 'Value_Asc'
					     THEN Value
					END ASC
				,CASE
				    WHEN @psortCol = 'Value_Desc'
					     THEN Value
					END Desc
                
					   ) AS ROWNUM
		,code
		,Value
		
	FROM @Collaboration
	)
	Select  code,Value
		
			From CTE_Results
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