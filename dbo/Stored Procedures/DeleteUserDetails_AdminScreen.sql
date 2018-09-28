CREATE PROCEDURE DeleteUserDetails_AdminScreen(@pcountrycode varchar(10),@pidentityid uniqueidentifier)

AS

BEGIN



DECLARE @countryId UNIQUEIDENTIFIER = (SELECT CountryId FROM Country WHERE CountryISO2A = @pcountrycode)



DELETE FROM SystemUserRole where IdentityUserId=@pidentityid AND CountryId = @countryId



DELETE FROM IdentityUserSession where IdentityUser_Id=@pidentityid



DELETE FROM ActionTask where Assignee_Id=@pidentityid AND Country_Id = @countryId



DELETE FROM [Order] where SentBy_Id=@pidentityid AND Country_Id = @countryId



IF NOT EXISTS (

				SELECT 1

				FROM SystemUserRole

				WHERE IdentityUserId=@pidentityid

				)

BEGIN

	DELETE FROM IdentityUser where Id=@pidentityid

END





END
