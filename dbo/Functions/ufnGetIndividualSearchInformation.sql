Create FUNCTION [dbo].[ufnGetIndividualSearchInformation](
	@Individualguid UNIQUEIDENTIFIER, 
	@Countryid UNIQUEIDENTIFIER, 
	@CultureCode INT)

RETURNS @Retindividualsearchinformation TABLE ( 
  -- Columns returned by the function 
  Name					NVARCHAR(500) NULL,  
  GeographicArea		NVARCHAR(500) NULL, 
  Phone					NVARCHAR(500) NULL, 
  EmailAddress			NVARCHAR(500) NULL,
  Alias                 NVARCHAR(500) NUll, 
  PostalAddress			NVARCHAR(500) NULL, 
  BusinessId			NVARCHAR(50) NULL, 
  PanelName				NVARCHAR(500) NULL,
  GroupContact			BIT,
  NextCall				DATETIME NULL,
  Frequency				NVARCHAR(50),
  Id					UNIQUEIDENTIFIER NULL,
  GPSUpdateTimestamp	DATETIME NULL,
  Sequence VARCHAR(100)) 
AS 
  BEGIN 

		DECLARE @IndividualguidLocal UNIQUEIDENTIFIER=@Individualguid
		DECLARE @CountryidLocal UNIQUEIDENTIFIER=@Countryid
		DECLARE @CultureCodeLocal INT =@CultureCode
	

DECLARE @Table TABLE(GUIDReference uniqueidentifier, combined nvarchar(1000))
insert into @Table SELECT  Individual.GUIDReference,NAC.[NAME] +': ' +NA.[KEY] as combined FROM dbo.Individual  INNER JOIN
           dbo.Candidate CAN ON dbo.Individual.GUIDReference = CAN.GUIDReference INNER JOIN
           dbo.Country ON CAN.Country_ID = dbo.Country.CountryId    
		   inner JOIN dbo.NamedAlias as NA on NA.Candidate_Id = CAN.GUIDReference
		   inner JOIN dbo.NamedAliasContext as NAC on NA.AliasContext_Id = NAC.NamedAliasContextId
		  where  Individual.GUIDReference =@Individualguid 

      INSERT @Retindividualsearchinformation 
      SELECT TOP 1
			CONCAT(pid.FirstOrderedName,' ', pid.MiddleOrderedName,' ',pid.LastOrderedName) AS Name, 
            
			ga.Code AS GeographicAreaCode, 
			
			(SELECT TOP 1 AddressLine1 FROM OrderedContactMechanism OCM 
				JOIN [Address] A ON OCM.Address_Id = A.GUIDReference AND A.AddressType = 'PhoneAddress'
				WHERE Candidate_Id = @Individualguid
				ORDER BY OCM.[Order]) AS Phone,

			(SELECT TOP 1 AddressLine1 FROM OrderedContactMechanism OCM 
				JOIN [Address] A ON OCM.Address_Id = A.GUIDReference AND A.AddressType = 'ElectronicAddress'
				WHERE Candidate_Id = @Individualguid
				ORDER BY OCM.[Order]) AS EmailAddress,

			(SELECT  Top 1 
       STUFF((SELECT ', ' + CAST(combined AS VARCHAR(1000)) [text()] 
         FROM @Table 
         WHERE GUIDReference = t.GUIDReference
         FOR XML PATH(''), TYPE)
        .value('.','NVARCHAR(MAX)'),1,2,' ') Alias
FROM @Table t) ,


			
			/*IIF (ind.MainPhoneAddress_Id IS NULL, '', (SELECT AddressLine1 FROM [Address] WHERE GUIDReference = ind.MainPhoneAddress_Id)) as Phone,

			IIF (ind.MainPhoneAddress_Id IS NULL, '', (SELECT AddressLine1 FROM [Address] WHERE GUIDReference = ind.MainEmailAddress_Id)) as EmailAddress,*/
 
 			IIF (ind.MainPostalAddress_Id IS NULL, '', 
				(SELECT CONCAT(IIF(AddressLine1 IS NULL,'' ,AddressLine1 +', '), IIF(AddressLine2 IS NULL,'' ,AddressLine2 +', '), IIF(AddressLine3 IS NULL,'' ,AddressLine3 +', '), 
					IIF(AddressLine4 IS NULL,'' ,AddressLine4 +', '), ISNULL(PostCode,'')) FROM [Address] WHERE  GUIDReference = ind.MainPostalAddress_Id)) as PostalAddress,

			ind.IndividualId AS BusinessID, 

			ISNULL(STUFF((SELECT CONCAT(', ',Panel.Name,' (', dbo.GetTranslationValue(sd.Label_Id, @CultureCode),')')
				FROM 
					(SELECT p.* FROM Panelist p WHERE p.PanelMember_Id = ind.GUIDReference
					UNION SELECT p.* FROM Panelist p
						JOIN CollectiveMembership cm on p.PanelMember_Id = cm.Group_Id
						 WHERE cm.Individual_Id = ind.GUIDReference) p
					JOIN Panel ON Panel.GUIDReference=P.Panel_Id
					JOIN StateDefinition sd on p.State_Id=sd.Id
					--JOIN TranslationTerm tt on sd.Label_Id=tt.Translation_Id AND tt.CultureCode=@CultureCode
					ORDER BY Panel.Panels_Order FOR XML PATH('')), 1, 1, ''),'') AS PanelName,

			IIF(c.GroupContact_Id=ind.GUIDReference, 1,0) AS GroupContact,

			ce.[Date] as NextCall,

			(SELECT TOP 1 dbo.GetTranslationValue(Translation_Id, @CultureCodelocal) FROM EventFrequency WHERE GUIDReference = ce.Frequency_Id) as Frequency,

			ind.GUIDReference AS Id,

			can.GPSUpdateTimestamp,
			c.Sequence
      FROM   Candidate can
             JOIN Individual ind ON can.GUIDReference = ind.GUIDReference 
             JOIN PersonalIdentification pid ON ind.PersonalIdentificationId = pid.PersonalIdentificationId
			 JOIN CollectiveMembership cm ON cm.Individual_Id=ind.GUIDReference			 
			 JOIN StateDefinition sd ON sd.Id=cm.State_Id
			 JOIN Collective c ON c.GUIDReference = cm.Group_Id
			 LEFT JOIN GeographicArea ga ON ga.GUIDReference = can.GeographicArea_Id
			 LEFT JOIN CalendarEvent ce ON ce.Id = ind.Event_Id			 
      WHERE  ind.GUIDReference = @IndividualguidLocal 
             AND can.Country_Id = @CountryidLocal
	  ORDER BY sd.InactiveBehavior DESC, cm.GPSUpdateTimestamp DESC
      RETURN 
  END
