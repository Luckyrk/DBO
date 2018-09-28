CREATE PROCEDURE KeysettingGridFilter_AdminScreen
(
@psearchText VARCHAR(100), 
@pcountrycode VARCHAR(10),
@pSortCol VARCHAR(20) = '',
@pPage INT = 1,
@pRecsPerPage INT = 10
)
As
Begin
BEGIN TRY 
Declare @key As table
(
keyname nvarchar(1000),
value nvarchar (512),
DefaultValue NVARCHAR(500)
)
insert into @key select k.keyname,k.DefaultValue,kv.value from keyAppsetting k 
						join keyvalueappsetting kv on k.Guidreference=kv.keyAppsetting_Id
                     JOIN COUNTRY C ON C.CountryId =kv.Country_Id 
					 WHERE C.CountryISO2A=@pcountrycode 
					 and k.KeyName LIKE '%'+@psearchText+'%'
					 OR kv.Value LIKE '%'+@psearchText+'%'
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
		,DefaultValue
	FROM @key
	)
	Select  keyname as Keyname
		,value as Value
		,DefaultValue as DefaultValue
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