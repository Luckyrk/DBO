CREATE PROCEDURE [dbo].[IndividualIdsGrid_AdminScreen] (
	@pCountryISO2A VARCHAR(10)
	,@pIndividualId nvarchar(max)
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
	BelongingType varchar(max)
	,BelongingCode int
	,IndividualId VARCHAR(max)
	)
IF(LEN(@psearchText)!=0)
BEGIN
INSERT INTO @Categorytable
SELECT dbo.GetTranslationValue(bt.Translation_Id,2057) as BelongingType,b.BelongingCode	,i.IndividualId
FROM Individual i
JOIN Belonging b ON i.GUIDReference=b.CandidateId
JOIN BelongingType bt on bt.Id = b.TypeId
join Country c on c.CountryId=@countryid
where i.INDIVIDUALID =  @pIndividualId and i.countryid=@countryid
and dbo.GetTranslationValue(bt.Translation_Id,2057) like '%'+@psearchText+'%'
or b.BelongingCode like '%'+@psearchText+'%'
or i.IndividualId like '%'+@psearchText+'%'
order by BelongingType,b.BelongingCode

END

ELSE
BEGIN

INSERT INTO @Categorytable
SELECT dbo.GetTranslationValue(bt.Translation_Id,2057) as BelongingType,b.BelongingCode	,i.IndividualId
FROM Individual i
JOIN Belonging b ON i.GUIDReference=b.CandidateId
JOIN BelongingType bt on bt.Id = b.TypeId
join Country c on c.CountryId=@countryid
where i.INDIVIDUALID =  @pIndividualId and i.countryid=@countryid
order by BelongingType,b.BelongingCode
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
					WHEN @pSortCol = 'BelongingType_Asc'
						THEN BelongingType
					END ASC
				,CASE 
					WHEN @pSortCol = 'BelongingType_Desc'
						THEN BelongingType
					END DESC
				,CASE 
					WHEN @pSortCol = 'BelongingCode_Asc'
						THEN BelongingCode
					END ASC
				,CASE 
					WHEN @pSortCol = 'BelongingCode_Desc'
						THEN BelongingCode
					END DESC
				,CASE 
					WHEN @pSortCol = 'IndividualId_Asc'
						THEN IndividualId
					END ASC
				,CASE 
					WHEN @pSortCol = 'IndividualId_Desc'
						THEN IndividualId
					END DESC
				
			) AS ROWNUM
		,BelongingType
		,BelongingCode
		,IndividualId
		
	FROM @Categorytable
	)
	SELECT BelongingType
		,BelongingCode
		,IndividualId
FROM CTE_Results
WHERE ROWNUM > @FirstRec
	AND ROWNUM < @LastRec
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

	
	