 
Create PROCEDURE [dbo].TransactionDeleteGrid_AdminScreen ( 
     @pCountryISO2A VARCHAR(10)
	,@BatchaId int
	,@pTransactionId varchar(max)
	,@pSortCol VARCHAR(20) = ''
	,@pPage INT = 1
	,@pRecsPerPage INT = 20
	)
AS
/*
Created By: 
Created On:
Purpose:

Updates:
Date - Update purpose.



*/
BEGIN

Declare @countryid uniqueidentifier = (select Top 1 CountryId from country where CountryISO2A=@pCountryISO2A)


DECLARE  @temp1 as table
( IncentiveAccountTransactionId uniqueidentifier)

DECLARE  @temp2 as table
( IncentiveAccountTransactionId uniqueidentifier
	,ParentId   Varchar(20)
)


if (@pTransactionId ='')
BEGIN

insert into  @temp1
select IncentiveAccountTransactionId 
from IncentiveAccountTransaction
where BatchId = @BatchaId AND ParentTransactionId IS NULL 


insert into  @temp2
Select ChildIAT.IncentiveAccountTransactionId,
(convert(varchar(10),IAT1.BatchId) + '-' + convert(varchar(10),IAT1.TransactionId) ) AS Parent
from IncentiveAccountTransaction  IAT1
Join IncentiveAccountTransaction ChildIAT 
ON ChildIAT.ParentTransactionId =  IAT1.IncentiveAccountTransactionId
Where IAT1.BatchId = @BatchaId

UNION ALL

Select ChildIAT.IncentiveAccountTransactionId,
(convert(varchar(10),IAT1.BatchId) + '-' + convert(varchar(10),IAT1.TransactionId) ) AS Parent
from IncentiveAccountTransaction  IAT1
Join IncentiveAccountTransaction ChildIAT 
ON ChildIAT.ParentTransactionId =  IAT1.IncentiveAccountTransactionId
Where ChildIAT.BatchId = @BatchaId

union ALL 
select IncentiveAccountTransactionId, NULL FROM @temp1
END

ELSE
BEGIN

declare @TransactionId int
 set   @TransactionId = ( select cast(@pTransactionId as bigint))
insert into  @temp1
select IncentiveAccountTransactionId 
from IncentiveAccountTransaction
where BatchId = @BatchaId AND ParentTransactionId IS NULL  and TransactionId = @TransactionId


insert into  @temp2
Select ChildIAT.IncentiveAccountTransactionId,
(convert(varchar(10),IAT1.BatchId) + '-' + convert(varchar(10),IAT1.TransactionId) ) AS Parent
from IncentiveAccountTransaction  IAT1
Join IncentiveAccountTransaction ChildIAT 
ON ChildIAT.ParentTransactionId =  IAT1.IncentiveAccountTransactionId
Where IAT1.BatchId = @BatchaId and IAT1.TransactionId = @TransactionId

UNION ALL

Select ChildIAT.IncentiveAccountTransactionId,
(convert(varchar(10),IAT1.BatchId) + '-' + convert(varchar(10),IAT1.TransactionId) ) AS Parent
from IncentiveAccountTransaction  IAT1
Join IncentiveAccountTransaction ChildIAT 
ON ChildIAT.ParentTransactionId =  IAT1.IncentiveAccountTransactionId
Where ChildIAT.BatchId = @BatchaId and ChildIAT.TransactionId = @TransactionId

union ALL 
select IncentiveAccountTransactionId, NULL FROM @temp1
END

DECLARE @Categorytable TABLE (
		 TransactionDate varchar(max)
         ,PointType  varchar(200)
         ,Comments varchar(max)
         ,BusinessId varchar(20)
         ,Balance int
         ,Batchid int
         ,TransactionId int
         ,ParentTransactionId Varchar(30)
		 ,incentiveaccounttransactionid uniqueidentifier

	)
	

	
	INSERT INTO @Categorytable

select iat.TransactionDate
		   ,tt.Value   AS [PointType]
		    ,iat.Comments
		   ,i.individualid AS [BusinessId]
		   ,iat.Balance
		   ,iat.Batchid
		   ,iat.TransactionId
		   , tmp.ParentId AS ParentTransactionId
		  ,iat.incentiveaccounttransactionid 
from IncentiveAccountTransaction iat
INNER JOIN IncentiveAccountTransactionInfo iati  (nolock) ON iati.IncentiveAccountTransactionInfoId = iat.TransactionInfo_Id  and iat.country_id =@countryid
INNER JOIN Individual i ON i.GUIDReference = iat.Account_Id  
INNER JOIN IncentivePoint ip  ON ip.GUIDReference = iati.Point_Id 
INNER JOIN IncentivePointAccountEntryType ipae ON ipae.GUIDReference = ip.[Type_Id]
INNER JOIN TranslationTerm tt ON tt.translation_Id = ipae.TypeName_Id and CultureCode = 2057
JOIN @temp2 tmp ON tmp.IncentiveAccountTransactionId = iat.IncentiveAccountTransactionId

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
					WHEN @pSortCol = 'TransactionDate_Asc'
						THEN TransactionDate
					END ASC
				,CASE 
					WHEN @pSortCol = 'TransactionDate_Desc'
						THEN TransactionDate
					END DESC
				,CASE 
					WHEN @pSortCol = 'PointType_Asc'
						THEN PointType
					END ASC
				,CASE 
					WHEN @pSortCol = 'PointType_Desc'
						THEN PointType
					END DESC
				,CASE 
					WHEN @pSortCol = 'Comments_Asc'
						THEN Comments
					END ASC
				,CASE 
					WHEN @pSortCol = 'Comments_Desc'
						THEN Comments
					END DESC
				,CASE 
					WHEN @pSortCol = 'BusinessId_Asc'
						THEN BusinessId
					END ASC
				,CASE 
					WHEN @pSortCol = 'BusinessId_Desc'
						THEN BusinessId
					END DESC
					,CASE 
					WHEN @pSortCol = 'Balance_Asc'
						THEN Balance
					END ASC
				,CASE 
					WHEN @pSortCol = 'Balance_Desc'
						THEN Balance
					END DESC
					,CASE 
					WHEN @pSortCol = 'Batchid_Asc'
						THEN Batchid
					END ASC
				,CASE 
					WHEN @pSortCol = 'Batchid_Desc'
						THEN Batchid
					END DESC
						,CASE 
					WHEN @pSortCol = 'TransactionId_Asc'
						THEN TransactionId
					END ASC
				,CASE 
					WHEN @pSortCol = 'TransactionId_Desc'
						THEN TransactionId
					END DESC
						,CASE 
					WHEN @pSortCol = 'ParentTransactionId_Asc'
						THEN ParentTransactionId
					END ASC
				,CASE 
					WHEN @pSortCol = 'ParentTransactionId_Desc'
						THEN ParentTransactionId
					END DESC
				,CASE 
					WHEN @pSortCol = 'incentiveaccounttransactionid_Asc'
						THEN ParentTransactionId
					END ASC
				,CASE 
					WHEN @pSortCol = 'incentiveaccounttransactionid_Desc'
						THEN ParentTransactionId
					END DESC
			) AS ROWNUM
	    , TransactionDate 
         ,PointType  
         ,Comments 
         ,BusinessId 
         ,Balance 
         ,Batchid 
         ,TransactionId 
         ,ParentTransactionId,
		 incentiveaccounttransactionid
	FROM @Categorytable
	)
	SELECT TransactionDate 
         ,PointType  
         ,Comments 
         ,BusinessId 
         ,Balance 
         ,Batchid 
         ,TransactionId 
         ,ParentTransactionId 
		 ,incentiveaccounttransactionid
FROM CTE_Results
WHERE ROWNUM > @FirstRec
	AND ROWNUM < @LastRec
ORDER BY ROWNUM ASC,TransactionId desc

END

GO


