
CREATE PROCEDURE [dbo].[deleteUserMappings_AdminScreen] (@pMappingId UNIQUEIDENTIFIER)
AS
BEGIN
	DELETE
	FROM SAMPLEPOINTMAPPING
	WHERE GuidReference = @pMappingId
END
