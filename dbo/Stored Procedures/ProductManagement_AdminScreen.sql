GO
Create PROCEDURE Productmanagement_AdminScreen (
	@pcountrycode VARCHAR(2)
	,@psearchText NVARCHAR(50)
	,@pSortCol VARCHAR(20) = ''
	,@pPage INT = 1
	,@pRecsPerPage INT = 10
	)
AS
BEGIN
	BEGIN TRY
		DECLARE @Product AS TABLE (
			ProductCode nvarchar(20)
			,productDescription NVARCHAR(300)
			,GPSUser NVARCHAR(100)
			,GPSUpdateTimeStamp DATETIME
			,CreationTimeStamp DATETIME
			)

		IF (LEN(@psearchText) != 0)
		BEGIN
			INSERT INTO @Product
			SELECT DISTINCT p.ProductCode AS productCode
				,p.productdescription AS productdescription
				,p.GPSUser AS GPSUSer
				,p.GPSUpdateTimeStamp AS GPSUpdateTimeStamp
				,P.CreationTimeStamp AS CreationTimeStamp
			FROM DemandedProductCategory p
			JOIN Country c ON c.CountryId = p.Country_Id
			WHERE c.CountryISO2A = @pcountrycode
				AND (
					p.ProductCode LIKE '%' + @psearchText + '%'
					OR p.productdescription LIKE '%' + @psearchText + '%'
					)
		END
		ELSE
			INSERT INTO @Product
			SELECT DISTINCT p.ProductCode AS productCode
				,p.productdescription AS productdescription
				,p.GPSUser AS GPSUSer
				,p.GPSUpdateTimeStamp AS GPSUpdateTimeStamp
				,P.CreationTimeStamp AS CreationTimeStamp
			FROM DemandedProductCategory p
			JOIN Country c ON c.CountryId = p.Country_Id
			WHERE c.CountryISO2A = @pcountrycode

		DECLARE @FirstRec INT
			,@LastRec INT

		SELECT @FirstRec = (@pPage - 1) * @pRecsPerPage

		SELECT @LastRec = (@pPage * @pRecsPerPage + 1)

		SELECT DISTINCT count(*) AS Total
		FROM @Product;

		WITH CTE_Results
		AS (
			SELECT ROW_NUMBER() OVER (
					ORDER BY CASE 
							WHEN @pSortCol = 'ProductCode_Asc'
								THEN ProductCode
							END ASC
						,CASE 
							WHEN @pSortCol = 'ProductCode_Desc'
								THEN ProductCode
							END DESC
						,CASE 
							WHEN @psortCol = 'productDescription_Asc'
								THEN productdescription
							END ASC
						,CASE 
							WHEN @psortCol = 'productDescription_Desc'
								THEN productdescription
							END DESC
					) AS ROWNUM
				,productCode
				,productDescription
				,GPSUser
				,GPSUpdateTimeStamp
				,CreationTimeStamp
			FROM @Product
			)
		SELECT DISTINCT ROWNUM
			,productCode
			,productDescription
			,GPSUser
			,GPSUpdateTimeStamp
			,CreationTimeStamp
		FROM CTE_Results
		WHERE ROWNUM > @FirstRec
			AND ROWNUM < @LastRec
		ORDER BY productCode ASC
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
