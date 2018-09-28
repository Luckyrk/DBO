--select * from collective where sequence=1111111111111111110

--select 1 from collective where sequence=0

--EXEC [InsertHitList] 2015,5,'Z','Irregular',300.5,175,340,3,0,0,0

CREATE PROCEDURE [dbo].[InsertHitList]

	(

	@pPERIOD numeric(6, 0),

	@pHOUSEHOLD_NUMBER numeric(7, 0),

	@pTYPE nvarchar(1),

	@pREASON nvarchar(120),

	@pSPEND_1 float ,

	@pSPEND_2 float,

	@pSPEND_3 float,

	@pHOUSEHOLD_SIZE int,

	@pELIGCODE_1 numeric(1, 0),

	@pELIGCODE_2 numeric(1, 0),

	@pELIGCODE_3 numeric(1, 0),

	@pGPSUser nvarchar(100)

	)

AS

BEGIN



SET NOCOUNT ON;

DECLARE @householdNumberNotExist VARCHAR(max)



SET @householdNumberNotExist = 'Household Number doesnot exist : ' + convert(VARCHAR(10), @pHOUSEHOLD_NUMBER)



BEGIN TRY

IF NOT EXISTS (select 1 from collective where sequence=@pHOUSEHOLD_NUMBER)

		BEGIN

			RAISERROR (

					@householdNumberNotExist

					,16

					,1

					);

		END

ELSE

		DECLARE @GetDate DATETIME
		DECLARE @CountryId UNIQUEIDENTIFIER
		SET @CountryId=(select CountryId from collective where sequence=@pHOUSEHOLD_NUMBER)
		SET @GetDate = (select dbo.GetLocalDateTimeByCountryId(getdate(),@CountryId))
		INSERT INTO dbo.HitList (PERIOD,

			HOUSEHOLD_NUMBER,

			[TYPE],

			REASON,

			SPEND_1,

			SPEND_2,

			SPEND_3,

			HOUSEHOLD_SIZE,

			ELIGCODE_1,

			ELIGCODE_2,

			ELIGCODE_3,
			
			GPSUser,

            GPSUpdateTimestamp,

            CreationTimeStamp)

		VALUES (@pPERIOD,

			@pHOUSEHOLD_NUMBER,

			@pTYPE,

			@pREASON,

			@pSPEND_1,

			@pSPEND_2,

			@pSPEND_3,

			@pHOUSEHOLD_SIZE,

			@pELIGCODE_1,

			@pELIGCODE_2,

			@pELIGCODE_3,
			
			@pGPSUser,
			
			@GetDate,
			
			@GetDate)


END TRY

BEGIN CATCH

		DECLARE @ErrorNumber INT = ERROR_NUMBER();

		DECLARE @ErrorLine INT = ERROR_LINE();

		DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();

		DECLARE @ErrorSeverity INT = ERROR_SEVERITY();

		DECLARE @ErrorState INT = ERROR_STATE();



		RAISERROR (

				@ErrorMessage

				,@ErrorSeverity

				,@ErrorState

				);

	END CATCH



END