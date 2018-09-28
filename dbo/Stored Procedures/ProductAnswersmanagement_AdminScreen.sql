CREATE PROCEDURE [dbo].[ProductAnswersmanagement_AdminScreen] (  

 @pcountrycode VARCHAR(2)  

 ,@psearchText NVARCHAR(50)  

 ,@pSortCol VARCHAR(20) = ''  

 ,@pPage INT = 1  

 ,@pRecsPerPage INT = 10  

 )  

AS  

BEGIN  

 BEGIN TRY  

  DECLARE @Answer AS TABLE (  

   productCode NVARCHAR(10)  

   ,productDescription NVARCHAR(300)  

   ,answerCode NVARCHAR(10)  

   ,answerDescription NVARCHAR(300)  

   ,callAgain BIT  
   
   ,AskAgainInterval int  

   ,GPSUser NVARCHAR(100)  

   ,GPSUpdateTimeStamp DATETIME  

   ,CreationTimeStamp DATETIME  

   )  

  

  IF (LEN(@psearchText) != 0)  

  BEGIN  

 
   INSERT INTO @Answer  

   SELECT p.ProductCode  

    ,p.productCode+'-'+ p.productDescription AS productDescription  

    ,a.answercatcode  

    ,a.answercatCode+'-'+a.answerCatDescription AS answerDescription  

    ,mp.DonotCallAgain  
	,mp.AskAgainInterval  

    ,mp.GPSUser AS GPSUSer  

    ,mp.GPSUpdateTimeStamp AS GPSUpdateTimeStamp  

    ,mp.CreationTimeStamp AS CreationTimeStamp  

   FROM DemandedProductCategory P  

   INNER JOIN DemandedproductCategoryAnswermapping mp ON mp.DemandedProductCategory_ID = p.ID  

   INNER JOIN DemandedProductcategoryAnswer a ON mp.DemandedProductCategoryAnswer_ID = a.ID  

   JOIN Country c ON c.CountryId = a.Country_Id  

   WHERE c.CountryISO2A = @pcountrycode  

    AND (  

     p.productCode+'-'+ p.productDescription LIKE '%' + @psearchText + '%'  

     OR a.answercatCode+'-'+a.answerCatDescription LIKE '%' + @psearchText + '%'  

     )  

  END  

  ELSE  

   INSERT INTO @Answer  

   SELECT P.ProductCode  

    ,p.productCode+'-'+ p.productDescription AS productDescription  

    ,a.answercatcode  

    ,a.answercatCode+'-'+a.answerCatDescription AS answerDescription  

    ,mp.DonotCallAgain  
	,mp.AskAgainInterval  
    ,mp.GPSUser AS GPSUSer  

    ,mp.GPSUpdateTimeStamp AS GPSUpdateTimeStamp  

    ,mp.CreationTimeStamp AS CreationTimeStamp  

   FROM DemandedProductCategory P  

   INNER JOIN DemandedproductCategoryAnswermapping mp ON mp.DemandedProductCategory_ID = p.ID  

   INNER JOIN DemandedProductcategoryAnswer a ON mp.DemandedProductCategoryAnswer_ID = a.ID  

   JOIN Country c ON c.CountryId = a.Country_Id  

   WHERE c.CountryISO2A = @pcountrycode  

  

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

       WHEN @pSortCol = 'ProductDescription_Asc'  

        THEN productDescription  

       END ASC  

      ,CASE   

       WHEN @pSortCol = 'ProductDescription_Desc'  

        THEN productDescription  

       END DESC  

      ,CASE   

       WHEN @psortCol = 'answerCatDescription_Asc'  

        THEN answerDescription  

       END ASC  

      ,CASE   

       WHEN @psortCol = 'answerCatDescription_Desc'  

        THEN answerDescription  

       END DESC  

	   

     ) AS ROWNUM  

    ,productCode  

    ,productDescription  

    ,answerCode  

    ,answerDescription  

    ,CallAgain

	,AskAgainInterval

    ,GPSUser  

    ,GPSUpdateTimeStamp  

    ,CreationTimeStamp  

   FROM @Answer  

   )  

  SELECT DISTINCT ROWNUM  

   ,productCode  

   ,productDescription  

   ,answerCode  

   ,answerDescription  

   ,CallAgain  
   ,AskAgainInterval
   ,GPSUser  

   ,GPSUpdateTimeStamp  

   ,CreationTimeStamp  

  FROM CTE_Results  

  WHERE ROWNUM > @FirstRec  

   AND ROWNUM < @LastRec  

  ORDER BY   

  --ROWNUM  

   productCode ASC,answerCode ASC  

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
