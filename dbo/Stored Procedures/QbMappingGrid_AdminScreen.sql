 CREATE procedure QbMappingGrid_AdminScreen
  (  
@pcountrycode NVARCHAR(10),
@psearchText NVARCHAR(100),
@pSortCol NVARCHAR(20) = '',
@pPage INT = 1,
@pRecsPerPage INT = 10
  )
  AS
  Begin
  BEGIN TRY 
  declare @DemoMapping As table

  (

  sourcefield nvarchar(512),

  [description] nvarchar(512),

  localdescription nvarchar(512),



  GPSEntity nvarchar(512),



  Attributekey nvarchar(2000),



  datatype nvarchar(512),



  isdemographic int,



  demographictype nvarchar(512),



  calculation nvarchar(2000),



  panel nvarchar(512)







  )

IF(LEN(@psearchText)!=0)



BEGIN

Insert into @DemoMapping select sourcefield,[description],localdescription,GPSEntity,Attributekey,datatype,isdemographic,demographictype,calculation,panel
 from [QBI].[demographicmappingtable] where sourcefield like '%'+@psearchText+'%' 
OR Attributekey like '%'+@psearchText+'%' OR [description] like '%'+@psearchText+'%'

	                                          OR localdescription LIKE '%'+@psearchText+'%' OR GPSEntity LIKE '%'+@psearchText+'%' OR datatype LIKE '%'+@psearchText+'%' 

											  OR isdemographic LIKE '%'+@psearchText+'%' OR demographictype LIKE'%'+@psearchText+'%' OR calculation LIKE '%'+@psearchText+'%' OR panel LIKE '%'+@psearchText+'%'


END  

ELSE

Insert into @DemoMapping select sourcefield,[description],localdescription,GPSEntity,Attributekey,datatype,isdemographic,demographictype,calculation,panel from [QBI].[demographicmappingtable]











  DECLARE @FirstRec INT



	   ,@LastRec INT



SELECT @FirstRec = (@pPage - 1) * @pRecsPerPage



SELECT @LastRec = (@pPage * @pRecsPerPage + 1)

IF(ISNULL(@pSortCol,'')='')
BEGIN
SET @pSortCol='SourceField_Asc'
END

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



				    WHEN @psortCol = 'Localdescription_ASC'



					     THEN localdescription



					END ASC



				,CASE



				    WHEN @psortCol = 'Localdescription_Desc'



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



				



			from @DemoMapping



			)



			Select  SourceField



				,[Description]



				,localdescription



				,GPSEntity



				,Attributekey



				,Datatype



				,isdemographic



				,DemographicType



				,Calculation



				,panel



				



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




