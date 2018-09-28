
CREATE PROCEDURE Keysetting_AdminScreen
(
@pcountrycode VARCHAR(10),
@psearchText VARCHAR(200),
@pSortCol VARCHAR(20) = '',
@pPage INT = 1,
@pRecsPerPage INT = 10
)
AS
BEGIN
BEGIN TRY 
DECLARE @key AS TABLE
(
keyname NVARCHAR(1000),
value NVARCHAR (512)
)
IF(LEN(@psearchText)!=0)
       BEGIN

INSERT INTO @key SELECT k.keyname,kv.value FROM keyAppsetting k 
				JOIN keyvalueappsetting kv ON k.Guidreference=kv.keyAppsetting_Id
                JOIN COUNTRY C ON C.CountryId =kv.Country_Id 
				WHERE C.CountryISO2A=@pcountrycode 
				AND (k.KeyName LIKE '%'+@psearchText+'%'
				OR kv.Value LIKE '%'+@psearchText+'%')
		END
ELSE
BEGIN
INSERT INTO @key SELECT k.keyname,kv.value FROM keyAppsetting k join keyvalueappsetting kv ON k.Guidreference=kv.keyAppsetting_Id
                                                                JOIN COUNTRY C ON C.CountryId =kv.Country_Id 
					                                             WHERE C.CountryISO2A=@pcountrycode
END
DECLARE @FirstRec INT
	   ,@LastRec INT
SELECT @FirstRec = (@pPage - 1) * @pRecsPerPage
SELECT @LastRec = (@pPage * @pRecsPerPage + 1)
SELECT count(*) AS TotalAppsettings
FROM @key
; WITH CTE_Results
AS (

	SELECT ROW_NUMBER() OVER (
			ORDER BY CASE 
					WHEN @pSortCol = 'keyname_Asc'
						THEN keyname
					END ASC
				,CASE 
					WHEN @pSortCol = 'keyname_Desc'
						THEN keyname
					END DESC
				,CASE 
				    WHEN @psortCol = 'value_ASC'
					     THEN value
					END ASC
				,CASE
				    WHEN @psortCol = 'value_DESC'
					      THEN value
                    END DESC
			         ) AS ROWNUM
		,Keyname
		,value
		
	FROM @key
	)
	Select  keyname
		,value
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


