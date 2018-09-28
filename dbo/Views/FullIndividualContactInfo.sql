CREATE  VIEW [dbo].[FullIndividualContactInfo]
AS 

SELECT CN.CountryISO2A,   IND.IndividualId, PID.FirstOrderedName, PID.LastOrderedName
       ,( select top 1 adr.addressline1
        from dbo.OrderedContactMechanism ord
        inner join dbo.Address adr on adr.GUIDReference = ord.Address_Id
        inner join dbo.AddressType aty on aty.Id = adr.Type_Id
        inner join dbo.Translation tr1 on tr1.TranslationId = aty.Description_Id
        where aty.DiscriminatorType = 'PhoneAddressType'
        and tr1.KeyName = 'HomePhoneType'
              and ord.Candidate_Id = Ind.GUIDReference
              order by ord.[Order]
    ) AS HomePhone,
       ( select top 1 adr.addressline1
        from dbo.OrderedContactMechanism ord
        inner join dbo.Address adr on adr.GUIDReference = ord.Address_Id
        inner join dbo.AddressType aty on aty.Id = adr.Type_Id
        inner join dbo.Translation tr1 on tr1.TranslationId = aty.Description_Id
        where aty.DiscriminatorType = 'PhoneAddressType'
        and tr1.KeyName = 'WorkPhoneType'
              and ord.Candidate_Id = Ind.GUIDReference
              order by ord.[Order]
    ) AS WorkPhone,
       ( select top 1 adr.addressline1
        from dbo.OrderedContactMechanism ord
        inner join dbo.Address adr on adr.GUIDReference = ord.Address_Id
        inner join dbo.AddressType aty on aty.Id = adr.Type_Id
        inner join dbo.Translation tr1 on tr1.TranslationId = aty.Description_Id
        where aty.DiscriminatorType = 'PhoneAddressType'
        and tr1.KeyName = 'MobilePhoneType'
              and ord.Candidate_Id = Ind.GUIDReference
              order by ord.[Order]
    ) AS MobilePhone,
       ( select top 1 adr.addressline1
        from dbo.OrderedContactMechanism ord
        inner join dbo.Address adr on adr.GUIDReference = ord.Address_Id
        inner join dbo.AddressType aty on aty.Id = adr.Type_Id
        inner join dbo.Translation tr1 on tr1.TranslationId = aty.Description_Id
        where aty.DiscriminatorType = 'ElectronicAddressType'
        and tr1.KeyName = 'PersonalEmailAddressType'
              and ord.Candidate_Id = Ind.GUIDReference
              order by ord.[Order]
    ) AS EmailAddress,
       (select top 1 ISNULL(adr.addressline1,'') + ', ' + ISNULL(adr.addressline2,'') + ', ' + ISNULL(adr.addressline3,'') + ', ' + ISNULL(adr.addressline4,'') + ', ' + ISNULL(adr.postcode,'') addressline1
        from dbo.OrderedContactMechanism ord
        inner join dbo.Address adr on adr.GUIDReference = ord.Address_Id
        inner join dbo.AddressType aty on aty.Id = adr.Type_Id
        inner join dbo.Translation tr1 on tr1.TranslationId = aty.Description_Id
        where aty.DiscriminatorType = 'PostalAddressType'
        and tr1.KeyName = 'HomeAddressType'
              and ord.Candidate_Id = Ind.GUIDReference
              order by ord.[Order]
    ) AS HomeAddress,
       ( select top 1 ISNULL(adr.addressline1,'') + ', ' + ISNULL(adr.addressline2,'') + ', ' + ISNULL(adr.addressline3,'') + ', ' + ISNULL(adr.addressline4,'') + ', ' + ISNULL(adr.postcode,'') addressline1
        from dbo.OrderedContactMechanism ord
        inner join dbo.Address adr on adr.GUIDReference = ord.Address_Id
        inner join dbo.AddressType aty on aty.Id = adr.Type_Id
        inner join dbo.Translation tr1 on tr1.TranslationId = aty.Description_Id
        where aty.DiscriminatorType = 'PostalAddressType'
        and tr1.KeyName = 'PostalAddressType'
              and ord.Candidate_Id = Ind.GUIDReference
              order by ord.[Order]
    ) AS PostalAddress,
       (SELECT TOP 1 Comment FROM IndividualComment 
              WHERE Individual_Id = Ind.GUIDReference
              ORDER BY GPSUpdateTimestamp DESC ) AS Comment
FROM Individual Ind
JOIN Country CN ON CN.CountryId = Ind.CountryId
Join PersonalIdentification PID
on PID.PersonalIdentificationId = Ind.PersonalIdentificationId
GO

