

 CREATE PROCEDURE QbMappingGridFilter_AdminScreen
  (
  @psearchText VARCHAR(100),
  @pSortCol VARCHAR(20) = '',
@pPage INT = 1,
@pRecsPerPage INT = 10
  )
  AS
  BEGIN
  BEGIN TRY 
  DECLARE @DemoMapping AS TABLE
  (
  sourcefield NVARCHAR(512),
  [description] NVARCHAR(512),
  localdescription NVARCHAR(512),
  GPSEntity NVARCHAR(512),
  Attributekey NVARCHAR(2000),
  datatype NVARCHAR(512),
  isdemographic INT,
  demographictype NVARCHAR(512),
  calculation NVARCHAR(2000),
  panel NVARCHAR(512),
  person INT
  )
  
INSERT INTO @DemoMapping SELECT sourcefield,[description],localdescription,GPSEntity,Attributekey,datatype,isdemographic,demographictype,calculation,panel,person FROM [QBI].[demographicmappingtable] WHERE sourcefield like '%'+@psearchText+'%' OR Attributekey like '%'+@psearchText+'%'


  DECLARE @FirstRec INT
	   ,@LastRec INT
SELECT @FirstRec = (@pPage - 1) * @pRecsPerPage
SELECT @LastRec = (@pPage * @pRecsPerPage + 1)
SELECT count(*) AS Total
FROM @DemoMapping
; WITH CTE_Results
AS (

	SELECT ROW_NUMBER() OVER (
			ORDER BY CASE 
					WHEN @pSortCol = 'SourceField_Asc'
						THEN SourceField
					END ASC
				,CASE 
					WHEN @pSortCol = 'SourceField_Desc'
						THEN SourceField
					END DESC
				,CASE
				    WHEN @pSortCol = 'Description_Asc'
					     THEN [Description]
                    END ASC
				,CASE
				    WHEN @psortCol = 'Description_Desc'
					     THEN [Description]
				    END DESC
				,CASE
				    WHEN @psortCol = 'localdescription_ASC'
					     THEN localdescription
					END ASC
				,CASE
				    WHEN @psortCol = 'localdescription_Desc'
					     THEN localdescription
					END DESC
				,CASE
				    WHEN @psortCol = 'GPSEntity_ASC'
					     THEN GPSEntity
					END ASC
				,CASE
				    WHEN @psortCol = 'GPSEntity_DESC'
					     THEN GPSEntity
					END DESC
				,CASE
				    WHEN @psortCol = 'AttributeKey_ASC'
					     THEN AttributeKey
					END ASC
				,CASE
				    WHEN @psortCol = 'AttributeKey_Desc'
					     THEN AttributeKey
					END DESC
				,CASE
				    WHEN @psortCol = 'DataType_ASC'
					     THEN DataType
					END ASC
				,CASE
				    WHEN @psortCol = 'DataType_DESC'
					     THEN DataType
					END DESC
				,CASE
				    WHEN @psortCol = 'IsDemographic_Asc'
					     THEN IsDemographic
					END ASC
				,CASE
				    WHEN @psortCol = 'IsDemographic_Desc'
					      THEN IsDemographic
					END DESC
				,CASE
				    WHEN @psortCol = 'DemographicType_ASC'
					      THEN DemographicType
					END ASC
				,CASE
				    WHEN @psortCol = 'DemographicType_DESC'
					      THEN DemographicType
					END DESC
				,CASE
				    WHEN @psortCol = 'Calculation_ASC'
					      THEN Calculation
					END ASC
				,CASE
				    WHEN @psortCol = 'Calculation_Desc'
					      THEN Calculation
					END DESC
				,CASE
				    WHEN @psortCol = 'panel_Asc'
					      THEN panel
					END ASC
				,CASE
				    WHEN @psortCol= 'panel_DESC'
					      THEN panel
					END DESC
				,CASE
				    WHEN @psortCol = 'person_Asc'
					      THEN person
					END ASC
				,CASE
				    WHEN @psortCol= 'person_DESC'
					      THEN person
					END DESC
				)AS ROWNUM
				,SourceField
				,[Description]
				,localdescription
				,GPSEntity
				,Attributekey
				,Datatype
				,isdemographic
				,DemographicType
				,Calculation
				,panel
				,person
			FROM @DemoMapping
			)
			SELECT  SourceField
				,[Description]
				,localdescription
				,GPSEntity
				,Attributekey
				,Datatype
				,isdemographic
				,DemographicType
				,Calculation
				,panel
				,person
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