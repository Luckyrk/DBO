create PROCEDURE [dbo].[GetKitDetails_AdminScreen]

(                              

                @pCountrycode VARCHAR(10)
                           ,@pFilterText NVARCHAR(50)
                ,@pSortCol VARCHAR(20) = ''

                ,@pPage INT = 1

                ,@pRecsPerPage INT = 10

)

AS
BEGIN 
BEGIN TRY 

                DECLARE @KitDetailsTable TABLE (

                [GUIDReference] UNIQUEIDENTIFIER,

                [Code] INT,

                [Name] NVARCHAR(100),

                [IsActive] BIT

                )

IF(LEN(@pFilterText)!=0)
BEGIN
INSERT INTO @KitDetailsTable
       SELECT [GUIDReference],
                 [Code],
                 [Name],
                 [IsActive]    
       FROM [dbo].[StockKit] SK
       INNER JOIN [dbo].[Country] C ON C.CountryId = SK.Country_Id
       WHERE C.CountryISO2A = @pCountrycode
                AND  
                ([Code] LIKE '%' + @pFilterText + '%' OR [Name] LIKE '%' + @pFilterText + '%')
END
ELSE
BEGIN
     INSERT INTO @KitDetailsTable

                SELECT [GUIDReference],
                                           [Code],
                                                       [Name],
                                                       [IsActive]             
                FROM [dbo].[StockKit] SK
                INNER JOIN [dbo].[Country] C ON C.CountryId = SK.Country_Id
                WHERE C.CountryISO2A = @pCountrycode 
                           ORDER BY CODE DESC
END
               
               
                DECLARE @FirstRec INT,  @LastRec INT
                           SELECT @FirstRec = (@pPage - 1) * @pRecsPerPage
                           SELECT @LastRec = (@pPage * @pRecsPerPage + 1)
                           SELECT COUNT(*) AS TotalRecords
                                          FROM @KitDetailsTable; 
                                             WITH CTE_Results
                                    AS (  SELECT ROW_NUMBER() OVER (
                                                                    ORDER BY CASE 
                                                                                            WHEN @pSortCol = 'GUIDReference_Ascending'
                                                                                                 THEN GUIDReference
                                                                                                       END ASC,
                                                                                                            CASE 
                                                                                                                   WHEN @pSortCol = 'GUIDReference_Descending'
                                                                                                                     THEN GUIDReference
                                                                                           END DESC,
                                                                                                 CASE 
                                                                                                                 WHEN @pSortCol = 'Code_Ascending'
                                                                                                                       THEN Code
                                                                                                        END ASC,

                                                                CASE 

                                                                                WHEN @pSortCol = 'Code_Descending'

                                                                                THEN Code

                                                                END DESC,

                                                                CASE 

                                                                                WHEN @pSortCol = 'Name_Ascending'

                                                                                THEN Name

                                                                END ASC,

                                                                CASE 

                                                                                WHEN @pSortCol = 'Name_Descending'

                                                                                THEN Name

                                                                END DESC,

                                                                CASE 

                                                                                WHEN @pSortCol = 'IsActive_Ascending'

                                                                                THEN IsActive

                                                                END ASC,

                                                                CASE 

                                                                                WHEN @pSortCol = 'IsActive_Descending'

                                                                                THEN IsActive

                                                                END DESC

                                ) AS ROWNUM

                                                ,GUIDReference

                                                ,Code

                                                ,Name

                                                ,IsActive

                                FROM @KitDetailsTable

                )

                SELECT GUIDReference,

                                   Code,

                                   Name,

                                   IsActive

                FROM CTE_Results
                           WHERE ROWNUM > @FirstRec
       AND ROWNUM < @LastRec
ORDER BY ROWNUM  ASC
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


