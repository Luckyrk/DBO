CREATE TYPE [dbo].[MorpheusAppUserType] AS TABLE 
(
 AppUserGUID	NVARCHAR (300),
 Email	NVARCHAR (300)  NULL,
 EmailValidated	BIT  NULL,
 AddressLine1	NVARCHAR (MAX)  NULL,
 AddressLine2	NVARCHAR (MAX)  NULL,
 AddressLine3	NVARCHAR (MAX)  NULL,
 AddressLine4	NVARCHAR (MAX)  NULL,
 Postcode	NVARCHAR (MAX)  NULL,
 PhoneNumberHome	NVARCHAR (MAX)  NULL,
 PhoneNumberMobile	NVARCHAR (MAX)  NULL,
 IndividualIDofAppUser	NVARCHAR (300)  NULL,
 IndividualIDofMainShopper	NVARCHAR (300)  NULL,
 IndividualIDofChiefIncomeEarner	NVARCHAR (300)  NULL,
 ShortCode	NVARCHAR (300)  NULL,
 Name	NVARCHAR (300)  NULL,
 JoinDate	NVARCHAR (300)  NULL,
 Gender NVARCHAR (10) NULL,
 DateOfBirth NVARCHAR(300) NULL
)