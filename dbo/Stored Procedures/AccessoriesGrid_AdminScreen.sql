Create PROCEDURE [dbo].AccessoriesGrid_AdminScreen (
	@pCountryISO2A VARCHAR(10)
	,@psearchText VARCHAR(max)
	,@pSortCol VARCHAR(20) = ''
	,@pPage INT = 1
	,@pRecsPerPage INT = 20
	)
AS
BEGIN

BEGIN TRY
Declare @countryid uniqueidentifier = (select Top 1 CountryId from country where CountryISO2A=@pCountryISO2A)

DECLARE @Categorytable TABLE (
	Name varchar(50)
	,Quantity int
	,Code INT
	,KitName VARCHAR(50)
	,CategoryName nvarchar(50)
	,BehaviorName nvarchar(50)
	,GUIDReference uniqueidentifier
	)
IF(LEN(@psearchText)!=0)
BEGIN
INSERT INTO @Categorytable
select st.Name,ski.Quantity,st.Code ,sk.Name as KitName,TT.Value as CategoryName,sbtt.value as BehaviorName,st.GUIDReference
from StockKitItem ski
join StockKit sk on sk.GUIDReference=ski.StockKit_Id AND sk.Country_Id=@countryid
join StockType st on st.GUIDReference=ski.StockType_Id
join StockBehavior sb on st.Behavior_Id=sb.GUIDReference AND SB.Country_Id=@countryid
join StockCategory SC on SC.GUIDReference=st.Category_Id AND sc.Country_Id=@countryid
join translation T on SC.Translation_Id =T.TranslationId 
join TranslationTerm TT on TT.Translation_Id= T.TranslationId and tt.culturecode=2057
join translation sbT on sb.Translation_Id =sbT.TranslationId 
join TranslationTerm sbTT on sbTT.Translation_Id= sbT.TranslationId and sbtt.CultureCode=2057
join Country c on c.CountryId=ski.Country_Id

where c.CountryISO2A=@pCountryISO2A and TT.CultureCode=2057 and sc.Country_Id=@countryid and sb.Country_Id=@countryid and sk.Country_Id=@countryid
and st.Name like '%'+@psearchText+'%'
or ski.Quantity like '%'+@psearchText+'%'
or st.Code like '%'+@psearchText+'%'
or sk.Name like '%'+@psearchText+'%'
or TT.Value like '%'+@psearchText+'%' 
or sbtt.value like '%'+@psearchText+'%'  order by    cast(st.code as int) desc
END

ELSE
BEGIN
INSERT INTO @Categorytable
select st.Name,ski.Quantity,st.Code,sk.Name as KitName,TT.Value as CategoryName,sbtt.value as BehaviorName,st.GUIDReference
from StockKitItem ski
join StockKit sk on sk.GUIDReference=ski.StockKit_Id AND sk.Country_Id=@countryid
join StockType st on st.GUIDReference=ski.StockType_Id
join StockBehavior sb on st.Behavior_Id=sb.GUIDReference AND SB.Country_Id=@countryid
join StockCategory SC on SC.GUIDReference=st.Category_Id AND SC.Country_Id=@countryid
join translation T on SC.Translation_Id =T.TranslationId 
join TranslationTerm TT on TT.Translation_Id= T.TranslationId and tt.culturecode=2057
join translation sbT on sb.Translation_Id =sbT.TranslationId 
join TranslationTerm sbTT on sbTT.Translation_Id= sbT.TranslationId and sbtt.CultureCode=2057
join Country c on c.CountryId=ski.Country_Id

where c.CountryISO2A=@pCountryISO2A and TT.CultureCode=2057 and sc.Country_Id=@countryid and sb.Country_Id=@countryid and sk.Country_Id=@countryid order by    cast(st.code as int) desc

END



DECLARE @FirstRec INT
	,@LastRec INT

SELECT @FirstRec = (@pPage - 1) * @pRecsPerPage

SELECT @LastRec = (@pPage * @pRecsPerPage + 1)

SELECT count(*) AS TotalRecords
FROM @Categorytable
; WITH CTE_Results
AS (
	SELECT ROW_NUMBER() OVER (
			ORDER BY CASE 
					WHEN @pSortCol = 'Name_Asc'
						THEN Name
					END ASC
				,CASE 
					WHEN @pSortCol = 'Name_Desc'
						THEN Name
					END DESC
				,CASE 
					WHEN @pSortCol = 'Quantity_Asc'
						THEN Quantity
					END ASC
				,CASE 
					WHEN @pSortCol = 'Quantity_Desc'
						THEN Quantity
					END DESC
				,CASE 
					WHEN @pSortCol = 'Code_Asc'
						THEN Code
					END ASC
				,CASE 
					WHEN @pSortCol = 'Code_Desc'
						THEN Code
					END DESC
				,CASE 
					WHEN @pSortCol = 'KitName_Asc'
						THEN KitName
					END ASC
				,CASE 
					WHEN @pSortCol = 'KitName_Desc'
						THEN KitName
					END DESC
					,CASE 
					WHEN @pSortCol = 'CategoryName_Asc'
						THEN CategoryName
					END ASC
				,CASE 
					WHEN @pSortCol = 'CategoryName_Desc'
						THEN CategoryName
					END DESC
					,CASE 
					WHEN @pSortCol = 'BehaviorName_Asc'
						THEN BehaviorName
					END ASC
				,CASE 
					WHEN @pSortCol = 'BehaviorName_Desc'
						THEN BehaviorName
					END DESC
			) AS ROWNUM
		,Name
		,Quantity
		,Code
		,KitName
		,CategoryName
		,BehaviorName
		,GUIDReference
	FROM @Categorytable
	)
	SELECT Name
	,Quantity 
	,Code 
	,KitName
	,CategoryName
	,BehaviorName
	,GUIDReference
FROM CTE_Results
WHERE ROWNUM > @FirstRec
	AND ROWNUM < @LastRec
ORDER BY ROWNUM ASC,Code desc
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

