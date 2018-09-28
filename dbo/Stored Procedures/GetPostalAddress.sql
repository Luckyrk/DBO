/*##########################################################################
-- Name             : GetPostalAddress.sql
-- Date             : 2014-11-05
-- Author           : Teena Areti
-- Company          : Cognizant Technology Solution
-- Purpose          : This Procedure gets the postal address for the individual
-- Usage            : 
-- Impact           : GPS Application
-- Required grants  : 
-- Called by        : GPS Application
-- PARAM Definitions
       @pCultureCode INT -- Culture Code
       @pBusinessId uniqueidentifier -- Individual Guid
       @pAddressType NVARCHAR(50) --Type of the address.
-- Sample Execution :
		EXEC GetPostalAddress 1067,'BC05A5FD-CB7E-C4F4-C1A6-08D11B004586','PostalAddress',1
		EXEC GetPostalAddress 1067,'BC05A5FD-CB7E-C4F4-C1A6-08D11B004586','PostalAddress',null                                    
##########################################################################
-- ver  user               date        change 
-- 1.0  Teena Areti     2014-11-05		initial
-- 1.1	Teena Areti		2014-11-21	 Added gettranslatedvalue function to retrieve key and value
-- 1.2  Ramana			2014-12-10 
-- 1.3  Ramana          2015-01-04   Always Homeaddress should come first
##########################################################################*/
CREATE PROCEDURE [dbo].[GetPostalAddress] @pCultureCode INT

	,@pBusinessId UNIQUEIDENTIFIER

	,@pAddressType NVARCHAR(256)

	,@pType INT = NULL

AS

BEGIN



	declare @countryId UNIQUEIDENTIFIER

	declare @Isaddressline1 bit

	set @countryId=(select CountryId from Individual where GUIDReference =@pBusinessId)

	set @Isaddressline1=(select (Required) from Fieldconfiguration where [Key]='IsAddressLine1UpperCase' and CountryConfiguration_Id=(select Configuration_Id from country where CountryId=@countryId))

	DECLARE @anon NVARCHAR(20) = 'XXXXXXXXX';

	SELECT 
		 IIF(I.IsAnonymized = 1 AND T.KeyName<>'HomeAddressType', @anon, IIF(@Isaddressline1=1, UPPER(A.AddressLine1), A.AddressLine1)) as AddressLine1
		,IIF(I.IsAnonymized = 1 AND T.KeyName<>'HomeAddressType', @anon, A.AddressLine2) as AddressLine2
		,IIF(I.IsAnonymized = 1 AND T.KeyName<>'HomeAddressType', @anon, A.AddressLine3) as AddressLine3
		,IIF(I.IsAnonymized = 1 AND T.KeyName<>'HomeAddressType', @anon, A.AddressLine4) as AddressLine4
		,IIF(I.IsAnonymized = 1 AND T.KeyName<>'HomeAddressType', @anon, A.PostCode	) as PostCode
		,CC.HasPostalCodeAssociatedInformation
		,CC.PostalCodeAssociatedInformationUrl
		,A.GUIDReference AS Id
		,O.[Order]
		,T.KeyName AS DescriptionKey
		,dbo.GetTranslationValue(AT.Description_Id, @pCultureCode) AS Description
		,AT.Id AS Id
		,CASE
		 WHEN ISNULL(T.KeyName,'')='HomeAddressType' THEN 1
		 ELSE 2
		 END AS RNO
	FROM [Address] A
	INNER JOIN AddressType AT ON A.[Type_Id] = At.Id
	INNER JOIN Translation T ON T.TranslationId = AT.Description_Id
	INNER JOIN OrderedContactMechanism O ON O.Address_Id = A.GUIDReference
	INNER JOIN Candidate C ON C.GUIDReference = O.Candidate_Id
	INNER JOIN Individual I ON I.GUIDReference = O.Candidate_Id
		--Revision 1.2

		AND A.GUIDReference = CASE 

			WHEN @pType IS NOT NULL

				THEN IIF(I.MainPostalAddress_Id IS NOT NULL, I.MainPostalAddress_Id, A.GUIDReference)

			ELSE A.GUIDReference

			END

	INNER JOIN Country CO ON CO.CountryId = C.Country_Id

	INNER JOIN CountryConfiguration CC ON CC.Id = CO.Configuration_Id

	WHERE I.GUIDReference = @pBusinessId

	AND A.Country_Id =@countryId

		AND A.AddressType = @pAddressType

		AND O.[Order] = ISNULL(@pType, O.[Order])

	ORDER BY [Order] ASC
END

