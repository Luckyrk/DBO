 CREATE PROCEDURE KitManagmentGridFilter_AdminScreen
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
  DECLARE @Kit AS TABLE
  (
  Reasoncode INT,
  Ordercode INT,
  reasondescription VARCHAR(100),
  ordertype VARCHAR(100)
  )
  INSERT INTO @Kit SELECT ro.Code AS reasoncode,ot.Code AS ordercode,tt.Value AS reasondescription,ordertranslation.Value AS ordertype FROM ReasonForOrderType ro
join OrderType ot ON ot.Id=ro.OrderType_Id
join Country c ON c.CountryId=ot.Country_Id
join TranslationTerm tt ON tt.Translation_Id=ro.Description_Id and tt.CultureCode=2057
join TranslationTerm ordertranslation ON ordertranslation.Translation_Id=ot.Description_Id and tt.CultureCode=2057
WHERE c.CountryISO2A=@pcountrycode AND tt.Value LIKE '%'+@psearchText+'%'

  DECLARE @FirstRec INT
	   ,@LastRec INT
SELECT @FirstRec = (@pPage - 1) * @pRecsPerPage
SELECT @LastRec = (@pPage * @pRecsPerPage + 1)
SELECT count(*) AS Total
FROM @Kit
  

  ; WITH CTE_Results
AS (

	SELECT ROW_NUMBER() OVER (
			ORDER BY CASE 
					WHEN @pSortCol = 'Reasoncode_Asc'
						THEN Reasoncode
					END ASC
				,CASE 
					WHEN @pSortCol = 'Reasoncode_Desc'
						THEN Reasoncode
					END DESC
				,CASE
				    WHEN @psortCol = 'Ordercode_Asc'
					     THEN Ordercode
					END ASC
				,CASE
				    WHEN @psortCol = 'Ordercode_Desc'
					     THEN Ordercode
					END DESC
                ,CASE
				    WHEN @psortCol = 'reasondescription_Asc'
					     THEN reasondescription
					END ASC
				,CASE
				    WHEN @psortCol = 'reasondescription_Desc'
					     THEN reasondescription
					END DESC
				,CASE
				    WHEN @psortCol = 'ordertype_Asc'
					     THEN ordertype
					END ASC
				,CASE
				    WHEN @psortCol = 'ordertype_Desc'
					     THEN ordertype
					END DESC
					   ) AS ROWNUM
		,Reasoncode
		,Ordercode
		,reasondescription
		,ordertype
		
	FROM @Kit
	)
	Select  Reasoncode,Ordercode
		,reasondescription,ordertype
			From CTE_Results
WHERE ROWNUM > @FirstRec
	AND ROWNUM < @LastRec
ORDER BY ROWNUM ASC
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