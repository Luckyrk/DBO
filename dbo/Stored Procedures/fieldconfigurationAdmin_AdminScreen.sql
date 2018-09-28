  GO
  Create procedure fieldconfigurationAdmin_AdminScreen
  (
   @pcountrycode VARCHAR(10),
   @psearchText VARCHAR(20),
   @pSortCol VARCHAR(20) = '',
   @pPage INT = 1,
   @pRecsPerPage INT = 10
  )
  AS
  BEGIN
  BEGIN TRY 
  declare @fieldconfig AS table
  (
  [key] varchar(100),
  [Required] bit,
  Visible bit
  )  
       IF(LEN(@psearchText)!=0)
       BEGIN
	   INSERT INTO @fieldconfig SELECT Fc.[key],Fc.[required],Fc.visible FROM FieldConfiguration Fc join country c ON c.Configuration_Id=Fc.CountryConfiguration_Id WHERE CountryISO2A=@pCountrycode and [key] like '%'+@psearchText+'%' OR [Required] LIKE '%'+@psearchText+'%'
	   END
	ELSE
  INSERT INTO @fieldconfig SELECT Fc.[key],Fc.[required],Fc.visible FROM FieldConfiguration Fc join country c ON c.Configuration_Id=Fc.CountryConfiguration_Id WHERE CountryISO2A=@pCountrycode 

  DECLARE @FirstRec INT
	   ,@LastRec INT
SELECT @FirstRec = (@pPage - 1) * @pRecsPerPage
SELECT @LastRec = (@pPage * @pRecsPerPage + 1)
SELECT count(*) AS Total
FROM @fieldconfig
  

  ; WITH CTE_Results
AS (

	SELECT ROW_NUMBER() OVER (
			ORDER BY CASE 
					WHEN @pSortCol = 'key_Asc'
						THEN [key]
					END ASC
				,CASE 
					WHEN @pSortCol = 'key_Desc'
						THEN [key]
					END DESC
				,CASE
				    WHEN @psortCol = 'Required_Asc'
					     THEN [required]
					END ASC
				,CASE
				    WHEN @psortCol = 'Required_Desc'
					     THEN [required]
					END Desc
                ,CASE
				    When @psortCol = 'Visible_Asc'
					     THEN visible
					END Asc
				,CASE
				    WHEN @psortCol = 'Visible_Desc'
					     THEN Visible
					END Desc
					   ) AS ROWNUM
		,[key]
		,[Required]
		,Visible
		
	FROM @fieldconfig
	)
	Select  [key],[required]
		,visible
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
Go

