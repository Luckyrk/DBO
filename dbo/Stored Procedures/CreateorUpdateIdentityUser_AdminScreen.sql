CREATE PROCEDURE dbo.CreateorUpdateIdentityUser_AdminScreen (

	@pIdentityUserId UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000000'

	,@pUsername VARCHAR(100)

	,@pPassword VARCHAR(200)

	,@pRuleComposerAccess BIT

	,@pSystemroles VARCHAR(max)

	,@pgpsuser VARCHAR(max)

	,@pcountrycode VARCHAR(max)

	)

AS

BEGIN

	DECLARE @pcountryid UNIQUEIDENTIFIER = (

			SELECT TOP 1 CountryId

			FROM Country

			WHERE CountryISO2A = @pcountrycode

			)

	DECLARE @GetDate DATETIME



	SET @GetDate = (

			SELECT dbo.GetLocalDateTimeByCountryId(getdate(), @pcountryid)

			)



	IF (@pIdentityUserId = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER))

	BEGIN

		IF NOT EXISTS (

				SELECT *

				FROM identityuser

				WHERE username = @pUsername

				)

		BEGIN

			SET @pIdentityUserId = newid()



			INSERT INTO IdentityUser

			VALUES (

				@pIdentityUserId

				,@pUsername

				,@pPassword

				,@pgpsuser

				,@GetDate

				,@GetDate

				,@pcountryid

				,NULL

				,NULL

				,NULL

				)



			INSERT INTO SystemUserRole

			SELECT newid()

				,@pIdentityUserId

				,Item

				,@pcountryid

				,@pgpsuser

				,@GetDate

				,@GetDate

			FROM dbo.SplitString(@pSystemroles, ',')



			IF (@pRuleComposerAccess = 1)

				INSERT INTO CountryViewAccess

				VALUES (

					@pUsername

					,@pcountrycode

					,2057

					,1

					)

		END

		ELSE

		BEGIN

			SET @pIdentityUserId = (

					SELECT Id

					FROM identityuser

					WHERE username = @pUsername

					)



			INSERT INTO SystemUserRole

			SELECT newid()

				,@pIdentityUserId

				,Item

				,@pcountryid

				,@pgpsuser

				,@GetDate

				,@GetDate

			FROM dbo.SplitString(@pSystemroles, ',')



			IF (@pRuleComposerAccess = 1)

				INSERT INTO CountryViewAccess

				VALUES (

					@pUsername

					,@pcountrycode

					,2057

					,1

					)

		END

	END

	ELSE

	BEGIN

		IF EXISTS (

				SELECT 1

				FROM IdentityUser

				WHERE Id = @pIdentityUserId

				)

		BEGIN

			UPDATE IdentityUser

			SET UserName = @pUsername

				,[Password] = @pPassword

				,GPSUser = @pgpsuser

				,GPSUpdateTimestamp = @GetDate

			WHERE Id = @pIdentityUserId



			DELETE

			FROM SystemUserRole

			WHERE IdentityUserId = @pIdentityUserId

				AND CountryId = @pcountryid



			INSERT INTO SystemUserRole

			SELECT newid()

				,@pIdentityUserId

				,Item

				,@pcountryid

				,@pgpsuser

				,@GetDate

				,@GetDate

			FROM dbo.SplitString(@pSystemroles, ',')



			IF (@pRuleComposerAccess = 1)

			BEGIN

				IF NOT EXISTS (

						SELECT 1

						FROM CountryViewAccess

						WHERE UserId = @pUsername

						)

					INSERT INTO CountryViewAccess

					VALUES (

						@pUsername

						,@pcountrycode

						,2057

						,1

						)

			END

			ELSE

				DELETE

				FROM CountryViewAccess

				WHERE UserId = @pUsername

		END

	END

END
