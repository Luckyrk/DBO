create PROCEDURE [dbo].[AccessoriesGridFilter_AdminScreen] (
    @psearchText VARCHAR(max)
	,@pCountryISO2A VARCHAR(10)
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

INSERT INTO @Categorytable
select a.Name,a.Quantity,a.Code,a.KitName,a.CategoryName,b.BehaviorName,a.GUIDReference from  (select st.Name,ski.Quantity,st.Code,sk.Name as KitName,st.GUIDReference,TT.Value as CategoryName  from StockKitItem ski
join StockKit sk on sk.GUIDReference=ski.StockKit_Id
join Country c on c.CountryId=@countryid
join StockType st on st.GUIDReference=ski.StockType_Id
join StockCategory SC on SC.GUIDReference=st.Category_Id
join translation T on SC.Translation_Id =T.TranslationId 
join TranslationTerm TT on TT.Translation_Id= T.TranslationId
where c.CountryISO2A=@pCountryISO2A and TT.CultureCode=2057) a
 inner join 
 (select st.Name,ski.Quantity,st.Code,sk.Name as KitName,st.GUIDReference,TT.Value as BehaviorName  from StockKitItem ski
join StockKit sk on sk.GUIDReference=ski.StockKit_Id
join Country c on c.CountryId=@countryid
join StockType st on st.GUIDReference=ski.StockType_Id
join StockBehavior SB on SB.GUIDReference=st.Behavior_Id
join translation T on SB.Translation_Id =T.TranslationId 
join TranslationTerm TT on TT.Translation_Id= T.TranslationId
where c.CountryISO2A=@pCountryISO2A and TT.CultureCode=2057 )  b on a.GUIDReference=b.GUIDReference
where  a.Name like '%'+@psearchText+'%'
or a.Quantity like '%'+@psearchText+'%'
or a.Code like '%'+@psearchText+'%'
or a.KitName like '%'+@psearchText+'%'
or a.CategoryName like '%'+@psearchText+'%' 
or b.BehaviorName like '%'+@psearchText+'%' 




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