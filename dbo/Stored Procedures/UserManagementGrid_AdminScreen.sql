CREATE PROCEDURE [dbo].[UserManagementGrid_AdminScreen] (
  	@pcountrycode VARCHAR(10)
	, @psearchText NVARCHAR(MAX) 
	,@pSortCol VARCHAR(20) = ''
	,@pPage INT = 1
	,@pRecsPerPage INT = 10
	)
AS
BEGIN
BEGIN TRY 
DECLARE @userstable TABLE (
	id UNIQUEIDENTIFIER
	,UserName VARCHAR(100)
	,Descriptions VARCHAR(5000)
	)

IF(LEN(@psearchText)!=0)
	BEGIN
		INSERT INTO @userstable
				SELECT ID
					,UserName
					,Descriptions

				FROM (SELECT Main.UserName
						,LEFT(Main.Descriptions, LEN(Main.Descriptions) - 1) AS Descriptions
						,Main.ID
					FROM (	SELECT DISTINCT V2.UserName
							,ID
							,(SELECT V.Description + ',' AS [text()]
								FROM (SELECT UserName
										,IU.Id ID
										,Description
									FROM IdentityUser IU
									INNER JOIN SystemUserRole SUR ON IU.Id = SUR.IdentityUserId
									INNER JOIN SystemRoleType SRT ON SRT.SystemRoleTypeId = SUR.SystemRoleTypeId
									INNER JOIN Country C ON C.CountryId = SUR.CountryId
									WHERE CountryISO2A =@pcountrycode
									GROUP BY UserName
										,Description
										,IU.id
									) V
								WHERE V.UserName = V2.UserName
								GROUP BY v.UserName
									,V.Description
								ORDER BY V.UserName
								FOR XML PATH('')
								) [Descriptions]
						FROM (	SELECT UserName
								,IU.Id ID
								,Description
							FROM IdentityUser IU
							INNER JOIN SystemUserRole SUR ON IU.Id = SUR.IdentityUserId
							INNER JOIN SystemRoleType SRT ON SRT.SystemRoleTypeId = SUR.SystemRoleTypeId
							INNER JOIN Country C ON C.CountryId = SUR.CountryId
							WHERE CountryISO2A = @pcountrycode
							GROUP BY UserName
								,Description
								,IU.Id
							) V2
						) [Main]
					) v where v.UserName like '%'+@psearchText+'%' or v.Descriptions like '%'+@psearchText+'%'
	END
ELSE
	BEGIN
		INSERT INTO @userstable
			SELECT ID
				,UserName
				,Descriptions
			FROM (	SELECT Main.UserName
				,LEFT(Main.Descriptions, LEN(Main.Descriptions) - 1) AS Descriptions
					,Main.ID
				FROM (	SELECT DISTINCT V2.UserName
						,ID
						,(SELECT V.Description + ',' AS [text()]
							FROM (	SELECT UserName
									,IU.Id ID
									,Description
								FROM IdentityUser IU
								INNER JOIN SystemUserRole SUR ON IU.Id = SUR.IdentityUserId
								INNER JOIN SystemRoleType SRT ON SRT.SystemRoleTypeId = SUR.SystemRoleTypeId
								INNER JOIN Country C ON C.CountryId = SUR.CountryId
								WHERE CountryISO2A =@pcountrycode
								GROUP BY UserName
									,Description
									,IU.id
								) V
							WHERE V.UserName = V2.UserName
							GROUP BY v.UserName
								,V.Description
							ORDER BY V.UserName
							FOR XML PATH('')
							) [Descriptions]
					FROM (	SELECT UserName
							,IU.Id ID
							,Description
						FROM IdentityUser IU
						INNER JOIN SystemUserRole SUR ON IU.Id = SUR.IdentityUserId
						INNER JOIN SystemRoleType SRT ON SRT.SystemRoleTypeId = SUR.SystemRoleTypeId
						INNER JOIN Country C ON C.CountryId = SUR.CountryId
						WHERE CountryISO2A = @pcountrycode
						GROUP BY UserName
							,Description
							,IU.Id
						) V2
					) [Main]
				) v
	END


DECLARE @FirstRec INT
	,@LastRec INT
SELECT @FirstRec = (@pPage - 1) * @pRecsPerPage
SELECT @LastRec = (@pPage * @pRecsPerPage + 1)
SELECT count(*) AS TotalRecords
FROM @userstable
; WITH CTE_Results
AS (
	SELECT ROW_NUMBER() OVER (
			ORDER BY CASE 
					WHEN @pSortCol = 'ID_Asc'
						THEN ID
					END ASC
				,CASE 
					WHEN @pSortCol = 'ID_Desc'
						THEN ID
					END DESC
				,CASE 
					WHEN @pSortCol = 'Username_Asc'
						THEN UserName
					END ASC
				,CASE 
					WHEN @pSortCol = 'Username_Desc'
						THEN UserName
					END DESC
				,CASE 
					WHEN @pSortCol = 'Descriptions_Asc'
						THEN Descriptions
					END ASC
				,CASE 
					WHEN @pSortCol = 'Descriptions_Desc'
						THEN Descriptions
					END DESC
			) AS ROWNUM
		,ID
		,UserName
		,Descriptions
	FROM @userstable
	)
SELECT ID
	,UserName
	,Descriptions AS UserRoles
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