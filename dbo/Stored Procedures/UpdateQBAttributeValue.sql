CREATE PROCEDURE [dbo].[UpdateQBAttributeValue]
	@pIdentifierType NVARCHAR(20),
	@pIdentifierValue NVARCHAR(20),
	@pAttributeValue NVARCHAR(20),
	@pGPSUser NVARCHAR(20),
	@pSystemDate DATETIME
AS
BEGIN
	
	DECLARE @Country UNIQUEIDENTIFIER = (SELECT CountryId FROM Country WHERE CountryISO2A = 'CN')
       DECLARE @BusinessId NVARCHAR(50) = ''
       DECLARE @Email NVARCHAR(50)
	   DECLARE @Phone NVARCHAR(50)

	   IF (@pIdentifierType = 'u_email') SET @Email = @pIdentifierValue
	   IF (@pIdentifierType = 'u_mobile') SET @Phone = @pIdentifierValue       

	   IF OBJECT_ID('tempdb..#FilteredIds') IS NOT NULL
              TRUNCATE TABLE #FilteredIds
       ELSE
              CREATE TABLE #FilteredIds (GUIDReference UNIQUEIDENTIFIER PRIMARY KEY (GUIDReference))


	   IF (@Email <> '')
       BEGIN
              DECLARE @LocalEmail NVARCHAR(50) = CONCAT (
                           @Email
                           ,'%'
                           );

              INSERT #FilteredIds (GUIDReference)
              SELECT DISTINCT ind.GUIDReference
              FROM Individual ind
              INNER JOIN Candidate c ON c.GUIDReference = ind.GUIDReference
              INNER JOIN CollectiveMembership cm ON cm.Individual_Id=ind.GUIDReference
              INNER JOIN OrderedContactMechanism OCM ON OCM.Candidate_Id=c.GUIDReference
              INNER JOIN [Address] ad ON ad.GUIDReference = OCM.Address_Id
                     AND ad.AddressType = 'ElectronicAddress'
              WHERE c.Country_Id = @Country
                     AND (
                           @LocalEmail IS NULL
                           OR ad.AddressLine1 LIKE @LocalEmail
                           )
       END
       ELSE IF (@Phone <> '')
       BEGIN
              DECLARE @LocalPhone NVARCHAR(50) = CONCAT (
                           @Phone
                           ,'%'
                           );

              INSERT #FilteredIds (GUIDReference)
              SELECT DISTINCT ind.GUIDReference
              FROM Individual ind
              INNER JOIN Candidate c ON c.GUIDReference = ind.GUIDReference
              INNER JOIN CollectiveMembership cm ON cm.Individual_Id=ind.GUIDReference
              Inner Join OrderedContactMechanism oc on oc.Candidate_Id=c.GUIDReference
              INNER JOIN [Address] ad ON ad.GUIDReference = oc.Address_Id
                     AND ad.AddressType = 'PhoneAddress'
              WHERE c.Country_Id = @Country
                     AND (
                           @LocalPhone IS NULL
                           OR ad.AddressLine1 LIKE @LocalPhone
                           )
       END	

	INSERT INTO AttributeValue 
	SELECT NEWID(),(SELECT a.GUIDReference FROM Attribute a	WHERE a.[Key] = 'QuestbackURL'),ids.GUIDReference,NULL,@pGPSUser,@pSystemDate,@pSystemDate,NULL,@pAttributeValue,NULL,@Country,NULL,'StringAttributeValue',NULL
	FROM #FilteredIds ids

END