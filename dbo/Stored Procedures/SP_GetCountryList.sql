CREATE PROCEDURE [dbo].[SP_GetCountryList]
AS

BEGIN
SET NOCOUNT ON;

SELECT CountryId , CountryISO2A as CountryCode  from Country
 
END