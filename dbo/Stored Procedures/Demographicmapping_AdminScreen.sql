go 

CREATE PROCEDURE Demographicmapping_adminscreen 
(
	@pcountrycode NVARCHAR(10), 
    @psearchText  NVARCHAR(100), 
    @pSortCol     NVARCHAR(20) = '' , 
    @pPage        INT = 1, 
    @pRecsPerPage INT = 10) 
AS 
  BEGIN 
  BEGIN TRY
      DECLARE @DemoMapping AS TABLE 
        ( 
           sourcefield        NVARCHAR(512), 
           [description]      NVARCHAR(512), 
           localdescription NVARCHAR(512), 
           gpsentity          NVARCHAR(512), 
           attributekey       NVARCHAR(2000), 
           datatype           NVARCHAR(512), 
           isdemographic      INT, 
           demographictype    NVARCHAR(512), 
           calculation        NVARCHAR(2000), 
           panel              NVARCHAR(512), 
           person             INT 
        ) 

      IF( Len(@psearchText) != 0 ) 
        BEGIN 
            INSERT INTO @DemoMapping 
            SELECT sourcefield, 
                   [description], 
                   localdescription, 
                   gpsentity, 
                   attributekey, 
                   datatype, 
                   isdemographic, 
                   demographictype, 
                   calculation, 
                   panel, 
                   person 
            FROM   [QBI].[demographicmappingtable] 
            WHERE  countrycode = @pcountrycode 
                   AND sourcefield LIKE '%' + @psearchText + '%' 
                    OR attributekey LIKE '%' + @psearchText + '%' 
                    OR [description] LIKE '%' + @psearchText + '%' 
                    OR localdescription LIKE '%' + @psearchText + '%' 
                    OR gpsentity LIKE '%' + @psearchText + '%' 
                    OR datatype LIKE '%' + @psearchText + '%' 
                    OR isdemographic LIKE '%' + @psearchText + '%' 
                    OR demographictype LIKE'%' + @psearchText + '%' 
                    OR calculation LIKE '%' + @psearchText + '%' 
                    OR panel LIKE '%' + @psearchText + '%' 
                    OR person LIKE '%' + @psearchText + '%' 
        END 
      ELSE 
        INSERT INTO @DemoMapping 
        SELECT sourcefield, 
               [description], 
               localdescription, 
               gpsentity, 
               attributekey, 
               datatype, 
               isdemographic, 
               demographictype, 
               calculation, 
               panel, 
               person 
        FROM   [QBI].[demographicmappingtable] 
        WHERE  countrycode = @pcountrycode 

      DECLARE @FirstRec INT, 
              @LastRec  INT 

      SELECT @FirstRec = ( @pPage - 1 ) * @pRecsPerPage 

      SELECT @LastRec = ( @pPage * @pRecsPerPage + 1 ) 

      IF( Isnull(@pSortCol, '') = '' ) 
        BEGIN 
            SET @pSortCol='SourceField_Asc' 
        END 

      SELECT Count(*) AS Total 
      FROM   @DemoMapping; 

      WITH cte_results 
           AS (SELECT Row_number() 
                        OVER ( 
                          ORDER BY 
							CASE WHEN @pSortCol = 'SourceField_Asc' THEN sourcefield END ASC, 
							CASE WHEN @pSortCol = 'SourceField_Desc' THEN sourcefield END DESC, 
							CASE WHEN @pSortCol = 'Description_Asc' THEN [description] END ASC, 
							CASE WHEN @psortCol = 'Description_Desc' THEN [description] END DESC,
							CASE WHEN @psortCol = 'localdescription_ASC' THEN localdescription END ASC, 
							CASE WHEN @psortCol = 'localdescription_Desc' THEN localdescription END DESC, 
							CASE WHEN @psortCol = 'GPSEntity_ASC' THEN gpsentity END ASC,
							CASE WHEN @psortCol = 'GPSEntity_DESC' THEN gpsentity END DESC, 
							CASE WHEN @psortCol = 'AttributeKey_ASC' THEN attributekey END ASC,
							CASE WHEN @psortCol = 'AttributeKey_Desc' THEN attributekey END DESC, 
							CASE WHEN @psortCol = 'DataType_ASC' THEN datatype END ASC, 
							CASE WHEN @psortCol = 'DataType_DESC' THEN datatype END DESC,
							CASE WHEN @psortCol = 'IsDemographic_Asc' THEN isdemographic END ASC,
							CASE WHEN @psortCol = 'IsDemographic_Desc' THEN isdemographic END DESC, 
							CASE WHEN @psortCol = 'DemographicType_ASC' THEN demographictype END ASC,
							CASE WHEN @psortCol = 'DemographicType_DESC' THEN demographictype END DESC,
							CASE WHEN @psortCol = 'Calculation_ASC' THEN calculation END ASC, 
							CASE WHEN @psortCol = 'Calculation_Desc' THEN calculation END DESC, 
							CASE WHEN @psortCol = 'panel_Asc' THEN panel END ASC , 
							CASE WHEN @psortCol= 'panel_DESC' THEN panel END DESC, 
							CASE WHEN @psortCol= 'person_Asc' THEN person END ASC, 
							CASE WHEN @psortCol= 'person_DESC' THEN person END DESC ) 
                      AS ROWNUM, 
                      sourcefield, 
                      [description], 
                      localdescription, 
                      gpsentity, 
                      attributekey, 
                      datatype, 
                      isdemographic, 
                      demographictype, 
                      calculation, 
                      panel, 
                      person 
               FROM   @DemoMapping) 
				  SELECT sourcefield, 
						 [description], 
						 localdescription, 
						 gpsentity, 
						 attributekey, 
						 datatype, 
						 isdemographic, 
						 demographictype, 
						 calculation, 
						 panel, 
						 person 
				  FROM   cte_results 
				  WHERE  rownum > @FirstRec 
						 AND rownum < @LastRec 
				  ORDER  BY rownum ASC 
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

GO 