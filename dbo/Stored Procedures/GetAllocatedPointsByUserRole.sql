create PROCEDURE [dbo].[GetAllocatedPointsByUserRole]

	@pRoleName  nvarchar(200),

	@pCountryId UNIQUEIDENTIFIER

	

AS

begin
BEGIN TRY
declare @typeId int

declare @point int

set @typeId =(select SystemRoleTypeId  from SystemRoleType where [Description]=@pRoleName)

IF EXIsTS(select Points from  UserPointsRoleMapping where SystemRoleTypeId =@typeId and CountryId =@pCountryId)
BEGIN
set @point=(select Points from  UserPointsRoleMapping where SystemRoleTypeId =@typeId and CountryId =@pCountryId)
END
ELSE
BEGIN
 set @point= 2147483647;
END

if @point>0

begin

select @point

end

else

begin

select 0

end

	SELECT (

			SELECT dbo.[IsFieldRequiredOrFieldVisible](@pCountryID, 'IsPointsLimitEnable', 0)

			) AS IsAddressHistoryBtn


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
end