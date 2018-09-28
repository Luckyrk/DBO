/*##########################################################################
-- Name             : GetPhoneorElectronicAddress.sql
-- Date             : 2014-11-05
-- Author           : Teena Areti
-- Company          : Cognizant Technology Solution
-- Purpose          : This Procedure gets the address details linked to individuals phone or email
-- Usage            : 
-- Impact           : GPS Application
-- Required grants  : 
-- Called by        : GPS Application
-- PARAM Definitions
       @pCultureCode INT -- Culture Code
       @pBusinessId uniqueidentifier -- GUID of individual 
       @pAddressType NVARCHAR(50) --Type of the address. Can be either 'PhoneAddress' or 'ElectronicAddress'
-- Sample Execution :
		EXEC GetPhoneorElectronicAddress 1067,'BC05A5FD-CB7E-C4F4-C1A6-08D11B004586','PhoneAddress'
		EXEC GetPhoneorElectronicAddress 1067,'BC05A5FD-CB7E-C4F4-C1A6-08D11B004586','ElectronicAddress'                                     
##########################################################################
-- ver  user               date        change 
-- 1.0  Teena Areti     2014-11-05		initial
-- 1.1	Teena Areti		2014-11-21	 Added gettranslatedvalue function to retrieve key and value
##########################################################################*/

CREATE PROCEDURE [dbo].[GetPhoneorElectronicAddress] @pCultureCode INT
	,@pBusinessId uniqueidentifier
	,@pAddressType NVARCHAR(50)
AS

declare @countryId UNIQUEIDENTIFIER

set @countryId=(select CountryId from Individual where GUIDReference =@pBusinessId)

SELECT 
	IIF(I.IsAnonymized=1, 'XXXXXXXXX', A.AddressLine1) as AddressLine1
	,A.GUIDReference as Id
	,T.KeyName AS DescriptionKey
	,dbo.GetTranslationValue(AT.Description_Id, @pCultureCode) AS Description
	,AT.Id AS Id
FROM [Address] A
INNER JOIN AddressType AT ON A.[Type_Id] = At.Id
	INNER JOIN Translation T ON T.TranslationId = AT.Description_Id
INNER JOIN OrderedContactMechanism O ON O.Address_Id = A.GUIDReference
INNER JOIN Candidate C ON C.GUIDReference = O.Candidate_Id
INNER JOIN Individual I ON I.GUIDReference = O.Candidate_Id
WHERE I.GUIDReference = @pBusinessId
	AND A.AddressType = @pAddressType
	AND A.Country_Id =@countryId
	
ORDER BY O.[Order]	