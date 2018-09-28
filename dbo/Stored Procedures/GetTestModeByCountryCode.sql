
--exec GetTestModeByCountryCode1 'GB','IsTestModeOn'


CREATE PROCEDURE GetTestModeByCountryCode @counrtyCode NVARCHAR(2),@isTestMode NVARCHAR(50)

AS

BEGIN

	DECLARE @configuration_Id UNIQUEIDENTIFIER



	SET @configuration_Id = (

			SELECT Configuration_Id

			FROM [dbo].[Country]

			WHERE CountryISO2A = @counrtyCode

			)

	select [key] as KeyName,[required] as [Required] from fieldconfiguration where [key]=@isTestMode and CountryConfiguration_Id=@configuration_Id

END
