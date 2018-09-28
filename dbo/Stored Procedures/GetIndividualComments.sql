
CREATE PROCEDURE [dbo].[GetIndividualComments] @pIndividualId UNIQUEIDENTIFIER

AS

BEGIN
BEGIN TRY 

	SET NOCOUNT ON



	DECLARE @CountryId UNIQUEIDENTIFIER

		,@NoOfRecords INT



	SET @CountryId = (

			SELECT TOP 1 CountryId

			FROM Individual

			WHERE GUIDReference = @pIndividualId

			)



	IF (

			@CountryId IN (

				SELECT C.CountryId

				FROM FieldConfiguration FC

				INNER JOIN Country C ON C.Configuration_Id = FC.CountryConfiguration_Id

				WHERE [Key] = 'IndividualComment'

					AND [Visible] = 1

				)

			)

	BEGIN

		SET @NoOfRecords = 1

	END

	ELSE

	BEGIN

		SET @NoOfRecords = 100000

	END



	SELECT Id, Comment, CommentDate, GPSUser, CreationTimestamp

	FROM (

		SELECT TOP (@NoOfRecords) IC.Id

			,IC.Comment

			,IC.GPSUpdateTimestamp AS CommentDate

			,IC.GPSUser

			,Ic.CreationTimeStamp

		FROM Individual I

		INNER JOIN IndividualComment IC ON I.Guidreference = IC.Individual_Id

		WHERE I.GUIDReference = @pIndividualId AND IC.Comment NOT LIKE '%<a href=''[0-9]%'

		ORDER BY CommentDate DESC

	) AS IC



	UNION



	SELECT IC.Id

		,IC.Comment

		,IC.GPSUpdateTimestamp AS CommentDate

		,IC.GPSUser

		,Ic.CreationTimeStamp

	FROM Individual I

	INNER JOIN IndividualComment IC ON I.Guidreference = IC.Individual_Id

	WHERE I.GUIDReference = @pIndividualId AND IC.Comment LIKE '%<a href=''[0-9]%'



	ORDER BY CommentDate DESC

	declare @pCountryId uniqueidentifier	
	DECLARE @isIndividualCommentVisible BIT
set @pCountryId=(select CountryId from Individual where GUIDReference=@pIndividualId)
	SELECT @isIndividualCommentVisible = dbo.[IsFieldRequiredOrFieldVisible](@pCountryId, 'IndividualComment', 0)
	SELECT @isIndividualCommentVisible
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