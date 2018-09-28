CREATE PROCEDURE AccessAreaGrid_AdminScreen(
@pRoleId INT,
@pAccessAreaId INT,
@pCountry varchar(20),
@pPage INT = 1,
@pRecsPerPage INT = 10,
@pSortCol VARCHAR(20) 
)

AS

BEGIN

DECLARE @Categorytable TABLE (
	AccessContextId INT,
	RestrictedAccessAreaId INT,
	Name nvarchar(max),
	[Path] nvarchar(max),
	isAssignedToRole bit,
	SystemRoleTypeId int,
	SystemOperationId int,
	SystemOperation nvarchar(max),
	ActiveFrom datetime,
	ActiveTo datetime
	)

 Declare @AccessContext bigint

 set @AccessContext = (select AccessContextId from AccessContext where  [Description]=@pCountry)


INSERT INTO @Categorytable
select @AccessContext as AccessContextId,RSA.RestrictedAccessAreaId,RSA.Name,RSA.[Path],IIF(AR.IsPermissionGranted IS NULL,0,AR.IsPermissionGranted) AS isAssignedToRole,@pRoleId as SystemRoleTypeId ,
IIF(AR.SystemOperationId IS NULL, 1, AR.SystemOperationId) as SystemOperationId, IIF(RST.[Description]='System - Screen','View',SO.[Description]) AS SystemOperation,AR.ActiveFrom, AR.ActiveTo
from RestrictedAccessSystemArea RSA
LEFT JOIN RestrictedAccessArea RA on rsa.RestrictedAccessAreaId=ra.RestrictedAccessAreaId and RA.RestrictedAccessAreaSubTypeId = @pAccessAreaId
LEFT JOIN RestrictedAccessAreaSubType RST ON  RST.RestrictedAccessAreaSubTypeId = @pAccessAreaId
LEFT JOIN AccessRights AR ON AR.RestrictedAccessAreaId=ra.RestrictedAccessAreaId and AR.AccessContextId=@AccessContext and AR.SystemRoleTypeId = @pRoleId
LEFT JOIN SystemOperation SO on SO.SystemOperationId= AR.SystemOperationId
where ra.RestrictedAccessAreaSubTypeId=@pAccessAreaId and @pRoleId in (select SystemRoleTypeId from systemroletype)
and (ar.activeto is null or ar.activeto > GetDate())



DECLARE @FirstRec INT
	,@LastRec INT

SELECT @FirstRec = (@pPage - 1) * @pRecsPerPage
SELECT @LastRec = (@pPage * @pRecsPerPage + 1)

IF (@pSortCol = '')

BEGIN

SET @pSortCol = 'NameAsc'

END

SELECT count(*) AS TotalRecords
FROM @Categorytable
; WITH CTE_Results
AS (
	SELECT ROW_NUMBER() OVER (
			ORDER BY CASE 
					WHEN @pSortCol = 'IdAsc'
						THEN AccessContextId
					END ASC
				,CASE 
					WHEN @pSortCol = 'IdDesc'
						THEN AccessContextId
					END DESC
				,CASE 
					WHEN @pSortCol = 'RestrictedAccessAreaIdAsc'
						THEN RestrictedAccessAreaId
					END ASC
				,CASE 
					WHEN @pSortCol = 'RestrictedAccessAreaIdDesc'
						THEN RestrictedAccessAreaId
					END DESC
				,CASE 
					WHEN @pSortCol = 'NameAsc'
						THEN Name
					END ASC
				,CASE 
					WHEN @pSortCol = 'NameDesc'
						THEN Name
					END DESC
				,CASE 
					WHEN @pSortCol = 'PathAsc'
						THEN [Path]
					END ASC
				,CASE 
					WHEN @pSortCol = 'PathDesc'
						THEN [Path]
					END DESC
				,CASE 
					WHEN @pSortCol = 'isAssignedToRoleAsc'
						THEN isAssignedToRole
					END ASC
				,CASE 
					WHEN @pSortCol = 'isAssignedToRoleDesc'
						THEN isAssignedToRole
					END DESC
				,CASE 
					WHEN @pSortCol = 'SystemRoleTypeIdAsc'
						THEN SystemRoleTypeId
					END ASC
				,CASE 
					WHEN @pSortCol = 'SystemRoleTypeIdDesc'
						THEN SystemRoleTypeId
					END DESC
				,CASE 
					WHEN @pSortCol = 'SystemOperationIdAsc'
						THEN SystemOperationId
					END ASC
				,CASE 
					WHEN @pSortCol = 'SystemOperationIdDesc'
						THEN SystemOperationId
					END DESC
				,CASE 
					WHEN @pSortCol = 'SystemOperationAsc'
						THEN SystemOperation
					END ASC
				,CASE 
					WHEN @pSortCol = 'SystemOperationDesc'
						THEN SystemOperation
					END DESC
				,CASE 
					WHEN @pSortCol = 'ActiveFromAsc'
						THEN ActiveFrom
					END ASC
				,CASE 
					WHEN @pSortCol = 'ActiveFromDesc'
						THEN ActiveFrom
					END DESC
					,CASE 
					WHEN @pSortCol = 'ActiveToAsc'
						THEN ActiveTo
					END ASC
				,CASE 
					WHEN @pSortCol = 'ActiveToDesc'
						THEN ActiveTo
					END DESC

			) AS ROWNUM,
	AccessContextId ,
	RestrictedAccessAreaId ,
	Name,
	[Path],
	isAssignedToRole,
	SystemRoleTypeId,
	SystemOperationId ,
	SystemOperation ,
	ActiveFrom ,
	ActiveTo 
	FROM @Categorytable
	)

SELECT AccessContextId ,
	RestrictedAccessAreaId ,
	[Path],
	Name,
	isAssignedToRole,
	SystemRoleTypeId,
	SystemOperationId ,
	SystemOperation ,
	ActiveFrom ,
	ActiveTo 
FROM CTE_Results
WHERE ROWNUM > @FirstRec
	AND ROWNUM < @LastRec
ORDER BY ROWNUM ASC


END
